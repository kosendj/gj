<template lang='jade'>
.bpmManual.button
  p
    input(placeholder='230(bpm)', v-model='bpm', autofocus, inputmode='numeric')
.send.button(v-on='click: send(this)')
  p {{status}}
</template>

<script lang='live'>
module.exports =
  data:
    bpm: ''
    status: \set
  ready: ->
    $.ajax do
      type: \GET
      url: \/bpm
    .done (res)~> @.$data.bpm = parseInt res
  methods:
    send: ->
      if @.$data.status is \set
        bpm = parseInt @.$data.bpm
        if 0 < bpm
          socket.emit \bpm, bpm
          @.$data.status = \done
          setTimeout ~>
            @.$data.status = \set
            location.hash = \bpm
          , 1000
</script>
