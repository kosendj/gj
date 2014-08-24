socket = io()

change = ->
  $gifs = $('.gif')
  $gifs.css
    opacity: 0
  target = Math.floor(Math.random() * $gifs.length)
  $(".gif:eq(#{target})").css
    opacity: 1
  setTimeout change, (main.$data.bpm / 60) * 1000

main = new Vue
  el: '.container'
  template: '#gifs'
  data:
    urls: []
    bpm: 120
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

socket.on 'added',  -> main.update()
socket.on 'choose', -> main.update()
socket.on 'bpm', (bpm)-> main.$data.bpm = bpm
