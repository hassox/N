Connect: require 'connect'
ConnectUtils: require 'connect/utils'
Jade: require 'jade'
Path: require 'path'
Sherpa: require 'sherpa/connect'
sys: require 'sys'
fs: require 'fs'
startsWithAPeriod: /^\./

# HEADER CONSTANTS
CONTENT_TYPE: 'Content-Type'

class Handler
  constructor: (req, resp, params, controller, next) ->
    @request: req
    @response: resp
    @params: params
    @controller: controller
    @status: 200
    @headers: {}
    @data: {}
    @next: next

  content_type: (type) ->
    if type
      if not type.match(startsWithAPeriod)
        type: ".${type}"
    else
      type: ".${@format()}"

    @headers[CONTENT_TYPE] = ConnectUtils.mime.type(type)

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

    if not @headers[CONTENT_TYPE]
      @content_type(opts.format)

    @response.writeHead @status, @headers
    @response.write content
    @response.end()

  render_and_respond: (name, opts) ->
    self: this
    @render name, opts, (err, content) ->
      if err
        self.respond err.message, {status: 500}
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

    @router: new Sherpa.Connect()

    @connector: Connect.createServer(@stack, @router.connector())

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

  GET     : (route, opts, fn) -> @handleRoute('GET'  ,    route, opts, fn)
  POST    : (route, opts, fn) -> @handleRoute('POST' ,    route, opts, fn)
  PUT     : (route, opts, fn) -> @handleRoute('PUT'  ,    route, opts, fn)
  DELETE  : (route, otps, fn) -> @handleRoute('DELETE',   route, opts, fn)
  OPTIONS : (route, opts, fn) -> @handleRoute('OPTIONS',  route, opts, fn)
  HEAD    : (route, opts, fn) -> @handleRoute('HEAD',     route, opts, fn)
  ANY     : (route, opts, fn) -> @handleRoute('ANY',      route, opts, fn)

  handleRoute: (meth, route,  opts, fn) ->
    self: this
    dispatcher: (req, resp, next) ->
      params:   req.sherpaResponse.params
      handler:  new Handler(req, resp, params, self, next)
      out:      fn.call(handler, params)

    @router[meth](route,opts).to(dispatcher)

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

N: {}
module.exports: N
N.Controller: Controller
N.Handler: Handler
