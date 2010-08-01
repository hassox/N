sys: require('sys')
N: require('../../../index')

posts: new N.Controller('posts')

posts.GET "/", {}, (routeParams) ->
  try
    @render_and_respond 'index'
  catch e
    sys.puts e
    throw e

posts.GET "/:id", {}, (params) ->
  @data.food: @queryParams.food || "food"
  @render_and_respond 'show'

module.exports: posts
