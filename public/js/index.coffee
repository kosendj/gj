socket = io()

Vue.component 'top', Vue.extend
  template: '#top'

Vue.component 'upload', Vue.extend
  template: '#upload'
  methods:
    send: ->
      @.$data.status = 'sending...'
      $.ajax
        type: 'POST'
        url: '/gifs'
        data:
          urls: @.$data.url.split('\n').map (url)-> url.trim()
          dj: if location.hash is '#dj' then 'true' else 'false'
      .done =>
        @.$data.status = 'done'
        setTimeout =>
          @.$data.status = 'send'
          @.$data.url = ''
        , 2000
  data:
    url: ''
    status: 'send'
    placeholder: 'http://...'

Vue.component 'jockey', Vue.extend
  template: '#jockey'

Vue.component 'select', Vue.extend
  template: '#select'
  data:
    urls: []
    page: 0
    showMore: true
  ready: ->
    $.ajax
      type: 'GET'
      url: '/gifs'
    .done (res)=> @.$data.urls = _.uniq res.reverse()
  methods:
    choose: (v)->
      if v.$el.className.match /^preview$/
        socket.emit 'choose', v.$el.querySelector('img').getAttribute('src')
        v.$el.classList.add 'choose'
    more: ->
      @.$data.page += 1
      $.ajax
        type: 'GET'
        url: "/gifs?page=#{@.$data.page}"
      .done (res)=>
        if res.length < 10
          @.$data.showMore = false
        for url in _.uniq(res.reverse())
          @.$data.urls.push url

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
          bpmcandidate = Math.floor((diff / 1000) * 60)
          if bpmcandidate <= 60
            bpmcandidate *= 3
          @.$data.bpm = bpmcandidate
          if bpmcandidate < 400
            socket.emit 'bpm', @.$data.bpm
          @.$data.count = 0
        else
          @.$data.count += 1

Vue.component 'bpm-manual', Vue.extend
  template: '#bpm-manual'
  data:
    bpm: ''
    status: 'set'
  ready: ->
    $.ajax
      type: 'GET'
      url: '/bpm'
    .done (res)=> @.$data.bpm = parseInt res
  methods:
    send: ->
      if @.$data.status is 'set'
        bpm = parseInt(@.$data.bpm, 10)
        if 0 < bpm
          socket.emit 'bpm', bpm
          @.$data.status = 'done'
          setTimeout =>
            @.$data.status = 'set'
            location.hash = 'bpm'
          , 1000

Vue.component 'name', Vue.extend
  template: '#upload'
  methods:
    send: ->
      @.$data.status = 'sending...'
      $.ajax
        type: 'POST'
        url: '/name'
        data:
          name: @.$data.url
      .done (res)=>
        setTimeout =>
          @.$data.status = 'send'
        , 1000
  data:
    url: ''
    status: 'send'
    placeholder: 'Enter DJ name'

main = new Vue
  el: '.buttons'
  data:
    current: 'top'

router = new Router
  'top':    -> main.current = 'top'
  'upload': -> main.current = 'upload'
  'jockey': -> main.current = 'jockey'
  'select': -> main.current = 'select'
  'bpm':    -> main.current = 'bpm'
  'bpm-manual':    -> main.current = 'bpm-manual'
  'dj':     -> main.current = 'upload'
  'name':   -> main.current = 'name'
router.init()

socket.on 'added', (url)->
  main.$.view.$data.urls.push url

socket.on 'bpm', (bpm)->
  main.$.view.$data.bpm = bpm

$('header').on 'click', ->
  main.$.view.$destroy()
