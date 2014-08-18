do->
  Vue.component 'top', Vue.extend
    template: '#top'

  Vue.component 'upload', Vue.extend
    template: '#upload'

  main = new Vue
    el: '.buttons'
    data:
      current: 'top'

  router = new Router
    '': -> main.current = 'top'
    'upload': -> main.current = 'upload'
  router.init()
