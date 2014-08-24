redis = process.globals.redis

exports.update = (bpm)->
  redis.set 'bpm', bpm

exports.get = (req, res)->
  redis.get 'bpm', (err, reply)->
    res.send reply
