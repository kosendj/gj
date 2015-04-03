<template lang='jade'>
.bpm.field(v-on='click: measure(this)') {{bpm}}
  p (tap here)
a.bpmManual.button(href='#bpm-manual')
  p set manually
</template>

<script lang='live'>
module.exports =
  data:
    bpm: 120
    count: 0
    start: 0
  ready: ->
    $.ajax do
      type: \GET
      url: \/bpm
    .done (res)~> @.$data.bpm = parseInt res
  methods:
    measure: ->
      switch @.$data.count
        when 0
          @.$data.start = new Date!.getTime!
          @.$data.count += 1
        when 3
          end = new Date!.getTime!
          diff = end - @.$data.start
          bpmcandidate = Math.floor((diff / 1000) * 60)
          if bpmcandidate <= 60 then bpmcandidate *= 3
          @.$data.bpm = bpmcandidate
          if bpmcandidate < 400 then socket.emit \bpm, @.$data.bpm
          @.$data.count = 0
        else
          @.$data.count += 1
</script>
