async = require 'async'
request = require 'request'
{Magic} = require 'mmmagic'
{add}   = require './queue'

module.exports = (socket)->
  socket.on 'choose', (url)->
    console.log url

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
          process.globals.io.emit 'added', url
        cb null
    ], (err)->
