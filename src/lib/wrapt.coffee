Connect:      require 'connect'
ConnectUtils: require 'connect/utils'
Jade:         require 'jade'
RenderMixin:  require './render'
ViewContext:  require './viewContext'

class WraptContext extends ViewContext
  @mixin: ViewContext.mixin
  constructor: (req, opts) ->
    super(req, opts)
    @content: req.layout.content

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

  format: () ->
    req.format || @defaultFormat

  viewContext: (opts) ->
    opts ?= {}
    opts.format: @format()
    new WraptContext(@request, opts)

  render: (opts) ->
    opts.format ?= @format()
    opts.scope  ?= viewContext opts

    wrapt.renderTemplate  @templateName, opts
    wrapt.template        @templateName, opts

class Wrapt
  constructor: (opts) ->
    self: this
    Wrapt.instances[opts.name || this]: this
    @roots: opts.roots || (() ->
      roots: []
      Wrapt.roots.forEach (root) ->
        roots.push root
      roots
    )()
    @paths: opts.paths || { views: ['views', 'views/layouts'] }
    @defaultFormat:       opts.defaultFormat || 'html'
    @defaultTemplateName: opts.defaultTemplateName || 'application'
    @preventLayoutParam:  opts.preventLayoutParam || '__layout'
    @templateCache:       {}

  connect: (opts) ->
    opts ?= {}
    for option, value in ops
      this[option]: value

    (req, resp, next) ->
      req.layout: new Layout(req, resp, this)
      next()

RenderMixin Wrapt

Wrapt.instances: {}
Wrapt.roots: ["${process.cwd}"]

module.exports = Wrapt
