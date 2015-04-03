<template lang='jade'>
.gif(v-repeat='urls')
  x-gif(src='{{$value}}', bpm='{{bpm}}')
.name
  p {{name}}
</template>

<script lang='live'>
module.exports =
  el: \.container
  data:
    urls: []
    bpm: 120
    lock: false
    name: ''
  ready: ->
    @update -> change!
    $.ajax do
      type: \GET
      url: \/bpm
    .done (res)~> @.$data.bpm = res
  methods:
    update: (cb)->
      $.ajax do
        type: 'GET'
        url: '/gifs/queue'
      .done (res)~>
        @.$data.urls = processUrls res
        if cb? then cb!
</script>
