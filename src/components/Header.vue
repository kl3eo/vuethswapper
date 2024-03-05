<template>
  <nav class="navbar">
   <div class="navbar-brand">
     <router-link class="navbar-item" to="/">Instructions</router-link>

     <div class="navbar-burger burger" v-on:click.prevent="toggleMenu">
       <span></span>
       <span></span>
       <span></span>
     </div>
   </div>
   <div class="navbar-menu" v-bind:class="{'is-active': isMenuActive}">
      <div class="navbar-start">
        <div class="navbar-item has-dropdown is-hoverable" @mouseover="show=true" @mouseleave="show=false">

          <router-link class="navbar-link" to="#">Wallet Actions</router-link>

          <div class="navbar-dropdown" v-show="show" @click="show=false">
            <router-link class="navbar-item" to="/eth">Create Wallet</router-link>
            <router-link class="navbar-item" to="/eth/wallet-seed">Mnemonic Wallet</router-link>
            <router-link class="navbar-item" to="/eth/import-keystore">Import Wallet</router-link>
            <router-link class="navbar-item" to="/eth/value-transaction">Transfer Funds</router-link>
            <router-link class="navbar-item" to="/eth/sp-exchange">Swap</router-link>
          </div>
        </div>
      </div>
   </div>
   <div class="navbar-brand">
     <router-link class="navbar-item" to="/hist" ref="swpLink">Swap History</router-link>
   </div>
  </nav>
</template>

<script>
export default {
  name: 'HeaderApp',
  data () {
    return {
      isMenuActive: false,
      show: true
    }
  },
  methods: {
    toggleMenu () {
      if (this.isMenuActive) {
        this.isMenuActive = false
      } else {
        this.isMenuActive = true
      }
    }
  }
  // watch: {
    // $route (to, from) {
      // console.log('show', this.show)
    // }
  // }
}
</script>
