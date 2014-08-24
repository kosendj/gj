socket = io()

change = ->
  $gifs = $('.gif')
  $gifs.css
    opacity: 0
  target = Math.floor(Math.random() * $gifs.length)
  $(".gif:eq(#{target})").css
    opacity: 1
  setTimeout change, 600

main = new Vue
  el: '.container'
  template: '#gifs'
  data:
    urls: []
  ready: -> @update -> change()
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
