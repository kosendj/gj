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

change = ->
  $gifs = $('.gif')
  $gifs.css
    opacity: 0
  target = Math.floor(Math.random() * $gifs.length)
  $(".gif:eq(#{target})").css
    opacity: 1
    webkitFilter: filterMaker()
  setTimeout change, (main.$data.bpm / 60) * 1000

interrupt = (url)->
  main.$set 'lock', true
  main.$set 'urls', [url]
  setTimeout ->
    main.$set 'lock', false
    main.update()
  , 20000

commentAdd = (body)->
  top = $('.comment').length * 40
  top -= $('.commentContainer').height() while top > $('.commentContainer').height()
  $("<p class=\'comment\'>#{body}</p>").appendTo $('.commentContainer')
    .css
      top: "#{top}px"
    .transition
      left: "-#{$('.commentContainer').width()}px"
      duration: 10000
      easing: 'linear'
      complete: -> $(@).remove()

main = new Vue
  el: '.container'
  template: '#gifs'
  data:
    urls: []
    bpm: 120
    lock: false
  ready: ->
    @update -> change()
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
        @.$data.urls = res
        if cb? then cb()

socket.on 'added',  -> if !main.$get('lock') then main.update()
socket.on 'choose', -> if !main.$get('lock') then main.update()
socket.on 'bpm', (bpm)-> main.$data.bpm = bpm
socket.on 'djadded', interrupt
socket.on 'comment', commentAdd
