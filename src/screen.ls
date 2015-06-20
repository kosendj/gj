socket = io!
effects = [
  * name: \grayscale
    values: [1 to 100]
    unit: \%
  * name: \sepia
    values: [1 to 100]
    unit: \%
  * name: \invert
    values: [60 to 100]
    unit: \%
  * name: \saturate
    values: [1 to 100]
    unit: ''
  * name: \hue-rotate
    values: [0 to 360]
    unit: \deg
  * name: \brightness
    values: [130 to 200]
    unit: \%
  * name: \contrast
    values: [130 to 200]
    unit: \%
]

filterMaker = ->
  result = ''
  for effect in effects
    if Math.random! < 0.16
      result += "#{effect.name}(#{effect.values[Math.floor(Math.random! * effect.values.length)]}#{effect.unit}) "
  result

change = ->
  $gifs = $ \.gif
  $gifs.css do
    opacity: 0
  $loadedGifs = $gifs.filter (_, $el)->
    $el.querySelector \x-gif .shadowRoot.querySelector \#frames .childNodes.length > 0
  if $loadedGifs.length > 0
    target = Math.floor(Math.random! * $loadedGifs.length)
    $ $loadedGifs[target] .css do
      opacity: 1
      webkitFilter: filterMaker!
  setTimeout change, (main.$data.bpm / 60) * 1000

processUrls = (urls) ->
  for x in urls
    url = x.replace /^https?:\/\/img\.sorah\.jp/, \http://sorah-pub.s3.amazonaws.com
    if url.match /^https?:\/\/(?:sorah-pub\.s3\.amazonaws\.com|192\.168|10\.|sorah-gif)/
      url
    else
      "/gifs/retrieve/#{url}"

interrupt = (url)->
  main.$set \lock, true
  main.$set \urls, processUrls [url]

  urlHashes = url.split /#/
  duration = 20000
  if 1 < urlHashes.length and urlHashes[urlHashes.length - 1]
    hash = urlHashes[urlHashes.length - 1]
    params = hash.split /:/

    dur = parseInt params[0], 10
    if 0 < dur
      duration = dur

  console.log "Interrupt #{url}, duration:#{duration}"
  setTimeout do
    ->
      main.$set \lock, false
      main.update!
    duration

tweetAdd = (tweet)->
  top = $ \.comment .length * 40
  while top > $ \.commentContainer .height!
    top -= $ \.commentContainer .height!
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
      complete: -> $ @ .remove!

main = new Vue do
  el: \.container
  template: \#gifs
  data:
    urls: []
    bpm: 120
    lock: false
    name: ''
  ready: ->
    @update -> change!
    $.ajax do
      type: \GET
      url: \/bpm
    .done (res)~> @.$data.bpm = res
  methods:
    update: (cb)->
      $.ajax do
        type: \GET
        url: \/gifs/queue
      .done (res)~>
        @.$data.urls = processUrls res
        if cb? then cb!

socket.on \added,  -> unless main.$get \lock then main.update!
socket.on \choose, -> unless main.$get \lock then main.update!
socket.on \bpm, (bpm)-> main.$data.bpm = bpm
socket.on \djadded, interrupt
socket.on \tweet, tweetAdd
socket.on \name, (name)-> main.$data.name = name
