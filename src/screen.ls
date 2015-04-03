require! {
  \./components/Screen.vue
  \./effects
}

socket = io!

filterMaker = ->
  result = ''
  for effect in effects
    if Math.random() < 0.16
      result += "#{effect.name}(#{effect.values[Math.floor(Math.random()*effect.values.length)]}#{effect.unit}) "
  result

change = ->
  $gifs = $ \.gif
  $gifs.css do
    opacity: 0
  target = Math.floor Math.random() * $gifs.length
  $ ".gif:eq(#{target})"
    .css do
      opacity: 1
      webkitFilter: filterMaker!
  setTimeout change, (main.$data.bpm / 60) * 1000

interrupt = (url)->
  main.$set \lock, true
  main.$set \urls, processUrls [url]

  url_hashes = url.split /#/
  duration = 20000
  if 1 < url_hashes.length && url_hashes[url_hashes.length-1]
    hash = url_hashes[url_hashes.length-1]
    params = hash.split /:/

    dur = parseInt params[0]
    if 0 < dur
      duration = dur

  setTimeout ->
    main.$set \lock, false
    main.update!
  , duration

tweetAdd = (tweet)->
  top = $(\.comment').length * 40
  while top > $(\.commentContainer).height!
    top -= $(\.commentContainer).height!
  $ \<p>
    .text tweet.text
    .addClass \comment
    .appendTo $ \.commentContainer
    .css do
      top: "#{top}px"
    .transition do
      left: "-#{$('.commentContainer').width()}px"
      duration: 10000
      easing: \linear
      complete: -> $(@).remove!

processUrls = (urls) ->
  for x in urls
    url = x.replace /^https?:\/\/img\.sorah\.jp/, 'http://sorah-pub.s3.amazonaws.com'
    if url.match /^https?:\/\/(?:sorah-pub\.s3\.amazonaws\.com|192\.168|10\.|sorah-gif)/
      url
    else
      "/gifs/retrieve/#{url}"

new Vue Screen
  .$mount \#emo

socket.on \added,  -> if !main.$get \lock then main.update!
socket.on \choose, -> if !main.$get \lock then main.update!
socket.on \bpm, (bpm)-> main.$data.bpm = bpm
socket.on \djadded, interrupt
socket.on \tweet, tweetAdd
socket.on \name, (name)-> main.$data.name = name
