require! {
  vue : Vue
  \./components/Main.vue
}

socket = io()

main = new Vue Main
  .$mount \.buttons

router = new Router do
  \Top       : -> main.current = \Top
  \Upload    : -> main.current = \Upload
  \Jockey    : -> main.current = \Jockey
  \Select    : -> main.current = \Select
  \BPM       : -> main.current = \BPM
  \BPMManual : -> main.current = \BPMManual
  \dj        : -> main.current = \Upload
  \Name      : -> main.current = \Name

router.init!

socket.on \added, (url)->
  main.$.view.$data.urls.push url

socket.on \bpm, (bpm)->
  main.$.view.$data.bpm = bpm

$ \header
  .on \click, -> main.$.view.$destroy()
