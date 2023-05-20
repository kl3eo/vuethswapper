<style scope>
.navbar-start > .navbar-item.active {
  background-color: #eee
}
.section .panel {
  overflow: hidden;
}
</style>

<template>
<div id="app">
  <div class="container">
    <HeaderApp />
    <section class="section">
      <div>
        <transition appear>
          <router-view></router-view>
        </transition>
      </div>
    </section>
  </div>
  <FooterApp />
  <Notifications />
</div>
</template>

<script>
import HeaderApp from '@/components/Header'
import FooterApp from '@/components/Footer'
import Notifications from '@/components/Notifications'
import { mapActions } from 'vuex'

export default {
  name: 'app',
  components: {
    HeaderApp,
    FooterApp,
    Notifications
  },
  mounted () {
    this.notify({ text: 'You can use this program on your own judgement of risk!', class: 'is-info' })
  },
  methods: {
    ...mapActions([
      'notify'
    ])
  }
}
</script>
