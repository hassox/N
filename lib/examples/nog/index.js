(function(){
  var Connect, N, server, sys;
  sys = require('sys');
  Connect = require('connect');
  N = require('../../index');
  N.mountController(require('./app/posts'), "/posts");
  server = Connect.createServer(Connect.logger(), N.connect());
  server.listen(8080);
})();
