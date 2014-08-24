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

Vue.component 'bpm', Vue.extend
  template: '#bpm'
  data:
    bpm: 120
    count: 0
    start: 0
  ready: ->
    $.ajax
      type: 'GET'
      url: '/bpm'
    .done (res)=> @.$data.bpm = parseInt res
  methods:
    measure: ->
      switch @.$data.count
        when 0
          @.$data.start = new Date().getTime()
          @.$data.count += 1
        when 3
          end = new Date().getTime()
          diff = end - @.$data.start
          @.$data.bpm = Math.floor((diff / 1000) * 60)
          socket.emit 'bpm', @.$data.bpm
          @.$data.count = 0
        else
          @.$data.count += 1

main = new Vue
  el: '.buttons'
  data:
    current: 'top'

router = new Router
  '': -> main.current = 'top'
  'upload': -> main.current = 'upload'
  'jockey': -> main.current = 'jockey'
  'select': -> main.current = 'select'
  'bpm':    -> main.current = 'bpm'
router.init()

socket.on 'added', (url)->
  main.$.view.$data.urls.push url

socket.on 'bpm', (bpm)->
  main.$.view.$data.bpm = bpm
