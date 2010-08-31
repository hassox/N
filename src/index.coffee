Connect:      require 'connect'
Controller:   require('./N/controller').Controller
Handler:      require('./N/controller').Handler
Wrapt:        require('./N/wrapt')
sys: require 'sys'

dupArray: (ary)->
  ary.slice()

dupObject: (obj)->
  dup: {}
  for item,value of obj
    dup[item] = value
  dup

use: (name, instance, path) ->
  @primeStack.push name
  @stackInstance[name]: { 'instance': instance, 'path': path }

class N
  @Controller:    Controller
  @Handler:       Handler
  @Wrapt:         Wrapt
  @primeStack:    []
  @stackInstance: {}
  @use:           use

  constructor: (name) ->
    @name:            name
    @root:            new N.Controller('root')
    @__defineGetter__ 'primeStack', ()->
      @_primeStack ?= dupArray N.primeStack

    @__defineGetter__ 'stackInstance', ()->
      @_stackInstance ?= dupObject N.stackInstance

  use: use

  connect: () ->
    server: Connect.createServer()

    for name in @primeStack
      item: @stackInstance[name]
      server.use(item.path || "/", item.instance)

    server.use "/", @root.connect()
    server

  mount: (app, path, opts) ->
    route: @root.ANY(path,opts).matchPartially()
    if app.connect
      route.to(app.connect())
    else
      route.to(app)

# A default stack
N.use N.Wrapt,                new N.Wrapt().connect({roots:[process.cwd()]})
N.use Connect.methodOverride, new Connect.methodOverride()
N.use Connect.cookieDecoder,  new Connect.cookieDecoder()
N.use Connect.format,         new Connect.format()
N.use Connect.responseTime,   new Connect.responseTime()

module.exports: N

