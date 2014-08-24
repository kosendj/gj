async   = require 'async'
request = require 'request'
{Magic} = require 'mmmagic'
{add}   = require './queue'
{push}  = require './queue'
io      = process.globals.io

module.exports = (socket)->
  socket.on 'choose', (url)->
    push url
    io.emit 'choose'

  socket.on 'upload', (url)->
    async.waterfall [
      (cb)->
        request
          url: url
          encoding: null
        , (err, res, body)-> cb err, url, body

      (url, body, cb)->
        magic = new Magic()
        magic.detect body, (err, mime)-> cb err, url, mime

      (url, mime, cb)->
        if mime?.match /^GIF/
          add url
          io.emit 'added', url
        cb null
    ], (err)->
