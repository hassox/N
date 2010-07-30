sys: require('sys')
N: require('../../../index')

posts: new N.Controller('posts')

posts.GET "/", {}, (params) ->
  @render_and_respond 'index'

posts.GET "/:id", {}, (params) ->
  @data.food: @queryParams.food || "food"
  @render_and_respond 'show'

module.exports: posts
