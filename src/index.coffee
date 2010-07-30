Connect:      require 'connect'
Controller:   require('./lib/controller').Controller
Handler:      require('./lib/controller').Handler
Wrapt:        require('./lib/wrapt')
sys: require 'sys'

N: {}
N.Controller: Controller
N.Handler:    Handler
N.Wrapt:      Wrapt

N.primeStack: []
N.stackInstance: {}
N.router: new Sherpa.Connect()

N.use: (name, instance, path) ->
  @primeStack.push name
  @stackInstance[name] = {'instance': instance, 'path': path}

N.connect: () ->
  server: Connect.createServer()

  for name in @primeStack
    item: @stackInstance[name]
    server.use(item.path || "/", item.instance)

  server.use "/", @router.connect()
  server

N.mount: (app, path, opts) ->
  @router.ANY(path,opts).matchPartially().to(app)

N.mountController: (app, path, opts) ->
  @mount(app.connect(), path, opts);

# A default stack
N.use N.Wrapt, new N.Wrapt().connect({roots:[process.cwd()]})

module.exports: N

