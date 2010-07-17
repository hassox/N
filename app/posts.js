(function(){
  var Controller, N, posts, sys;
  sys = require('sys');
  N = require('../lib/n');
  Controller = N.Controller;
  posts = new Controller('posts');
  posts.GET("/", {}, function(params) {
    sys.puts("IN INDEX");
    return this.render_and_respond("index");
  });
  posts.GET("/:id", {}, function(params) {
    this.data.food = "Banana";
    return this.render_and_respond("show");
  });
  module.exports = posts;
})();
