socket = io()

Vue.component 'top', Vue.extend
  template: '#top'

Vue.component 'upload', Vue.extend
  template: '#upload'
  methods:
    send: ->
      event = switch location.hash
        when '#upload' then 'upload'
        when '#dj'     then 'djupload'
        else null

      if event? and @.$data.url.length > 0
        socket.emit event, @.$data.url
        @.$data.status = 'done'
        setTimeout =>
          @.$data.status = 'send'
          @.$data.url = ''
        , 2000
  data:
    url: ''
    status: 'send'

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

main = new Vue
  el: '.buttons'
  data:
    current: 'top'

router = new Router
  '': -> main.current = 'top'
  'top':    -> main.current = 'top'
  'upload': -> main.current = 'upload'
  'jockey': -> main.current = 'jockey'
  'select': -> main.current = 'select'
  'bpm':    -> main.current = 'bpm'
  'dj':     -> main.current = 'upload'
router.init()

socket.on 'added', (url)->
  main.$.view.$data.urls.push url

socket.on 'bpm', (bpm)->
  main.$.view.$data.bpm = bpm

$('header').on 'click', ->
  main.$.view.$destroy()
