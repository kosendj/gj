{add}   = require './queue'
{push}  = require './queue'
{update} = require './bpm'
{check} = require './gif'
io      = process.globals.io

module.exports = (socket)->
  socket.on 'choose', (url)->
    push url
    io.emit 'choose'

  socket.on 'upload', (url)->
    check url, (err, res)->
      if res
        add url
        io.emit 'added', url

  socket.on 'djupload', (url)->
    check url, (err, res)->
      if res
        add url
        io.emit 'djadded', url

  socket.on 'bpm', (bpm)->
    update bpm
    io.emit 'bpm', bpm

  socket.on 'comment', (body)->
    io.emit 'comment', body
