express = require 'express'
bodyParser = require 'body-parser'
stylus = require('stylus').middleware
coffee = require 'coffee-middleware'
app = express()

http = require('http').Server app
io = require('socket.io')(http)

redis   = require 'redis'

if process.env.REDISTOGO_URL
  process.globals = {}
  rtg = require('url').parse process.env.REDISTOGO_URL
  process.globals.redis = redis.createClient rtg.port, rtg.hostname
  process.globals.redis.auth rtg.auth.split(':')[1]
else
  console.log 'Redis to go not found'
  process.exit 1

app.set 'views', "#{__dirname}/views"
app.set 'view engine', 'jade'
app.use bodyParser.urlencoded({extended: true})
app.use coffee
  src: "#{__dirname}/public"
app.use stylus
  src: "#{__dirname}/public"
app.use express.static("#{__dirname}/public")

app.get  '/', (req, res)-> res.render 'index'
app.post '/upload', require './lib/upload'
app.get  '/gifs', require('./lib/gif').index
app.get  '/gifs/queue', require('./lib/queue').index
app.get  '/gifs/retrieve', require('./lib/gif').retrieve
app.get  '/screen', (req, res)-> res.render 'screen'

io.on 'connection', require './lib/socket'

http.listen process.env.PORT || 3000
