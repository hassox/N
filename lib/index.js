(function(){
  var Connect, Controller, Handler, N, Wrapt, sys;
  Connect = require('connect');
  Controller = require('./N/controller').Controller;
  Handler = require('./N/controller').Handler;
  Wrapt = require('./N/wrapt');
  sys = require('sys');
  N = {};
  N.Controller = Controller;
  N.Handler = Handler;
  N.Wrapt = Wrapt;
  N.primeStack = [];
  N.stackInstance = {};
  N.router = new Sherpa.Connect();
  N.use = function(name, instance, path) {
    this.primeStack.push(name);
    this.stackInstance[name] = {
      'instance': instance,
      'path': path
    };
    return this.stackInstance[name];
  };
  N.connect = function() {
    var _a, _b, _c, item, name, server;
    server = Connect.createServer();
    _b = this.primeStack;
    for (_a = 0, _c = _b.length; _a < _c; _a++) {
      name = _b[_a];
      item = this.stackInstance[name];
      server.use(item.path || "/", item.instance);
    }
    server.use("/", this.router.connect());
    return server;
  };
  N.mount = function(app, path, opts) {
    return this.router.ANY(path, opts).matchPartially().to(app);
  };
  N.mountController = function(app, path, opts) {
    return this.mount(app.connect(), path, opts);
  };
  N.use(N.Wrapt, new N.Wrapt().connect({
    roots: [process.cwd()]
  }));
  module.exports = N;
})();
