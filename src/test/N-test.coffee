N:       require '../index'
vows:    require 'vows'
assert:  require 'assert'
sys:     require 'sys'
Connect: require 'connect'

middlewareFunction: (req, resp, next)->
  next()

nSuite: vows.describe('N Contructor')
nSuite.addBatch {
  'Stack': {
    'prime stack': {
      topic: N.primeStack
      'should be array': (topic) ->
        assert.isArray topic
    }
    'stack instance': {
      topic: N.stackInstance
      'should be an object': (topic) ->
        assert.isObject topic
    }
  }
}

nSuite.addBatch {
  'N Instance': {
    'name': {
      topic: new N('foo')
      'should have name foo': (topic) ->
        assert.equal topic.name, 'foo'
    }
    'root controller': {
      topic: new N('foo')
      'should have a root controller': (topic) ->
        assert.instanceOf topic.root, N.Controller
    }
    'prime stack': {
      topic: () ->
        n: new N('foo')
        n.use 'test', middlewareFunction
        n
      'should setup a test middleware': (topic) ->
        assert.include topic.primeStack, 'test'
    }
    'stack instance': {
      topic: () ->
        n: new N('foo')
        n.use 'test', middlewareFunction
        n
      'should setup the test middleware': (topic) ->
        assert.include topic.stackInstance, 'test'
        assert.equal topic.stackInstance.test.instance, middlewareFunction
    }
    'connect()': {
      topic: ()->
        n: new N('foo')
        { server: n.connect() } # can't pass an event emitter unless it's going to be a promise
      'should be a connect server': (topic) ->
        assert.instanceOf topic.server, Connect.Server
    }

    'mount(app, path, opts)': {
      topic: ()->
        (req, resp, next)->
          next()
      'mounting into the root controller': {
        topic: (app)->
          n: new N('foo')
          n.mount(app, '/foo')
          n.root
        'should have a route at /foo': (root)->
    }
  }
}

module.exports.nSuite: nSuite
