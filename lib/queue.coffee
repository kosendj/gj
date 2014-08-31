redis = process.globals.redis

trimQueue = ->
  redis.ltrim 'queue', -10, -1

exports.add = (url)->
  console.log(url)
  redis.rpush 'gifs', url
  redis.rpush 'queue', url, -> trimQueue()

exports.push = (url)->
  redis.rpush 'queue', url, -> trimQueue()

exports.index = (req, res)->
  redis.lrange 'queue', 0, 10, (err, reply)-> res.json reply
