socket = io()

Vue.component 'top', Vue.extend
  template: '#top'

Vue.component 'upload', Vue.extend
  template: '#upload'
  methods:
    send: -> socket.emit 'upload', @.$data.url
  data:
    url: ''

Vue.component 'jockey', Vue.extend
  template: '#jockey'

Vue.component 'select', Vue.extend
  template: '#select'
  data:
    urls: []
  ready: ->
    $.ajax
      type: 'GET'
      url: '/gifs'
    .done (res)=> @.$data.urls = res.reverse()
  methods:
    choose: (v)->
      socket.emit 'choose', v.$el.querySelector('img').getAttribute('src')

main = new Vue
  el: '.buttons'
  data:
    current: 'top'

router = new Router
  '': -> main.current = 'top'
  'upload': -> main.current = 'upload'
  'jockey': -> main.current = 'jockey'
  'select': -> main.current = 'select'
router.init()

socket.on 'added', (url)->
  main.$.view.$data.urls.push url
