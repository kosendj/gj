<template lang='jade'>
.current(v-component='{{current}}')
</template>

<script lang='live'>
require! {
  \./Top.vue
  \./Upload.vue
  \./Jockey.vue
  \./Select.vue
  \./BPM.vue
  \./BPMManual.vue
  \./Name.vue
}

module.exports =
  components:
    Top: Top
    Upload: Upload
    Jockey: Jockey
    Select: Select
    BPM: BPM
    BPMManual: BPMManual
    Name: Name
  data:
    current: \Top
</script>
