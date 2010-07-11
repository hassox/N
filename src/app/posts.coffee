Connect: require 'connect'
ConnectUtils: require 'connect/utils'
Jade: require 'jade'
Path: require 'path'
sys: require 'sys'
fs: require 'fs'

class Handler
  constructor: (req, resp, params, controller) ->
    @request: req
    @response: resp
    @params: params
    @controller: controller
    @status: 200
    @headers: {'Content-Type': 'text/plain'}
    @data: {}

  content_type: (type) ->
    @headers['Content-Type']: type

  format: () ->
    @request.format || "html"

  render: (name, opts, fn) ->
    opts ?= {}
    opts.format ?= @format()

    path: @controller.templatePathFor name, opts
    opts.scope: this
    if path
      out: Jade.renderFile path, opts, fn
    else
      fn new Error("Template '${name}' not found")

  respond: (content, opts) ->
    opts ?= {}
    @status: opts.status || @status

    ConnectUtils.merge(@headers, opts.headers || {})

    @response.writeHead @status, @headers
    @response.write content
    @response.end()

  render_and_respond: (name, opts) ->
    self: this
    @render name, opts, (err, content) ->
      if err
        next(err)
      else
        self.respond content

  redirect: (url, status) ->
    status ?= 302
    @headers['Location'] = url
    @status: status
    @respond "Redirecting to ${url}"

class Controller
  constructor: (name, opts) ->
    opts ?= {}
    throw new Error("Controller Name Not Given") unless name
    @name: name
    @options: opts
    @stack: Connect.createServer()

    rtr: undefined
    @connector: Connect.createServer(
      @stack
      Connect.router (r) ->
        rtr = r
    )

    @router: rtr

    @Handler: opts.Handler || Handler
    @templateCache: {}
    @roots: opts.roots || [process.cwd()]
    @paths: opts.paths || {
      views: [
        "views"
        "views/${name}"
        "app/views"
        "app/views/${name}"
      ]
    }

  use: (args...) ->
    @stack.use(args...)

  get : (route, fn) -> @handleRoute('get'  , route, fn)
  post: (route, fn) -> @handleRoute('post' , route, fn)
  put : (route, fn) -> @handleRoute('put'  , route, fn)
  del : (route, fn) -> @handleRoute('del'  , route, fn)

  handleRoute: (meth, route, fn) ->
    self: this
    dispatcher: (req, resp, params) ->
      handler: new Handler(req, resp, params, self)
      out: fn.call(handler)

    @router[meth](route, dispatcher)

  templateNames: (name, opts) ->
    opts ?= {}
    fmt: opts.format || 'html'
    [
      "${name}.${fmt}.${process.connectEnv.name}"
      "${name}.${fmt}"
      name
    ]

  templatePathFor: (name, opts) ->
    possible: @templateNames name, opts
    existing: @templateCache[possible]
    return existing if existing

    for _root in @roots.reverse()
      for viewPath in @paths.views.reverse()
        for path in possible
          try
            fullPath: Path.join(_root, viewPath, "${path}.jade")
            template: fs.statSync fullPath
            @templateCache[possible]: fullPath
            break
          catch e
            "noop"
          break if @templateCache[possible]
      break if @templateCache[possible]
    @templateCache[possible]

#### Actual Usage
posts: new Controller('posts')

posts.get "/", () ->
  @render_and_respond "index"

posts.get "/:id", () ->
  @data.food: "Banana"
  @render_and_respond "show"

module.exports: posts
