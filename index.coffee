app = require('express')()
stylus = require('stylus').middleware

app.set 'views', "#{__dirname}/views"
app.set 'view engine', 'jade'
app.use stylus
  src: "#{__dirname}/public"

app.get '/', (req, res)-> res.render 'index'

app.listen process.env.PORT || 3000
