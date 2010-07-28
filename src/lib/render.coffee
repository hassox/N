Connect:      require 'connect'
ConnectUtils: require 'connect/utils'
Jade:         require 'jade'
Path:         require 'path'
fs:           require 'fs'
sys:          require 'sys'

templateNames: (name, opts) ->
  opts ?= {}
  fmt: opts.format || @_format()
  [
    "${name}.${fmt}.${process.connectEnv.name}"
    "${name}.${fmt}"
    name
  ]

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
            # TODO: Add some logging and or re-raise at this point if it's a
            # file not found
            sys.puts e.message
            "noop"
          break if cache[key]
      break if cache[key]
  throw new Error("Template not found ${name}")

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
    @paths ?= []

