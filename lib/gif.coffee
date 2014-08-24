request = require 'request'

exports.index = (req, res)->
  if req.query.page?
    page = req.query.page
  else
    page = 0
  process.globals.redis.lrange 'gifs', page, page + 10, (err, reply)-> res.json reply

exports.retrieve = (req, res)->
  request
    url: req.query.url
    encoding: null
  , (err, r, body)-> res.send body
