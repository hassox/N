sys: require('sys')
N: require('../../../index')
Controller: N.Controller

#### Actual Usage
posts: new Controller('posts')

posts.GET "/", {}, (params) ->
  sys.puts("IN INDEX")
  @render_and_respond "index"

posts.GET "/:id", {}, (params) ->
  @data.food: "Banana"
  @render_and_respond "show"

module.exports: posts
