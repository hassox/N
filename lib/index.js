(function(){
  var Connect, Controller, Handler, N, Wrapt, dupArray, dupObject, sys, use;
  var __hasProp = Object.prototype.hasOwnProperty;
  Connect = require('connect');
  Controller = require('./N/controller').Controller;
  Handler = require('./N/controller').Handler;
  Wrapt = require('./N/wrapt');
  sys = require('sys');
  dupArray = function(ary) {
    return ary.slice();
  };
  dupObject = function(obj) {
    var _a, dup, item, value;
    dup = {};
    _a = obj;
    for (item in _a) { if (__hasProp.call(_a, item)) {
      value = _a[item];
      dup[item] = value;
    }}
    return dup;
  };
  use = function(name, instance, path) {
    this.primeStack.push(name);
    this.stackInstance[name] = {
      'instance': instance,
      'path': path
    };
    return this.stackInstance[name];
  };
  N = function(name) {
    this.name = name;
    this.root = new N.Controller('root');
    this.__defineGetter__('primeStack', function() {
      var _a;
      return this._primeStack = (typeof (_a = this._primeStack) !== "undefined" && _a !== null) ? this._primeStack : dupArray(N.primeStack);
    });
    this.__defineGetter__('stackInstance', function() {
      var _a;
      return this._stack_instance = (typeof (_a = this._stack_instance) !== "undefined" && _a !== null) ? this._stack_instance : dupObject(N.stackInstance);
    });
    return this;
  };
  N.Controller = Controller;
  N.Handler = Handler;
  N.Wrapt = Wrapt;
  N.primeStack = [];
  N.stackInstance = {};
  N.use = use;
  N.prototype.use = use;
  N.prototype.connect = function() {
    var _a, _b, _c, item, name, server;
    server = Connect.createServer();
    _b = this.primeStack;
    for (_a = 0, _c = _b.length; _a < _c; _a++) {
      name = _b[_a];
      item = this.stackInstance[name];
      server.use(item.path || "/", item.instance);
    }
    server.use("/", this.root.connect());
    return server;
  };
  N.prototype.mount = function(app, path, opts) {
    var route;
    route = this.root.ANY(path, opts).matchPartially();
    if (app.connect) {
      return route.to(app.connect());
    } else {
      return route.to(app);
    }
  };

  N.use(N.Wrapt, new N.Wrapt().connect({
    roots: [process.cwd()]
  }));
  N.use(Connect.methodOverride, new Connect.methodOverride());
  N.use(Connect.cookieDecoder, new Connect.cookieDecoder());
  N.use(Connect.format, new Connect.format());
  N.use(Connect.responseTime, new Connect.responseTime());
  module.exports = N;
})();
