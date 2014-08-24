module.exports = (socket)->
  socket.on 'choose', (url)->
    console.log url
