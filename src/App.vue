<template>
  <div id="q-app">
    <router-view />
  </div>
</template>

<script>
import { state, mutations } from 'src/store/index'

export default {
  name: 'App',
  mounted() {
    /**
     * Initialize the checklist vuex state using the current data set
     * in the device's local storage.
     */
    mutations.initLocalStorage(state)
  },
}
</script>
