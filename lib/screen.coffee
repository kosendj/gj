io = process.globals.io

exports.name = (req, res)->
  io.emit 'name', req.body.name
  res.send 'ok'
