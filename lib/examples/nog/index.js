(function(){
  var Connect, N, n1, n2, server, server2, sys;
  sys = require('sys');
  Connect = require('connect');
  N = require('../../index');
  n1 = new N();
  n2 = new N();
  n1.mount(require('./app/posts'), "/posts");
  n2.mount(require('./app/posts'), '/cookies');
  n1.root.GET("/hi", {}, function(params) {
    return this.respond("Hi From The root");
  });
  n1.root.GET("/", {}, function() {
    return this.respond("Roots Root");
  });
  server = Connect.createServer(Connect.logger(), n1.connect());
  server.listen(8080);
  server2 = Connect.createServer(Connect.logger(), n2.connect());
  server2.listen(8081);
})();
