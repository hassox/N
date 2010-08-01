(function(){
  var N, posts, sys;
  sys = require('sys');
  N = require('../../../index');
  posts = new N.Controller('posts');
  posts.GET("/", {}, function(routeParams) {
    try {
      return this.render_and_respond('index');
    } catch (e) {
      sys.puts(e);
      throw e;
    }
  });
  posts.GET("/:id", {}, function(params) {
    this.data.food = this.queryParams.food || "food";
    return this.render_and_respond('show');
  });
  module.exports = posts;
})();
