redis = process.globals.redis

overflowCheck = ->
  redis.llen 'queue', (err, reply)->
    if reply > 10
      redis.lpop 'queue'
      overflowCheck()

exports.add = (url)->
  redis.lpush 'gifs', url
  redis.lpush 'queue', url
  overflowCheck()

exports.index = (req, res)->
  redis.lrange 'queue', 0, 10, (err, reply)-> res.json reply
