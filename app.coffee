express           = require 'express'
path              = require 'path'
favicon           = require 'serve-favicon'
logger            = require 'morgan'
bodyParser        = require 'body-parser'
mongoose          = require 'mongoose'
session           = require 'express-session'
sessionStorage    = (require 'connect-mongo')(session)
uuid              = require 'node-uuid'
flash             = require 'flash'
fs                = require 'fs'
http              = require 'http'
recur_readdir_sync= require 'recursive-readdir-sync'
_                 = require 'lodash'
sanitizer         = require 'mongo-sanitize'


config            = require './config'

app               = express();
server            = http.createServer app



app.set 'x-powered-by', false # sowwy, i don't like telling everything what am i using on server

# view engine setup

app.set 'views', [path.join(__dirname, 'views')]
app.set 'view engine', 'jade'

app.locals.config = config

console.log "Establishing database connection to #{config.dbURI}"

mongoose.connect config.dbURI

models_path   = __dirname + '/models'
routes_path   = __dirname + '/routes'
console.log "Bootstrapping models..."
(recur_readdir_sync models_path).forEach (file) ->
  console.log "Bootstrapping #{ file }"
  require file

# node.js will be running after nginx on production, so we need to trust it
if config.env == 'production'
# FIXME: do we really need this for i am using custom middleware with config?
  app.set 'trust proxy', 'loopback'


sessionMiddleware = session {
  genid: (req) ->
    uuid.v4()
  store: new sessionStorage { mongooseConnection: mongoose.connection }
  name: config.session.name
  secret: config.session.key      # FIXME: place something secure in production.json. "correct horse battery staple" is not the best password
  unset: 'destroy'                # Default behaviour is keeping the session, but ignoring the changes$
  resave: false                   # true is default, but true is also deprecated. hmmmm
  cookie: {
    secure: config.env == 'production'
  }
  saveUninitialized: false        # reduces storage usage
}

app.use logger('dev')
app.use bodyParser.json()
app.use bodyParser.urlencoded({ extended: false })

app.use (req, res, next) ->
  ip = req.ips[req.ips.length - 1] || req.connection.remoteAddress
  req.realIp = ip.split(':')[0]
  next()


app.use sessionMiddleware

app.use flash()


# serve all static on public as /<filename>
app.use '/static', express.static(path.join(__dirname, 'static/dist/'))

app.use '/upload', express.static(path.join(__dirname, 'upload/'))

# server bower dependencies as /libraries/<filename>
# TODO: maybe let it be bower_components?
app.use '/libraries', express.static(__dirname + '/bower_components')


sanitizeObject = (obj) ->
  for key in obj
    if obj.hasOwnProperty(key)
      if typeof obj[key] == "object"
        obj[key] = sanitizeObject(obj[key])
      else if typeof obj[key] == "array"
        arr = obj[key]
        newarr = []
        for element in arr
          newarr.push sanitizer(element)
        obj[key] = newarr
      else
        obj[key] = sanitizer obj[key]
  obj

# Automatically sanitize all mongo fields

app.use (req, res, next) ->
  params = req.params
  body = req.body
  req.params = sanitizeObject params
  req.body = sanitizeObject body
  next()


app.use (req, res, next) ->
  res.locals.session = req.sesssion
  res.locals.req = req
  next()


console.log 'Bootstrapping routes...'
(recur_readdir_sync routes_path).forEach (file) ->
  console.log "Bootstrapping #{ file }"
  temp_route = require file
  app.use temp_route.bootstrap_path, temp_route



# catch 404 and forward to error handler
app.use (req, res, next) ->
  err = new Error('Ничего не найдено');
  err.status = 404;
  next err

# error handlers

app.use (err, req, res, next) ->
  res.status err.status || 500
  res.render 'service/error', {
    message: err.message
    status: err.status || 500
    error: err
  }


# Normalize a port into a number, string, or false.
normalizePort = (val) ->
  port = parseInt val, 10

  # named pipe
  if isNaN port
    val
# port number
  else if port >= 0
    port
  false

# Event listener for HTTP server "error" event.
onError = (error) ->
  if error.syscall isnt 'listen'
    throw error

  bind = if typeof port is 'string' then "Pipe #{port}" else "Port #{port}"

  # handle specific listen errors with friendly messages
  switch error.code
    when 'EACCES'
      console.error "#{bind} requires elevated privileges"
      process.exit 1
    when 'EADDRINUSE'
      console.error "#{bind} is already in use"
      process.exit 1
    else
      throw error

# Event listener for HTTP server "listening" event.
onListening = ->
  addr = server.address()
  bind = if typeof addr is 'string' then "pipe #{addr}" else "port #{addr.port}"
  console.log "Listening on #{bind}"

# Get port from environment and store in Express.
port = normalizePort(process.env.PORT) or config.bind or '3000'
app.set 'port', port

console.log 'App created on port ' + port
# Listen on provided port, on all network interfaces.
server.listen port
server.on 'error', onError
server.on 'listening', onListening


module.exports = app