<template lang='jade'>
.url.button
  textarea(v-model='url', v-attr='placeholder: placeholder', autofocus)
.send.button(v-on='click: send(this)')
  p {{status}}
</template>

<script lang='live'>
module.exports =
  methods:
    send: ->
      @.$data.status = \sending...
      $.ajax do
        type: \POST
        url: \/gifs
        data:
          urls: @.$data.url.split('\n').map (url)-> url.trim!
          dj: if location.hash is \#dj then \true else \false
      .done ~>
        @.$data.status = \done
        setTimeout ~>
          @.$data.status = \send
          @.$data.url = ''
        , 2000
  data:
    url: ''
    status: \send
    placeholder: \http://...
</script>
