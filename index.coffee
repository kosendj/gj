express = require 'express'
stylus = require('stylus').middleware
coffee = require 'coffee-middleware'
app = express()

app.set 'views', "#{__dirname}/views"
app.set 'view engine', 'jade'
app.use coffee
  src: "#{__dirname}/public"
app.use stylus
  src: "#{__dirname}/public"
app.use express.static("#{__dirname}/public")

app.get '/', (req, res)-> res.render 'index'

app.listen process.env.PORT || 3000
