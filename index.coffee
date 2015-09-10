express = require 'express'
bodyParser = require 'body-parser'
cors = require 'cors'

app = express()

app.use(cors(
  origin: (origin, callback) ->
    if origin
      allow = origin.match(/\.kosendj-bu\.in\//) != null
      if app.get('env') == "development"
        allow = allow || origin.match(/localhost/) != null

      callback(null, allow)
    else
      callback(null, false)
))

http = require('http').Server app
io = require('socket.io')(http)

redis   = require 'redis'

redis_url = process.env.REDIS_URL or process.env.REDISTOGO_URL or process.env.REDISCLOUD_URL
unless redis_url
  console.log '$REDIS_URL, $REDISTOGO_URL, $REDISCLOUD_URL not specified; falling back to redis://localhost:6379'
  redis_url = 'redis://localhost:6379'

process.globals = {}
rtg = require('url').parse redis_url
process.globals.redis = redis.createClient rtg.port, rtg.hostname
if rtg.auth
  process.globals.redis.auth rtg.auth.split(':')[1]

process.globals.io = io

app.set 'views', "#{__dirname}/views"
app.set 'view engine', 'jade'
app.use bodyParser.urlencoded({extended: true})
app.use express.static("#{__dirname}/build")

app.get '/', (req, res)-> res.render 'index'
app.get '/gifs', require('./lib/gif').index
app.post '/gifs', require('./lib/gif').add
app.get '/gifs/queue', require('./lib/queue').index
unless process.env.CAMO_URL
  app.get /^\/gifs\/retrieve\/(.+)$/, require('./lib/gif').retrieve
app.get '/screen', (req, res)-> res.render 'screen'
app.get '/bpm', require('./lib/bpm').get
app.get '/usage', (req, res)-> res.render 'usage'
app.post '/name', require('./lib/screen').name

io.on 'connection', require './lib/socket'
require './lib/twitter'

port = if process.env.PORT
         parseInt(process.env.PORT, 10)
       else
         3000
http.listen port, -> console.log "Listening at port #{port}"
