async   = require 'async'
request = require 'request'
{Magic} = require 'mmmagic'

exports.index = (req, res)->
  if req.query.page?
    page = (req.query.page * -10) - 1
  else
    page = -1
  process.globals.redis.lrange 'gifs', page - 9, page, (err, reply)-> res.json reply

exports.retrieve = (req, res)->
  request
    url: req.query.url
    encoding: null
  , (err, r, body)-> res.send body

exports.check = (url, callback)->
  async.waterfall [
    (cb)->
      request
        url: url
        encoding: null
      , (err, res, body)-> cb err, body

    (body, cb)->
      magic = new Magic()
      magic.detect body, (err, mime)-> cb err, mime

    (mime, cb)->
      if mime?.match /^GIF/
        cb null, true
      else
        cb null, false
  ], (err, res)-> callback err, res
