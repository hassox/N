(function(){
  var CONTENT_TYPE, Connect, ConnectUtils, Controller, ControllerViewContext, Handler, Jade, Path, RenderMixin, Sherpa, ViewContext, fs, startsWithAPeriod, sys, url;
  var __extends = function(child, parent) {
    var ctor = function(){ };
    ctor.prototype = parent.prototype;
    child.__superClass__ = parent.prototype;
    child.prototype = new ctor();
    child.prototype.constructor = child;
  }, __slice = Array.prototype.slice;
  Connect = require('connect');
  ConnectUtils = require('connect/utils');
  Jade = require('jade');
  Path = require('path');
  Sherpa = require('sherpa/connect');
  RenderMixin = require('./render');
  ViewContext = require('./viewContext');
  url = require('url');
  sys = require('sys');
  fs = require('fs');
  startsWithAPeriod = /^\./;
  CONTENT_TYPE = 'Content-Type';
  ControllerViewContext = function() {
    return ViewContext.apply(this, arguments);
  };
  __extends(ControllerViewContext, ViewContext);
  ControllerViewContext.mixin = ViewContext.mixin;

  Handler = function(req, resp, params, controller, next) {
    var _a, _b;
    req.N = (typeof (_a = req.N) !== "undefined" && _a !== null) ? req.N : {};
    this.request = req;
    this.response = resp;
    this.params = params;
    this.controller = controller;
    this.status = 200;
    this.headers = {};
    this.data = {};
    this.next = next;
    if (req.N.url && req.N.url.query) {
      this.queryParams = req.N.url.query;
    } else {
      req.N.url = url.parse(req.url, true);
      this.queryParams = req.N.url.query;
    }
    this.queryParams = (typeof (_b = this.queryParams) !== "undefined" && _b !== null) ? this.queryParams : {};
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
  Handler.prototype.render = function(name, opts, callback) {
    var _a, context, layout, locals, useLayout;
    if (!callback) {
      callback = opts;
      opts = {};
    }
    opts = (typeof opts !== "undefined" && opts !== null) ? opts : {};
    opts.format = (typeof (_a = opts.format) !== "undefined" && _a !== null) ? opts.format : this.format();
    layout = (function() {
      if (opts.layout) {
        useLayout = true;
        if (!opts.layout === true) {
          layout = opts.layout;
          return layout;
        }
      } else {
        useLayout = false;
        return useLayout;
      }
    })();
    context = new this.controller.constructor.ViewContext(this.request, opts);
    locals = {
      data: this.data,
      params: this.params
    };
    try {
      if (useLayout && this.request.layout) {
        this.request.layout.content.main = this.controller.renderTemplate(name, opts, context, locals);
        if (layout) {
          this.request.layout.templateName = layout;
        }
        return callback(null, this.request.layout.layout());
      } else {
        return callback(null, this.controller.renderTemplate(name, opts, context, locals));
      }
    } catch (err) {
      return callback(err);
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
    opts = (typeof opts !== "undefined" && opts !== null) ? opts : {};
    self = this;
    if (opts.layout !== false) {
      opts.layout = true;
    }
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
    this.connect = function(opts) {
      return Connect.createServer(this.stack, this.router.connect(opts));
    };
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
      handler = new self.Handler(req, resp, params, self, next);
      out = fn.call(handler, params);
      return out;
    };
    return this.router[meth](route, opts).to(dispatcher);
  };

  RenderMixin(Controller);
  Controller.ViewContext = ControllerViewContext;
  module.exports.Controller = Controller;
  module.exports.Handler = Handler;
})();
