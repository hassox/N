Connect:      require 'connect'
ConnectUtils: require 'connect/utils'
Jade:         require 'jade'
Path:         require 'path'
Sherpa:       require 'sherpa/connect'
RenderMixin:  require './render'
ViewContext:  require './viewContext'
url:          require 'url'

sys: require 'sys'
fs: require 'fs'
startsWithAPeriod: /^\./

# HEADER CONSTANTS
CONTENT_TYPE: 'Content-Type'

class ControllerViewContext extends ViewContext
  @mixin: ViewContext.mixin

class Handler
  constructor: (req, resp, params, controller, next) ->
    req.N ?= {}
    @request: req
    @response: resp
    @params: params
    @controller: controller
    @status: 200
    @headers: {}
    @data: {}
    @next: next

    if req.N.url and req.N.url.query
      @queryParams: req.N.url.query
    else
      req.N.url = url.parse req.url, true
      @queryParams: req.N.url.query

    @queryParams ?= {}

  content_type: (type) ->
    if type
      if not type.match(startsWithAPeriod)
        type: ".${type}"
    else
      type: ".${@format()}"

    @headers[CONTENT_TYPE] = ConnectUtils.mime.type(type)

  format: () ->
    @request.format || "html"

  render: (name, opts, callback) ->
    if not callback
      callback:    opts
      opts:  {}

    opts ?= {}
    opts.format ?= @format()
    layout:

    if opts.layout
      useLayout: true
      layout: opts.layout if not opts.layout == true
    else
      useLayout: false

    context: new @controller.constructor.ViewContext(@request, opts)
    locals:  {
      data:   @data
      params: @params
    }

    try
      if useLayout and @request.layout
        @request.layout.content.main = @controller.renderTemplate name, opts, context, locals
        @request.layout.templateName: layout if layout
        callback null, @request.layout.layout()
      else
        callback null, @controller.renderTemplate name, opts, context, locals
    catch err
      callback err


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
    opts ?= {}
    self: this
    opts.layout: true if opts.layout != false

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
    @name:    name
    @options: opts

    @stack: Connect.createServer()

    @router: new Sherpa.Connect()

    @connect: (opts) ->
      Connect.createServer(@stack, @router.connect(opts))

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
      handler:  new self.Handler(req, resp, params, self, next)
      out:      fn.call(handler, params)

    @router[meth](route,opts).to(dispatcher)

RenderMixin Controller
Controller.ViewContext: ControllerViewContext

module.exports.Controller = Controller
module.exports.Handler = Handler
