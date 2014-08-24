request = require 'request'

exports.index = (req, res)->
  process.globals.redis.lrange 'gifs', 0, 10, (err, reply)-> res.json reply

exports.retrieve = (req, res)->
  request
    url: req.query.url
    encoding: null
  , (err, r, body)-> res.send body
