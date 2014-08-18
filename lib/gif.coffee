module.exports = (req, res)->
  process.globals.redis.lrange 'gifs', 0, 20, (err, reply)-> res.json reply
