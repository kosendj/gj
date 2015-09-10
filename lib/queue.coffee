
Crypto = require 'crypto'
generateCamoUrl  = (url) ->
  hmac = Crypto.createHmac("sha1", process.env.CAMO_KEY)
  hmac.update(url, 'utf8')
  digest = hmac.digest('hex')

  buf = ""
  for i in [0...url.length]
    buf += url.charCodeAt(i).toString(16)
  hexurl = buf.toString()

  "#{process.env.CAMO_URL}/#{digest}/#{hexurl}"

redis = process.globals.redis

trimQueue = ->
  redis.ltrim 'queue', -10, -1

exports.add = (url)->
  console.log("queue.add: #{url}")
  if !url.match(/\.kosendj-bu\.in\//) && process.env.CAMO_URL 
    url = generateCamoUrl(url)
    console.log("queue.add-camo: #{url}")

  redis.rpush 'gifs', url
  redis.rpush 'queue', url, -> trimQueue()

exports.push = (url)->
  redis.rpush 'queue', url, -> trimQueue()

exports.index = (req, res)->
  redis.lrange 'queue', 0, 10, (err, reply)-> res.json reply
