Connect:      require 'connect'
ConnectUtils: require 'connect/utils'
Jade:         require 'jade'
Path:         require 'path'
fs:           require 'fs'
sys:          require 'sys'

noFileRegexp: /No such file or directory/i

# this.templateNames(name, opts) -> for a given name and options object, provide all available template names to search for.
#     @example:
#       this.templateNames('index', {format: 'xml'})
#         -> ['index.xml.development.jade', 'index.xml.jade', 'index.jade']
#
templateNames: (name, opts) ->
  opts ?= {}
  fmt: opts.format || @_format()
  [
    "${name}.${fmt}.${process.connectEnv.name}"
    "${name}.${fmt}"
    name
  ]

#   this.renderTemplate(name, opts, context, locals)
#     ->  This will render the template syncronously.
#         The hit for sync access is only felt once, when the template is first loaded.  After this, the cached version will be hit.
#
#     @param name - the template name
#     @param opts - the render options
#     @param context - an object to execute the template for
#     @param locals - the local variables to use inside the template
renderTemplate: (name, opts, context, locals) ->
  key: [name, opts]
  cache: @_templateCache()
  renderOptions: {
    cache: cache
    scope: context
    locals: locals
  }

  if cache[key]
    renderOptions.filename: cache[key]
    return Jade.render(null, renderOptions)
  else
    for _root in @_roots().reverse()
      for viewPath in @_paths().views.reverse()
        for path in @templateNames(name, opts)
          try
            fullPath: Path.join(_root, viewPath, "${path}.jade")
            template: fs.readFileSync(fullPath).toString('utf8')
            cache[key]: fullPath
            renderOptions.filename: fullPath
            return Jade.render(template, renderOptions)
          catch e
            if not e.message.match noFileRegexp
              throw e
          break if cache[key]
      break if cache[key]
  throw new Error("Template not found ${name}")

# A rendering mixin.
# The mixin provides support for jade only
#
# To customise the renderer, you can provide it:
#   this.roots -> a list of directories to look for templates in
#   this.templateCache  -> an object used to cache templates from disk
#   this.format         -> the default format of the renderer
#   this.paths          -> An object of relative paths that should be searched for the templateName.  The this.paths.views should be an array of relative paths in order of precedence
#
module.exports: (obj) ->
  if typeof obj == 'function'
    proto: obj.prototype
    contructor: obj
  else
    proto: obj.__proto__
    constructor: obj.constructor

  proto.templateNames:  templateNames
  proto.renderTemplate: renderTemplate

  proto._roots: () ->
    @roots ?= []

  proto._templateCache: () ->
    @templateCache ?= {}

  proto._format: () ->
    @format ?= 'html'

  proto._paths: () ->
    @paths ?= { views: []}

