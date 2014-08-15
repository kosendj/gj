do->
  Vue.component 'top', Vue.extend
    template: '#top'

  main = new Vue
    el: '.buttons'
    data:
      current: 'top'

  router = new Router
    '/': -> main.current = 'top'
  router.init()
