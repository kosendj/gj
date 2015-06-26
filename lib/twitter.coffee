Twit = require 'twit'

io = process.globals.io

unless process.env.DISABLE_TWITTER == '1'
  twitter = new Twit
    consumer_key: process.env.CONSUMER_KEY
    consumer_secret: process.env.CONSUMER_SECRET
    access_token: process.env.ACCESS_TOKEN
    access_token_secret: process.env.ACCESS_TOKEN_SECRET

  replaceHashtag = new RegExp process.env.HASH_TAG, 'g'

  stream = twitter.stream 'statuses/filter',
    track: "##{process.env.HASH_TAG}"

  stream.on 'tweet', (tweet)->
    io.emit 'tweet',
      text: tweet.text.replace replaceHashtag, ''
