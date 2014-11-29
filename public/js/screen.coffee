socket = io()
effects = [
  {
    name: 'grayscale'
    values: [1..100]
    unit: '%'
  }
  {
    name: 'sepia'
    values: [1..100]
    unit: '%'
  }
  {
    name: 'invert'
    values: [60..100]
    unit: '%'
  }
  {
    name: 'saturate'
    values: [1..100]
    unit: ''
  }
  {
    name: 'hue-rotate'
    values: [0..360]
    unit: 'deg'
  }
  {
    name: 'brightness'
    values: [130..200]
    unit: '%'
  }
  {
    name: 'contrast'
    values: [130..200]
    unit: '%'
  }
]

filterMaker = ->
  result = ''
  for effect in effects
    if Math.random() < 0.16
      result += "#{effect.name}(#{effect.values[Math.floor(Math.random()*effect.values.length)]}#{effect.unit}) "
  result

autoEffect = ->
  $gifs = $('.gif')
  $gifs.css
    opacity: 0
  target = Math.floor(Math.random() * $gifs.length)
  $(".gif:eq(#{target})").css
    opacity: 1
    webkitFilter: filterMaker()
  setTimeout autoEffect, (main.$data.bpm / 60) * 1000

processUrls = (urls) ->
  for x in urls
    url = x.replace(/^https?:\/\/img\.sorah\.jp/, 'http://sorah-pub.s3.amazonaws.com')
    if url.match(/^https?:\/\/(?:sorah-pub\.s3\.amazonaws\.com|192\.168|10\.|sorah-gif)/)
      url
    else
      "/gifs/retrieve/#{url}"

interrupt = (url)->
  main.$set 'lock', true
  main.$set 'urls', processUrls([url])

  url_hashes = url.split(/#/)
  duration = 20000
  if 1 < url_hashes.length && url_hashes[url_hashes.length-1]
    hash = url_hashes[url_hashes.length-1]
    params = hash.split(/:/)

    dur = parseInt(params[0], 10)
    if 0 < dur
      duration = dur

  console.log("Interrupt #{url}, duration:#{duration}")
  setTimeout ->
    main.$set 'lock', false
    main.update()
  , duration

tweetAdd = (tweet)->
  top = $('.comment').length * 40
  top -= $('.commentContainer').height() while top > $('.commentContainer').height()
  $("<p>").text(tweet.text)
    .addClass('comment')
    .appendTo $('.commentContainer')
    .css
      top: "#{top}px"
    .transition
      left: "-#{$('.commentContainer').width()}px"
      duration: 10000
      easing: 'linear'
      complete: -> $(@).remove()

midiController = (id, kind, value)->
  switch kind
    when 'SLIDER'
      $(".gif:eq(#{id})").css
        opacity: parseFloat(value / 128)

midiInit = (callback)->
  midi = new MIDI()
  try
    midi.init().then ->
      kontrol = new nanoKONTROL()
      kontrol.init midi, midiController
      callback null
    , null
  catch err
    callback err

main = new Vue
  el: '.container'
  template: '#gifs'
  data:
    urls: []
    bpm: 120
    lock: false
    name: ''
  ready: ->
    midiInit (err)=> @update -> if err? then autoEffect()
    $.ajax
      type: 'GET'
      url: '/bpm'
    .done (res)=> @.$data.bpm = res
  methods:
    update: (cb)->
      $.ajax
        type: 'GET'
        url: '/gifs/queue'
      .done (res)=>
        @.$data.urls = processUrls(res)
        if cb? then cb()

socket.on 'added',  -> if !main.$get('lock') then main.update()
socket.on 'choose', -> if !main.$get('lock') then main.update()
socket.on 'bpm', (bpm)-> main.$data.bpm = bpm
socket.on 'djadded', interrupt
socket.on 'tweet', tweetAdd
socket.on 'name', (name)-> main.$data.name = name
