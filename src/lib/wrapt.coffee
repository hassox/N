Connect:      require 'connect'
ConnectUtils: require 'connect/utils'
Jade:         require 'jade'
RenderMixin:  require './render'
ViewContext:  require './viewContext'
sys:          require 'sys'

class WraptContext extends ViewContext
  @mixin: ViewContext.mixin

  constructor: (req, opts) ->
    super(req,opts)
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
    @request.format || @defaultFormat

  viewContext: (opts) ->
    opts ?= {}
    opts.format: @format()
    new WraptContext(@request, opts)

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
    @roots.unshift __dirname

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

module.exports = Wrapt
