async   = require 'async'
request = require 'request'
{Magic} = require 'mmmagic'

exports.index = (req, res)->
  if req.query.page?
    page = (req.query.page * -10) - 1
  else
    page = -1
  process.globals.redis.lrange 'gifs', page - 9, page, (err, reply)-> res.json reply

exports.retrieve = (req, res)->
  url = req.params[0]
  unless url.match(/^https?:\//)
    res.status(404).send("not found\n")
    return

  preq = request(
    url: url
    encoding: null
  )

  res.set('Cache-Control', 'public,max-age=28800')
  preq.on 'response', (pres) ->
    if pres.headers['content-type'] && !pres.headers['content-type'].match(/gif/i)
      res.status(400).send("not gif\n")
      res.end()
      return
    pres.on 'data', (chunk) ->
      res.write chunk, 'binary'
    pres.on 'end', -> res.end()

exports.check = (url, callback)->
  async.waterfall [
    (cb)->
      request
        url: url
        encoding: null
      , (err, res, body)-> cb err, body

    (body, cb)->
      magic = new Magic()
      magic.detect body, (err, mime)-> cb err, mime

    (mime, cb)->
      if mime?.match /^GIF/
        cb null, true
      else
        cb null, false
  ], (err, res)-> callback err, res
