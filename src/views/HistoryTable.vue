<template>
  <div class="container">
    <h1 class="title">Swap History</h1>
    <div v-for="swapData in swapDataList" :key="swapData.id" class="swap-data">
      <div class="swap-stats">
        <div>
          <span>Hash send:</span>&nbsp;<span>{{swapData.tx_sender}}</span>
        </div>
        <div>
          <span>Sender:</span>&nbsp;<span class="sender">{{swapData.sender}}</span>
        </div>
        <div>
          <span>Sum send:</span>&nbsp;<span class="sender">{{swapData.suma}}</span>
        </div>
        <div>
          <span>Hash rcpt:</span>&nbsp;<span>{{swapData.tx_receiver}}</span>
        </div>
        <div>
          <span>Recepient:</span>&nbsp;<span class="sender">{{swapData.receiver}}</span>
        </div>
         <div>
          <span>Sum rcpt:</span>&nbsp;<span class="sender">{{swapData.sumb}}</span>
        </div>
      </div>
      <div class="swap-dtm">
        <span>DTM send:</span>&nbsp;<span>{{swapData.dtma}}</span><br>
	<span>DTM rcpt:</span>&nbsp;<span>{{swapData.dtmb}}</span>
      </div>
    </div>
  </div>
</template>
<script>
export default {
  name: 'historyTable',
  data () {
    return {
      swapDataList: []
    }
  },
  mounted () {
    const u = this.makeUrlee()
    this.getSwapData(u)
  },
  methods: {
    getSwapData (url) {
      fetch(url, {cache: 'no-store'})
           .then(response => response.json())
           .then(data => (this.swapDataList = data))
    },
    getParentOrigin () {
      const locationAreDisctint = (window.location !== window.parent.location)
      const parentOrigin = ((locationAreDisctint ? document.referrer : document.location) || '').toString()
      if (parentOrigin) {
        return new URL(parentOrigin).origin
      }
      const currentLocation = document.location
      if (currentLocation.ancestorOrigins && currentLocation.ancestorOrigins.length) {
        return currentLocation.ancestorOrigins[0]
      }
      return ''
    },
    makeUrlee () {
      const inFrame = window !== window.top
      const h = inFrame ? 'https://coins.room-house.com' : this.getParentOrigin()
      const u = h + '/cgi/sw_hist_api.pl'
      return u
    }
  }
}
</script>
<style>
@media screen and (min-width: 1024px) {
.swap-data {
  display: flex;
  align-items: center;
  margin-top: 20px;
  margin-left: 20px;
  border-bottom: 2px solid #ccc;
  padding: 20px;
}

.swap-stats {
  flex-grow: 8;
  text-align: left;
  padding-left: 20px;
  font-size:12px;
}

.swap-stats .sender {
  font-size: 16px;
}

.swap-dtm {
  flex-grow: 1;
  font-size: 18px;
}
}
@media screen and (max-width: 1024px) {
.swap-data {
  display: flex;
  align-items: center;
  margin-top: 20px;
  margin-left: 0px;
  border-bottom: 2px solid #ccc;
  padding: 5px;
  max-width: 360px;
  mix-width: 300px;
}

.swap-stats {
  flex-grow: 8;
  text-align: left;
  padding-left: 0px;
  font-size:12px;
}

.swap-stats .sender {
  font-size: 16px;
}

.swap-dtm {
  flex-grow: 1;
  font-size: 12px;
  max-width: 320px;
  mix-width: 300px;
}
}
</style>
