(function(){
  var Connect, ConnectUtils, Jade, Path, fs, noFileRegexp, renderTemplate, sys, templateNames;
  Connect = require('connect');
  ConnectUtils = require('connect/utils');
  Jade = require('jade');
  Path = require('path');
  fs = require('fs');
  sys = require('sys');
  noFileRegexp = /No such file or directory/i;
  templateNames = function(name, opts) {
    var fmt;
    opts = (typeof opts !== "undefined" && opts !== null) ? opts : {};
    fmt = opts.format || this._format();
    return [("" + (name) + "." + (fmt) + "." + (process.connectEnv.name)), ("" + (name) + "." + (fmt)), name];
  };
  renderTemplate = function(name, opts, context, locals) {
    var _a, _b, _c, _d, _e, _f, _g, _h, _i, _root, cache, fullPath, key, path, renderOptions, template, viewPath;
    key = [name, opts];
    cache = this._templateCache();
    renderOptions = {
      cache: cache,
      scope: context,
      locals: locals
    };
    if (cache[key]) {
      renderOptions.filename = cache[key];
      return Jade.render(null, renderOptions);
    } else {
      _b = this._roots().reverse();
      for (_a = 0, _c = _b.length; _a < _c; _a++) {
        _root = _b[_a];
        _e = this._paths().views.reverse();
        for (_d = 0, _f = _e.length; _d < _f; _d++) {
          viewPath = _e[_d];
          _h = this.templateNames(name, opts);
          for (_g = 0, _i = _h.length; _g < _i; _g++) {
            path = _h[_g];
            try {
              fullPath = Path.join(_root, viewPath, ("" + (path) + ".jade"));
              template = fs.readFileSync(fullPath).toString('utf8');
              cache[key] = fullPath;
              renderOptions.filename = fullPath;
              return Jade.render(template, renderOptions);
            } catch (e) {
              if (!e.message.match(noFileRegexp)) {
                throw e;
              }
            }
            if (cache[key]) {
              break;
            }
          }
        }
        if (cache[key]) {
          break;
        }
      }
    }
    throw new Error(("Template not found " + (name)));
  };
  module.exports = function(obj) {
    var constructor, contructor, proto;
    if (typeof obj === 'function') {
      proto = obj.prototype;
      contructor = obj;
    } else {
      proto = obj.__proto__;
      constructor = obj.constructor;
    }
    proto.templateNames = templateNames;
    proto.renderTemplate = renderTemplate;
    proto._roots = function() {
      var _a;
      return this.roots = (typeof (_a = this.roots) !== "undefined" && _a !== null) ? this.roots : [];
    };
    proto._templateCache = function() {
      var _a;
      return this.templateCache = (typeof (_a = this.templateCache) !== "undefined" && _a !== null) ? this.templateCache : {};
    };
    proto._format = function() {
      var _a;
      return this.format = (typeof (_a = this.format) !== "undefined" && _a !== null) ? this.format : 'html';
    };
    proto._paths = function() {
      var _a;
      return this.paths = (typeof (_a = this.paths) !== "undefined" && _a !== null) ? this.paths : {
        views: []
      };
    };
    return proto._paths;
  };
})();
