socket = io()

change = (i)->
  $gifs = $('.gif')
  if i >= $gifs.length then i = 0
  $gifs.css
    opacity: 0
  $(".gif:eq(#{i})").css
    opacity: 1
  setTimeout ->
    change i+1
  , 600

main = new Vue
  el: '.container'
  template: '#gifs'
  data:
    urls: []
  ready: ->
    $.ajax
      type: 'GET'
      url: '/gifs/queue'
    .done (res)=>
      @.$data.urls = res
      change 0
