(function(){
  var Connect, ConnectUtils, Jade, Layouter, RenderMixin, ViewContext, Wrapt, WraptContext, sys;
  var __extends = function(child, parent) {
    var ctor = function(){ };
    ctor.prototype = parent.prototype;
    child.__superClass__ = parent.prototype;
    child.prototype = new ctor();
    child.prototype.constructor = child;
  }, __hasProp = Object.prototype.hasOwnProperty;
  Connect = require('connect');
  ConnectUtils = require('connect/utils');
  Jade = require('jade');
  RenderMixin = require('./render');
  ViewContext = require('./viewContext');
  sys = require('sys');
  WraptContext = function(req, opts) {
    WraptContext.__superClass__.constructor.call(this, req, opts);
    this.content = req.layout.content;
    return this;
  };
  __extends(WraptContext, ViewContext);
  WraptContext.mixin = ViewContext.mixin;

  Layouter = function(req, resp, wrapt) {
    this.content = {};
    this.wrapt = wrapt;
    this.roots = wrapt.roots;
    this.templateDirs = wrapt.templateDirs;
    this.defaultFormat = wrapt.defaultFormat;
    this.request = req;
    this.response = resp;
    this.templateName = wrapt.defaultTemplateName;
    this.preventLayoutParam = wrapt.preventLayoutParam;
    return this;
  };
  Layouter.prototype.format = function() {
    return this.request.format || this.defaultFormat;
  };
  Layouter.prototype.viewContext = function(opts) {
    opts = (typeof opts !== "undefined" && opts !== null) ? opts : {};
    opts.format = this.format();
    return new WraptContext(this.request, opts);
  };
  Layouter.prototype.render = function(opts) {
    var _a, _b, locals, scope;
    opts.format = (typeof (_a = opts.format) !== "undefined" && _a !== null) ? opts.format : this.format();
    opts.scope = (typeof (_b = opts.scope) !== "undefined" && _b !== null) ? opts.scope : this.viewContext(opts);
    scope = opts.scope;
    locals = opts.locals;
    delete opts.scope;
    delete opts.locals;
    try {
      return this.wrapt.renderTemplate(this.templateName, opts, scope, locals);
    } catch (e) {
      return this.content.main;
    }
  };
  Layouter.prototype.layout = function(opts) {
    var _a, _b, _c, locals, scope, templateName;
    opts = (typeof opts !== "undefined" && opts !== null) ? opts : {};
    if ((typeof (_a = opts.templateName) !== "undefined" && _a !== null)) {
      templateName = opts.templateName;
      delete opts.templateName;
    } else {
      templateName = this.templateName;
    }
    opts.locals = (typeof (_b = opts.locals) !== "undefined" && _b !== null) ? opts.locals : {};
    opts.scope = (typeof (_c = opts.scope) !== "undefined" && _c !== null) ? opts.scope : this.viewContext(opts);
    scope = opts.scope;
    locals = opts.locals;
    delete opts.scope;
    delete opts.locals;
    ConnectUtils.merge(locals, {
      content: this.content
    });
    try {
      return this.wrapt.renderTemplate(templateName, opts, scope, locals);
    } catch (e) {
      return this.content.main;
    }
  };

  Wrapt = function(opts) {
    var self;
    opts = (typeof opts !== "undefined" && opts !== null) ? opts : {};
    self = this;
    Wrapt.instances[opts.name || this] = this;
    this.roots = opts.roots || (function() {
      var roots;
      roots = [];
      Wrapt.roots.forEach(function(root) {
        return roots.push(root);
      });
      return roots;
    })();
    this.paths = opts.paths || {
      views: ['app/views/layouts', 'views/layouts']
    };
    this.defaultFormat = opts.defaultFormat || 'html';
    this.defaultTemplateName = opts.defaultTemplateName || 'application';
    this.preventLayoutParam = opts.preventLayoutParam || '__layout';
    this.templateCache = {};
    return this;
  };
  Wrapt.prototype.connect = function(opts) {
    var _a, option, self, value;
    self = this;
    opts = (typeof opts !== "undefined" && opts !== null) ? opts : {};
    _a = opts;
    for (option in _a) { if (__hasProp.call(_a, option)) {
      value = _a[option];
      this[option] = value;
    }}
    return function(req, resp, next) {
      req.layout = new Layouter(req, resp, self);
      return next();
    };
  };

  RenderMixin(Wrapt);
  Wrapt.instances = {};
  Wrapt.roots = [("" + (process.cwd))];
  WraptContext.mixin(require('./viewHelpers/wraptHelpers'));
  Wrapt.ViewContext = WraptContext;
  module.exports = Wrapt;
})();
