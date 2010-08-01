# N
## N
### N

N is yet another framework for Node.js using the [Connect](http://extjs.github.com/Connect/) middleware system.

N is built to help me make applications and borrows heavily from my work in the Ruby ecosystem.

N currently has the following features:

* MVC (only the V and C portions are supplied)
* Controllers
* Views using [Jade](http://github.com/visionmedia/jade)
* Moutable Routing using [Sherpa](http://github.com/joshbuddy/sherpa)
* Central layout system for all downstream connect middleware / applications

## Request Flow

Assuming the following setup:

<pre><code>
Connect: require('connect')
N: require '../../index'

# Declare Mount controllers
N.mountController require('./app/posts'), "/posts"

# Setup the server instance
# N.connect() provides the default N middlewares
# including sessions, cookies, and wrapt (A layouter)
server: Connect.createServer  Connect.logger(), N.connect()

server.listen 8080
</code></pre>

The 'posts' controller is mounted inside N.

N is then setup in the Connect server.

A request for '/posts' would see the following

* -> Request
* -> Connect.logger()
* -> N Stack - The N level Connect middleware stack
* -> N Router - The N level router.  Any Node/Connect app can be mounted here
* -> Route to the 'posts' controller
* -> Posts controller can choose how to route.

## MVC

N provides the View and Controller part of the MVC equation.  It provides a simple controller which operates on HTTP verbs via a controller level Sherpa router.

## Controller

Controllers in N are small packages of (almost) self contained application goodness.  An N controller is an application in it's own right.  A controller has the following features:

* Individual Connect Middleware Stack
* Individual Sherpa router instance
* Rendering
* Layout aware
* Controller level View Contexts.  (Allows for per controller view helpers)
* Mime type aware
* Sync and ASync usages
* Multi-Root view lookups
* Cascading template names (index.development.html.jade, index.html.jade, index.jade)


<pre><code>
# In Coffeescript
N: require('../../../index')

posts: new N.Controller('posts')

posts.GET "/", {}, (routeParams) ->
  @render_and_respond 'index'

posts.GET "/:id", {}, (params) ->
  self: this
  @data.food: @queryParams.food || "food"
  @render 'show', (err, content) ->
    if err
      self.next(err)
    else
      self.respond content

module.exports: posts
</code></pre>

## Mountable Routing

N uses the [Sherpa](http://github.com/joshbuddy/sherpa) router, and has the ability (from sherpa) to mount any node or connect application.

N has a router, and each controller also has a router instance.  You can mount applications either inside N, or inside a controller

## Views & Layouts

Views are provided by the [Jade](http://github.com/visionmedia/jade) templating system.  Each view template can be used by calling render in the controller.

Layouts are provided in N by an instance attached to the request.  For example:

<pre><code>
  // Something downstream from N
  function(req, resp){
    var layout = req.layout;
    layout.content.main = "Here's the main content";
    layout.content.side = "Here's some side content";

    layout.templateName = 'application'; // Not required. This is default.
    layout.format = "html";              // Not Required. This is default.

    resp.writeHead 200, {'content-type': 'text/html'}
    resp.end layout.layout() // wraps the content in the 'application' layout
  }
</code></pre>

To render in a controller without a layout, pass the layout: false option.

<pre><code>
  posts.GET "/", {}, (params) ->
    @render_and_respond "index", {layout: false}

### Mixins

The View and Wrapt (layout) functions allow you to provide mixins that will be mixed into the prototypes or each (seperately)

<pre><code>
var N = require('N');

N.Controller.mixin(helper1, helper2);
N.Controller.ViewContext.mixin(helper1, helper2);
N.Wrapt.ViewContext.mixin(helper1)

</code></pre>

This will mixin any methods / data into the view context atthe prototype level.

In coffeescript, you can extend from a ViewContext.  This can be done to provide a controller with it's own set of helpers.

<pre><code>
posts: new N.Controller('posts')

class PostsViewContext extends posts.ViewContext
  @mixin: posts.ViewContext.mixin # must copy this over since there is no class inheritance

PostsViewContext.mixin specialHelper

posts.ViewContext: PostsViewContext
</code></pre>

By doing this, you are able to have different mixins, inheriting into different controllers, or for the layout.



