Connect: require('connect')
N: require '../../index'

N.mountController require('./app/posts'), "/posts"

server: Connect.createServer  Connect.logger(), N.connect()
server.use "/bar", require('./app/posts').connect()

server.listen 8080
