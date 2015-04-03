<template lang='jade'>
.url.button
  textarea(v-model='url', v-attr='placeholder: placeholder', autofocus)
.send.button(v-on='click: send(this)')
  p {{status}}
</template>

<script lang='live'>
module.exports =
  data:
    url: ''
    status: \send
    placeholder: 'Enter DJ name'
  methods:
    send: ->
      @.$data.status = \sending...
      $.ajax do
        type: \POST
        url: \/name
        data:
          name: @.$data.url
      .done (res)~>
        setTimeout ~>
          @.$data.status = 'send'
        , 1000
</script>
