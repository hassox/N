sys:     require('sys')
Connect: require('connect')
N: require '../../index'

n1: new N()
n2: new N()

# Declare Mount controllers
n1.mount require('./app/posts'), "/posts"
n2.mount require('./app/posts'), '/cookies'

n1.root.GET "/hi", {}, (params) ->
  @respond "Hi From The root"

n1.root.GET "/", {}, ()->
  @respond "Roots Root"
# Setup the server instance
# n.connect() provides the default N middlewares
# including sessions, cookies, and wrapt (A layouter)
server: Connect.createServer  Connect.logger(), n1.connect()
server.listen 8080

server2: Connect.createServer  Connect.logger(), n2.connect()
server2.listen 8081
