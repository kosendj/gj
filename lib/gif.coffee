request = require 'request'

exports.index = (req, res)->
  if req.query.page?
    page = (req.query.page * -10) - 1
  else
    page = -1
  console.log page, (page - 9)
  process.globals.redis.lrange 'gifs', page - 9, page, (err, reply)-> res.json reply

exports.retrieve = (req, res)->
  request
    url: req.query.url
    encoding: null
  , (err, r, body)-> res.send body
