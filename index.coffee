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

process.globals.io = io

app.set 'views', "#{__dirname}/views"
app.set 'view engine', 'jade'
app.use bodyParser.urlencoded({extended: true})
app.use coffee
  src: "#{__dirname}/public"
app.use stylus
  src: "#{__dirname}/public"
app.use express.static("#{__dirname}/public")

app.get '/', (req, res)-> res.render 'index'
app.get '/gifs', require('./lib/gif').index
app.get '/gifs/queue', require('./lib/queue').index
app.get '/gifs/retrieve', require('./lib/gif').retrieve
app.get '/screen', (req, res)-> res.render 'screen'
app.get '/bpm', require('./lib/bpm').get
app.get '/usage', (req, res)-> res.render 'usage'

io.on 'connection', require './lib/socket'

port = if process.env.PORT
         parseInt(process.env.PORT, 10)
       else
         3000
console.log("Listening at port #{port}")
http.listen port
