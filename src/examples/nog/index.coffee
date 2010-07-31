Connect: require('connect')
N: require '../../index'

# Declare Mount controllers
N.mountController require('./app/posts'), "/posts"

# Setup the server instance
# N.connect() provides the default N middlewares
# including sessions, cookies, and wrapt (A layouter)
server: Connect.createServer  Connect.logger(), N.connect()

server.listen 8080
