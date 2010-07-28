Connect:  require 'connect'
sys:      require 'sys'
fs:       require 'fs'
Wrapt:    require '../../lib/wrapt'

posts: require './app/posts'
server: Connect.createServer Connect.logger()

server.use "/",   new Wrapt('nog').connect({roots:[__dirname]})
server.use "/nog", posts.connect()
#server.use "/", Connect.errorHandler({dumpExceptions: false})

server.listen 8080
