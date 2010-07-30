sys: require('sys')
N: require('../../../index')
Controller: N.Controller

#### Actual Usage
posts: new Controller('posts')

posts.GET "/", {}, (params) ->
  @render_and_respond 'index'

posts.GET "/wrapt_test", {}, (params) ->
  @request.layout.content.main = "Hi There"
  @respond @request.layout.layout()

posts.GET "/:id", {}, (params) ->
  @data.food: "Different types of food!"
  @render_and_respond 'show'

module.exports: posts
