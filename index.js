(function(){
  var Connect, fs, posts, server, sys;
  Connect = require('connect');
  sys = require('sys');
  fs = require('fs');
  posts = require('./app/posts');
  server = Connect.createServer(Connect.logger());
  server.use("/posts", posts.connector);
  server.use("/", Connect.errorHandler({
    dumpExceptions: false
  }));
  server.listen(8080);
})();
