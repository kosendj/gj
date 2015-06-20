async   = require 'neo-async'
request = require 'request'
{Magic} = require 'mmmagic'
io      = process.globals.io

check = (url, callback)->
  if url.match(/^http:\/\/sorah-gif/)
    callback(null, true)
    return

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

exports.index = (req, res)->
  if req.query.page?
    page = (req.query.page * -10) - 1
  else
    page = -1
  process.globals.redis.lrange 'gifs', page - 9, page, (err, reply)-> res.json reply

exports.add = (req, res)->
  {add} = require './queue'
  event = if req.body.dj is 'true' then 'djadded' else 'added'
  if req.body.urls?
    if req.body.urls.forEach?
      req.body.urls.forEach (url)->
        check url, (err, r)->
          if r
            add url
            io.emit event, url
  res.send 'ok'

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
