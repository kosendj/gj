async   = require 'async'
request = require 'request'
{Magic} = require 'mmmagic'
{add}   = require './queue'

module.exports = (req, res)->
  res.send 'ok'

  async.waterfall [
    (cb)->
      request
        url: req.body.url
        encoding: null
      , (err, res, body)-> cb err, req.body.url, body

    (url, body, cb)->
      magic = new Magic()
      magic.detect body, (err, mime)-> cb err, url, mime

    (url, mime, cb)->
      add url if mime?.match /^GIF/
      cb null
  ], (err)->
