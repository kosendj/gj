<template lang='jade'>
.preview(v-repeat='urls')
  img(src='{{$value}}', v-on='click: choose(this)')
.more(v-on='click: more(this)', v-show='showMore') more
</template>

<script lang='live'>
module.exports =
  data:
    urls: []
    page: 0
    showMore: true
  ready: ->
    $.ajax do
      type: \GET
      url: \/gifs
    .done (res)~> @.$data.urls = _.uniq res.reverse!
  methods:
    choose: (v)->
      if v.$el.className.match /^preview$/
        socket.emit \choose, v.$el.querySelector(\img).getAttribute \src
        v.$el.classList.add \choose
    more: ->
      @.$data.page += 1
      $.ajax do
        type: \GET
        url: "/gifs?page=#{@.$data.page}"
      .done (res)~>
        if res.length < 10 then @.$data.showMore = false
        for url in _.uniq res.reverse!
          @.$data.urls.push url
</script>
