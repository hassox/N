Connect:      require 'connect'
ConnectUtils: require 'connect/utils'
Jade:         require 'jade'
RenderMixin:  require './render'
ViewContext:  require './viewContext'
sys:          require 'sys'

# A 'subclass' of the View Context specifically for
# rendering a layout
class WraptContext extends ViewContext
  @mixin: ViewContext.mixin

  constructor: (req, opts) ->
    super(req,opts)
    @content: req.layout.content

# The Layotuer is injected into the request object and may be used to
# generate layouts
#
# @example
#   layout: request.layout
#
#   layout.content.main = "Some content that should be layed out"
#   layout.content.sidebar = "Some sidebar content"
#   response.end( layout.layout() )
#
# @example Setting a default format
#   request.layout.format = "xml"
#   request.layout.content.main = "Some main content"
#   response.end( layout.layout() )
#
# @example Set a different template name
#   request.layout.templateName = "public"
#   request.layout.content.main ......
#
class Layouter
  constructor: (req, resp, wrapt) ->
    @content:             {}
    @wrapt:               wrapt
    @roots:               wrapt.roots
    @templateDirs:        wrapt.templateDirs
    @defaultFormat:       wrapt.defaultFormat
    @request:             req
    @response:            resp
    @templateName:        wrapt.defaultTemplateName
    @preventLayoutParam:  wrapt.preventLayoutParam

  # Get the currently set format for this layouter
  format: () ->
    @request.format || @defaultFormat

  # Get a hold of a view context for this layouter
  viewContext: (opts) ->
    opts ?= {}
    opts.format: @format()
    new WraptContext(@request, opts)

  # Render the layout Don't use directly
  render: (opts) ->
    opts.format ?= @format()
    opts.scope  ?= @viewContext opts
    scope:  opts.scope
    locals: opts.locals

    delete opts.scope
    delete opts.locals

    try
      @wrapt.renderTemplate  @templateName, opts, scope, locals
    catch e
      @content.main

  # Lay out the currently defined content in the layouter
  # with the given format, and template name
  layout: (opts) ->
    opts ?= {}
    if opts.templateName?
      templateName: opts.templateName
      delete opts.templateName
    else
      templateName: @templateName

    opts.locals ?= {}
    opts.scope  ?= @viewContext opts
    scope:  opts.scope
    locals: opts.locals

    delete opts.scope
    delete opts.locals

    ConnectUtils.merge locals, {content: @content}

    try
      @wrapt.renderTemplate templateName, opts, scope, locals
    catch e
      @content.main

# Use in a Connect stack to provide layouts to all downstream
# applications.  Applications can then share layouts and have them
# consistent across the application
#
# @example
#   wrapt = new Wrapt({roots: [__dirname]})
#   server.use("/", wrapt.connect())
#
# @options
#   roots       - the root directories to find tempaltes in
#   paths.views - array of relative directories to search for template files
#   defaultTemplateName - The default template name.  Default 'application'
class Wrapt
  constructor: (opts) ->
    opts ?= {}
    self: this
    Wrapt.instances[opts.name || this]: this
    @roots: opts.roots || (() ->
      roots: []
      Wrapt.roots.forEach (root) ->
        roots.push root
      roots
    )()

    @paths: opts.paths || { views: ['app/views/layouts', 'views/layouts'] }
    @defaultFormat:       opts.defaultFormat || 'html'
    @defaultTemplateName: opts.defaultTemplateName || 'application'
    @preventLayoutParam:  opts.preventLayoutParam || '__layout'
    @templateCache:       {}

  connect: (opts) ->
    self: this
    opts ?= {}
    for option, value of opts
      this[option]: value

    (req, resp, next) ->
      req.layout: new Layouter(req, resp, self)
      next()

RenderMixin Wrapt

Wrapt.instances: {}
Wrapt.roots: ["${process.cwd}"]

Wrapt.ViewContext = WraptContext
module.exports = Wrapt
