express = require 'express'
bodyParser = require 'body-parser'
stylus = require('stylus').middleware
coffee = require 'coffee-middleware'
app = express()

app.set 'views', "#{__dirname}/views"
app.set 'view engine', 'jade'
app.use bodyParser.urlencoded({extended: true})
app.use coffee
  src: "#{__dirname}/public"
app.use stylus
  src: "#{__dirname}/public"
app.use express.static("#{__dirname}/public")

app.get '/', (req, res)-> res.render 'index'
app.post '/upload', (req, res)->
  console.log req
  res.send 'ok'

app.listen process.env.PORT || 3000
