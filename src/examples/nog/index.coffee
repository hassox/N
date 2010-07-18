Connect:  require 'connect'
sys:      require 'sys'
fs:       require 'fs'

posts: require './app/posts'
server: Connect.createServer Connect.logger()

server.use "/nog", posts.connect()
server.use "/", Connect.errorHandler({dumpExceptions: false})

server.listen 8080
