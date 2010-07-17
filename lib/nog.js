(function(){
  var CONTENT_TYPE, Connect, ConnectUtils, Controller, Handler, Jade, Path, Sherpa, fs, startsWithAPeriod, sys;
  var __slice = Array.prototype.slice;
  Connect = require('connect');
  ConnectUtils = require('connect/utils');
  Jade = require('jade');
  Path = require('path');
  Sherpa = require('sherpa/connect');
  sys = require('sys');
  fs = require('fs');
  startsWithAPeriod = /^\./;
  CONTENT_TYPE = 'Content-Type';
  Handler = function(req, resp, params, controller, next) {
    this.request = req;
    this.response = resp;
    this.params = params;
    this.controller = controller;
    this.status = 200;
    this.headers = {};
    this.data = {};
    this.next = next;
    return this;
  };
  Handler.prototype.content_type = function(type) {
    type ? !type.match(startsWithAPeriod) ? (type = ("." + (type))) : null : (type = ("." + (this.format())));
    this.headers[CONTENT_TYPE] = ConnectUtils.mime.type(type);
    return this.headers[CONTENT_TYPE];
  };
  Handler.prototype.format = function() {
    return this.request.format || "html";
  };
  Handler.prototype.render = function(name, opts, fn) {
    var _a, out, path;
    opts = (typeof opts !== "undefined" && opts !== null) ? opts : {};
    opts.format = (typeof (_a = opts.format) !== "undefined" && _a !== null) ? opts.format : this.format();
    path = this.controller.templatePathFor(name, opts);
    opts.scope = this;
    if (path) {
      out = Jade.renderFile(path, opts, fn);
      return out;
    } else {
      return fn(new Error(("Template '" + (name) + "' not found")));
    }
  };
  Handler.prototype.respond = function(content, opts) {
    opts = (typeof opts !== "undefined" && opts !== null) ? opts : {};
    this.status = opts.status || this.status;
    ConnectUtils.merge(this.headers, opts.headers || {});
    !this.headers[CONTENT_TYPE] ? this.content_type(opts.format) : null;
    this.response.writeHead(this.status, this.headers);
    this.response.write(content);
    return this.response.end();
  };
  Handler.prototype.render_and_respond = function(name, opts) {
    var self;
    self = this;
    return this.render(name, opts, function(err, content) {
      if (err) {
        return self.respond(err.message, {
          status: 500
        });
      } else {
        return self.respond(content);
      }
    });
  };
  Handler.prototype.redirect = function(url, status) {
    status = (typeof status !== "undefined" && status !== null) ? status : 302;
    this.headers['Location'] = url;
    this.status = status;
    return this.respond(("Redirecting to " + (url)));
  };

  Controller = function(name, opts) {
    opts = (typeof opts !== "undefined" && opts !== null) ? opts : {};
    if (!(name)) {
      throw new Error("Controller Name Not Given");
    }
    this.name = name;
    this.options = opts;
    this.stack = Connect.createServer();
    this.router = new Sherpa.Connect();
    this.connector = Connect.createServer(this.stack, this.router.connector());
    this.Handler = opts.Handler || Handler;
    this.templateCache = {};
    this.roots = opts.roots || [process.cwd()];
    this.paths = opts.paths || {
      views: ["views", ("views/" + (name)), "app/views", ("app/views/" + (name))]
    };
    return this;
  };
  Controller.prototype.use = function() {
    var args;
    var _a = arguments.length, _b = _a >= 1;
    args = __slice.call(arguments, 0, _a - 0);
    return this.stack.use.apply(this.stack, args);
  };
  Controller.prototype.GET = function(route, opts, fn) {
    return this.handleRoute('GET', route, opts, fn);
  };
  Controller.prototype.POST = function(route, opts, fn) {
    return this.handleRoute('POST', route, opts, fn);
  };
  Controller.prototype.PUT = function(route, opts, fn) {
    return this.handleRoute('PUT', route, opts, fn);
  };
  Controller.prototype.DELETE = function(route, otps, fn) {
    return this.handleRoute('DELETE', route, opts, fn);
  };
  Controller.prototype.OPTIONS = function(route, opts, fn) {
    return this.handleRoute('OPTIONS', route, opts, fn);
  };
  Controller.prototype.HEAD = function(route, opts, fn) {
    return this.handleRoute('HEAD', route, opts, fn);
  };
  Controller.prototype.ANY = function(route, opts, fn) {
    return this.handleRoute('ANY', route, opts, fn);
  };
  Controller.prototype.handleRoute = function(meth, route, opts, fn) {
    var dispatcher, self;
    self = this;
    dispatcher = function(req, resp, next) {
      var handler, out, params;
      params = req.sherpaResponse.params;
      handler = new Handler(req, resp, params, self, next);
      out = fn.call(handler, params);
      return out;
    };
    return this.router[meth](route, opts).to(dispatcher);
  };
  Controller.prototype.templateNames = function(name, opts) {
    var fmt;
    opts = (typeof opts !== "undefined" && opts !== null) ? opts : {};
    fmt = opts.format || 'html';
    return [("" + (name) + "." + (fmt) + "." + (process.connectEnv.name)), ("" + (name) + "." + (fmt)), name];
  };
  Controller.prototype.templatePathFor = function(name, opts) {
    var _a, _b, _c, _d, _e, _f, _g, _h, _i, _root, existing, fullPath, path, possible, template, viewPath;
    possible = this.templateNames(name, opts);
    existing = this.templateCache[possible];
    if (existing) {
      return existing;
    }
    _b = this.roots.reverse();
    for (_a = 0, _c = _b.length; _a < _c; _a++) {
      _root = _b[_a];
      _e = this.paths.views.reverse();
      for (_d = 0, _f = _e.length; _d < _f; _d++) {
        viewPath = _e[_d];
        _h = possible;
        for (_g = 0, _i = _h.length; _g < _i; _g++) {
          path = _h[_g];
          try {
            fullPath = Path.join(_root, viewPath, ("" + (path) + ".jade"));
            template = fs.statSync(fullPath);
            this.templateCache[possible] = fullPath;
            break;
          } catch (e) {
            "noop";
          }
          if (this.templateCache[possible]) {
            break;
          }
        }
      }
      if (this.templateCache[possible]) {
        break;
      }
    }
    return this.templateCache[possible];
  };

  module.exports.N = {};
  module.exports.N.Controller = Controller;
  module.exports.N.Handler = Handler;
})();
