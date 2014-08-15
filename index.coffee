app = require('express')()

app.get '/', (req, res)->
  res.send 'it works'

app.listen process.env.PORT || 3000
