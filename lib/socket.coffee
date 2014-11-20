{push}  = require './queue'
{update} = require './bpm'
io      = process.globals.io

module.exports = (socket)->
  socket.on 'choose', (url)->
    push url
    io.emit 'choose'

  socket.on 'bpm', (bpm)->
    update bpm
    io.emit 'bpm', bpm
