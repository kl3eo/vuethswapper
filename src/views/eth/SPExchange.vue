<template>
  <div class="panel">
    <h2 class="panel-heading">SkyRHC Swap 1:{{ ratio }}</h2>

    <div class="panel-block">
      <div class="container">
        <div class="columns">
          <div class="column is-one-quarter">
            <label class="label" for="value">Available for Swap:</label>
          </div>
          <div class="column is-one-quarter">
            {{ avail }} {{ ticker }}
          </div>
        </div>
      </div>
    </div>
    <div class="panel-block">
      <div class="container">
        <div class="columns">
          <div class="column is-one-quarter">
            <label class="label" for="value">Wallet</label>
          </div>
        
          <div class="column is-third-quarter">
            <div class="control">
              <div class="select">
                <select v-model="walletType">
                  <option value="0">Choose Wallet</option>
                  <option value="1">Import from json</option>
                  <option value="2">Metamask</option>
                  <!-- option value="3">Ledger</option -->
                </select>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="panel-block" v-if="isImportJSON">
      <div class="container">
        <password-input v-on:failed="failed" v-on:success="success"></password-input>
      </div>
    </div>
    
    <div class="panel-block" v-if="isImportJSON">
      <div class="container">
        <div class="columns">
          <div class="column is-one-quarter">
            <label class="label" for="file-seed">Keystore JSON</label>
          </div>
        
          <div class="column is-third-quarter">
            <div class="control">
              <input id="file-seed" class="input" type="file" v-on:change="readKeystoreJsonFile" placeholder="Keystore JSON" v-bind:class="{'is-danger': (!isKeystoreJsonValid && keystoreJson), 'is-success': isKeystoreJsonValid}">
              <p class="help is-danger file-help" v-if="!isKeystoreJsonValid && keystoreJson">Keystore JSON isn't valid</p>
              <p class="help is-success file-help" v-if="isKeystoreJsonValid">Keystore JSON is valid</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <template v-if="address">
      <div class="panel-block" >
        <div class="container">
          <div class="columns">
            <div class="column is-one-quarter">
              <label class="label">Address</label>
            </div>
            <div class="column is-three-quarter">
              <p v-if="!isHostValid">{{ address }}</p>
              <p v-if="isHostValid"><a v-bind:href="`${this.explorer}/address/${this.address}`" target="_blank">{{ address }}</a></p>
            </div>
          </div>
        </div>
      </div>

      <div class="panel-block" v-if="isHostValid || isMetamask">
        <div class="container">
          <div class="columns">
            <div class="column is-one-quarter">
              <label class="label">Balance</label>
            </div>
            <div class="column is-three-quarter">
              <p>{{ !isHostValid ? parseInt(balance,16).toString(10) : balance }} (wei)</p>
            </div>
          </div>
        </div>
      </div>

      <div class="panel-block" v-if="!isMetamask">
        <div class="container">
          <div class="columns">
            <div class="column is-one-quarter">
              <label class="label" for="host">Host</label>
            </div>
          
            <div class="column is-half">
              <div class="control">
                <input id="host" class="input" type="text" v-model="host" placeholder="Host" v-bind:class="{'is-danger': (!isHostValid && host), 'is-success': isHostValid}" v-on:change="resetProvider">
                <p class="help is-danger" v-if="!isHostValid && host">Host isn't valid</p>
                <p class="help is-success" v-if="isHostValid">Host is valid</p>
              </div>
            </div>

            <div class="column is-one-quarter">
              <div class="select is-info">
                <select v-on:change="selectHost">
                  <option value="">------</option>
                  <option v-for="(host, key) in hosts" v-bind:value="key">
                    {{ `${key} ${(host.test === true) ? 'test network' : 'network'}` }}
                  </option>
                </select>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="panel-block">
        <div class="container">
          <div class="columns">
            <div class="column is-one-quarter">
              <label class="label">SkyRHC Address</label>
            </div>
          
            <div class="column is-third-quarter">
              <div class="control">
		<!-- input id="toAddress" class="input" type="text" v-model="toAddress" value=this.toAddress disabled -->
		<input id="spAddress" class="input" type="text" v-model="spAddress" placeholder="SkyRHC Address" v-bind:class="{'is-danger': (!isSPAddressValid && spAddress), 'is-success': isSPAddressValid}" required>
                <p class="help is-danger" v-if="!isSPAddressValid && spAddress">SkyRHC Address isn't valid</p>
                <p class="help is-success" v-if="isSPAddressValid && spAddress">SkyRHC Address is valid</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="panel-block">
        <div class="container">
          <ether-units v-bind:valueLabel="'Send Value'" v-bind:valuePlaceholder="'Send Value'" v-on:success="(e) => {val = e.value * e.unit}" />
        </div>
      </div>

      <div class="panel-block">
        <div class="container">
          <div class="columns">
            <div class="column is-one-quarter">
              <label class="label" for="nonce">Nonce</label>
            </div>
          
            <div class="column is-third-quarter">
              <div class="control">
                <input id="nonce" class="input" type="text" v-model="nonce" placeholder="Nonce" disabled>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="panel-block">
        <div class="container">
          <div class="columns">
            <div class="column is-one-quarter">
              <label class="label" for="chainid">Chain Id</label>
            </div>
          
            <div class="column is-third-quarter">
              <div class="control">
                <input id="chainid" class="input" type="text" v-model="chainId" placeholder="Chain Id" disabled>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="panel-block" v-if="result">
        <div class="container">
          <div class="columns">
            <div class="column is-one-quarter">
              <label class="label" for="value">Result</label>
            </div>
          
            <div class="column is-third-quarter">
              <div class="control">
                <p><a v-bind:href="`${this.explorer}/tx/${this.result}`" target="_blank">{{ result }}</a></p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </template>

    <div class="panel-block has-text-centered">
      <div class="container">
        <button class="button is-primary" v-bind:disabled="working" v-on:click.prevent.self="importWallet" v-if="walletType !== '0' && !address">
          <template v-if="isImportJSON">
            Import Wallet
          </template>
          <template v-if="!isImportJSON">
            Connect
          </template>
        </button>
        <button class="button is-info" v-on:click.prevent.self="signTransaction" v-if="!shipped && address && !signedTransaction && !send && (isImportJSON || isLedger)">Sign Transaction</button>
        <button class="button is-warning" v-on:click.prevent.self="sendTransaction" v-if="!shipped && address && !send && (signedTransaction || isMetamask)">Send Transaction</button>
        <button class="button is-info" v-on:click.prevent.self="cancelTransaction" v-if="!shipped && address && !send && (signedTransaction || isMetamask)">Cancel</button>
        <button class="button is-danger" v-if="send">Sending transaction, please wait..</button>
        <button class="button is-info" v-on:click.prevent.self="reloadPage" v-if="shipped && address && !send && (signedTransaction || isMetamask)">Swap Complete</button>
      </div>
    </div>

  </div>
</template>

<script>
import yoethwallet from 'yoethwallet'
import Message from '@/components/Message'
import { ethers } from 'ethers'
import config from '@/config'
import confirmedTransaction from '@/util/confirmedTransaction'
import { mapActions } from 'vuex'
import PasswordInput from '@/components/PasswordInput'
import EtherUnits from '@/components/EtherUnits'
import detectEthereumProvider from '@metamask/detect-provider'
import { BigNumber } from 'bignumber.js'
import LedgerTransportWebUSB from '@ledgerhq/hw-transport-webusb'
import LedgerEtherApp from '@ledgerhq/hw-app-eth'
import Connector from '@vue-polkadot/vue-api'
import keyring from '@polkadot/ui-keyring'

export default {
  name: 'sp-exchange',
  components: {
    Message,
    PasswordInput,
    EtherUnits
  },
  data () {
    return {
      working: false,
      password: '',
      type: 'text',
      buttonText: 'Hide',
      score: 0,
      keystore: {},
      address: '',
      keystoreJson: '',
      host: '',
      explorer: '',
      // toAddress: '0x4073bc820e0933AA92853a44A3B216C359d776d8', // to the world in swapper
      toAddress: '0xd3f3f015873f9cd8d6698b688b109bcd33222037',
      apiUrl: 'wss://aspen.room-house.com:8466',
      spAddress: '',
      spXETR: '5CkLgg19XECX98Lxam7kd4yZWyMqs6dG5Z686e2EkwtHqU86',
      shipped: false,
      api_checked: false,
      keyringLoaded: false,
      val: new BigNumber(0),
      gasPrice: '20000000000',
      gasLimit: '21000',
      gas: '',
      data: '',
      result: '',
      provider: {},
      hosts: {},
      nonce: '0',
      chainId: '',
      signedTransaction: '',
      send: false,
      badRpcCall: false,
      balance: '0',
      avail: '..checking..',
      ticker: '',
      ratio: '1',
      walletType: '0',
      metamaskProvider: null,
      path: '44\'/60\'/0\'/0/0',
      ledgerApp: null
    }
  },
  created () {
    this.hosts = config.hosts || {}
  },
  mounted () {
    this.mapAccounts()
    this.setCoo()
    this.setAvail()
  },
  computed: {
    isKeystoreJsonValid () {
      if (!this.keystoreJson) {
        return false
      }
      try {
        JSON.parse(this.keystoreJson)
      } catch (e) {
        return false
      }
      return true
    },
    isHostValid () {
      if (!this.host) {
        return false
      }
      return /https?:\/\/([\w.]+):?([\d]+)?/.test(this.host)
    },
    isToAddressValid () {
      if (!this.toAddress) {
        return false
      }
      return /0x[a-zA-Z0-9]{40}/.test(this.toAddress)
    },
    isSPAddressValid () {
      if (!this.spAddress) {
        return false
      }
      return /5[a-zA-Z0-9]{47}/.test(this.spAddress)
    },
    isImportJSON () {
      return this.walletType === '1'
    },
    isMetamask () {
      return this.walletType === '2'
    },
    isBadRpcCall () {
      return this.badRpcCall === true
    },
    isLedger () {
      return this.walletType === '3'
    }
  },
  methods: {
    cancelTransaction () {
      this.send = false
      this.signedTransaction = false
    },
    makeUrlee (s) {
      const inFrame = window !== window.top
      const h = inFrame ? 'https://coins.room-house.com' : this.getParentOrigin()
      const reh = /https:\/\//gi
      const hh = h.replace(reh, '')
      const poh = hh.split(':')
      const hhh = hh.split('.')
      const checkerPort = (hhh[0] === 'aspen' || hhh[0] === 'cube' || hhh[0] === 'coins') ? '' : ':8453'
      const genc = (hhh[0] === 'dussel' || hhh[0] === 'coins') ? '' : '/genc'
      const u = 'https://' + poh[0] + checkerPort + '/cgi' + genc + '/' + s
      return u
    },
    reloadPage () {
      window.location.reload()
    },
    goToHist () {
      // unable to
      // window.location.href = window.location.hostname + '/hist'
      // this.$refs.swpLink.click()
    },
    failed (e) {
      this.score = e.score
      this.password = e.password
    },
    success (e) {
      this.score = e.score
      this.password = e.password
    },
    async getBalance () {
      if (!this.provider || !this.address) {
        return ''
      }
      let provider = this.provider
      let balance = await provider.getBalance(this.address)
      return balance
    },
    async getNonce () {
      if (!this.provider || !this.address) {
        return ''
      }
      let provider = this.provider
      let nonce = await provider.getTransactionCount(this.address)
      return nonce
    },
    async importWallet () {
      if (this.walletType === '1') {
        if (!this.isKeystoreJsonValid) {
          this.notify({ text: 'Please check out keystore.json!', class: 'is-danger' })
          return
        }
        if (!this.password) {
          this.notify({ text: 'Please enter password!', class: 'is-danger' })
          return
        }
        if (this.score < 3) {
          this.notify({ text: 'Password is not strong, please change!', class: 'is-danger' })
          return
        }

        this.working = true

        window.setTimeout(function () {
          yoethwallet.wallet.fromV3String(this.keystoreJson, this.password, (err, keystore) => {
            if (!this.working) {
              return
            }
            this.working = false
            if (err) {
              this.notify({ text: 'Please enter valid keystore json!', class: 'is-danger' })
              console.warn(err.message)
              return
            }

            let wallet = keystore

            this.keystore = wallet
            this.address = wallet.getHexAddress(true)
            this.notify({ text: 'Wallet import successfully!', class: 'is-info' })
          })
        }.bind(this), 100)
      } else if (this.walletType === '2' && this.metamaskProvider === null) {
        try {
          this.working = true
          const metamaskProvider = await detectEthereumProvider()
          if (metamaskProvider === window.ethereum) {
            this.metamaskProvider = metamaskProvider
            this.chainId = await metamaskProvider.request({ method: 'eth_chainId' })
            const accounts = await metamaskProvider.request({ method: 'eth_requestAccounts' })
            this.handleAccountsChange(accounts)
            // register events
            metamaskProvider.on('chainChanged', function (chainId) {
              window.location.reload()
            })
            metamaskProvider.on('accountsChanged', this.handleAccountsChange)
            this.notify({ text: 'Wallet connect successfully!', class: 'is-info' })
          }
        } catch (err) {
          console.warn(err.message)
        } finally {
          this.working = false
        }
      } else if (this.walletType === '3') {
        try {
          this.working = true
          let transport = await LedgerTransportWebUSB.create()
          const ledgerApp = new LedgerEtherApp(transport)
          const { address } = await ledgerApp.getAddress(this.path, true)
          this.address = address
          this.ledgerApp = ledgerApp
          this.notify({ text: 'Wallet connect successfully!', class: 'is-info' })
        } catch (err) {
          if (!navigator.usb) {
            this.notify({ text: 'Please use chromium based browser!', class: 'is-danger' })
          } else {
            this.notify({ text: 'Please make sure eth app was installed and started!', class: 'is-danger' })
          }
          console.warn(err.message)
        } finally {
          this.working = false
        }
      }
    },
    readKeystoreJsonFile (e) {
      var files = e.target.files

      if (files.length > 1) {
        this.notify({ text: 'Please choose only one file!', class: 'is-danger' })
        return
      }
      if (!/(.*)\.json/.test(files[0].name)) {
        this.notify({ text: 'Please choose valid keystore json!', class: 'is-danger' })
        return
      }
      var reader = new FileReader()

      reader.onload = function (e) {
        this.keystoreJson = e.target.result
      }.bind(this)

      reader.onerror = function (e) {
        this.notify({ text: 'Something wrong happened!', class: 'is-danger' })
      }.bind(this)

      reader.readAsText(files[0])
    },
    newProvider () {
      let provider = new ethers.providers.JsonRpcProvider(this.host)
      return provider
    },
    getParentOrigin () {
      const locationAreDistinct = (window.location !== window.parent.location)
      const parentOrigin = ((locationAreDistinct ? document.referrer : document.location) || '').toString()
      if (parentOrigin) {
        return new URL(parentOrigin).origin
      }
      const currentLocation = document.location
      if (currentLocation.ancestorOrigins && currentLocation.ancestorOrigins.length) {
        return currentLocation.ancestorOrigins[0]
      }
      return ''
    },
    async checkIt () {
      if (this.shipped || this.api_checked) {
        return
      }
      const { getInstance: Api } = Connector
      Api().on('connect', async (api) => {
        if (!this.api_checked) {
          const { nonce } = await api.query.system.account(this.spAddress)
          if (nonce && nonce.words && nonce.words[0]) {
            this.api_checked = true
            return true
          }
        }
        this.api_checked = true
        return false
      })
      Api().on('error', async () => {
        // console.log('CheckIt error', error)
        return false
      })
      Api().connect(this.apiUrl)
    },
    async setCoo () {
      const urlee = this.makeUrlee('action_vw')
      fetch(urlee).then((response) => response.json()).then((result) => {
        console.log('set session', result)
      }).catch(function (err) { console.log('Error', err) })
    },
    async setBal () {
      let balance = await this.getBalance()
      this.balance = balance.toString(10)
    },
    async setAvail () {
      this.avail = '..checking..'
      this.ticker = ''
      const { getInstance: Api } = Connector
      Api().on('connect', async (api) => {
        let { data: balance, nonce: previousNonce } = await api.query.system.account(this.spXETR)
        if (previousNonce && previousNonce.words && previousNonce.words[0]) {
          this.avail = (parseInt(balance.free) - parseInt(balance.miscFrozen)) / 1000000000000
          this.ticker = 'RHC'
          return true
        }
        this.api_checked = true
        return false
      })
      Api().on('error', async (error) => {
        console.log('setAvail error', error)
        return false
      })
      Api().connect(this.apiUrl)
    },
    async shipIt (txId) {
      if (this.shipped) {
        return
      }
      // console.log('shipped: this val is', this.val / 1000000000000000000)
      const { getInstance: Api } = Connector
      Api().on('connect', async (api) => {
        if (!this.shipped) {
          // transfer (this.val / 250000) to this.spAddress and inform History
          this.shipped = true
        }
      })
      Api().on('error', async () => {
        // console.log('[API] error', error)
        return false
      })
      Api().connect(this.apiUrl)
    },
    async mapAccounts () {
      try {
        keyring.loadAll({
          ss58Format: 42,
          type: 'sr25519',
          isDevelopment: false
        })
      } catch (err) { /* console.log('keyring already loaded') */ }
      this.keyringLoaded = true
    },
    async signTransaction () {
      if (this.shipped) {
        return
      }
      if (!this.host) {
        this.notify({ text: 'Please enter host!', class: 'is-danger' })
        return
      }
      if (!this.spAddress || !this.isSPAddressValid) {
        this.notify({ text: 'Please enter correct SkyRHC address!', class: 'is-danger' })
        return
      }
      let v = this.isHex(this.val) ? parseInt(this.val, 16) : parseInt(this.val)
      // console.log('val is', this.val, 'avail is', this.avail, 'bal is', this.balance)
      // const lim = 1000
      /* if (this.val > lim * 1000000000000000000) {
        this.notify({ text: 'Maximum ' + lim + ' coins swap!', class: 'is-danger' })
        return
      } */
      if (this.val > this.avail * 1000000000000000000) {
        this.notify({ text: 'Available for swap only ' + this.avail + '!', class: 'is-danger' })
        return
      }
      let balu = this.balance - this.gasPrice * this.gasLimit
      if (this.val > balu) {
        balu = balu / 1000000000000000000
        this.notify({ text: 'Cannot swap more than ' + balu + '!', class: 'is-danger' })
        return
      }
      if (v === 0 || this.val === '') {
        this.notify({ text: 'Value to swap cannot be 0!', class: 'is-danger' })
        return
      }
      let txParams = {
        from: this.address,
        to: this.toAddress,
        chainId: this.chainId,
        nonce: this.nonce,
        value: this.isHex(this.val) ? this.val : parseInt(this.val),
        gasPrice: this.isHex(this.gasPrice) ? this.gasPrice : parseInt(this.gasPrice),
        gasLimit: this.isHex(this.gasLimit) ? this.gasLimit : parseInt(this.gasLimit)
      }
      if (this.isHex(this.data)) {
        txParams.data = this.data
      }
      let valueTx = yoethwallet.tx.valueTx(txParams)

      if (this.isImportJSON) {
        valueTx.sign(this.keystore.getPrivateKey())

        this.signedTransaction = '0x' + valueTx.serialize().toString('hex')
      } else if (this.isLedger) {
        valueTx.v = this.chainId
        const sig = await this.ledgerApp.signTransaction(this.path, valueTx.serialize().toString('hex'))
        valueTx.v = '0x' + sig.v
        valueTx.r = '0x' + sig.r
        valueTx.s = '0x' + sig.s
        this.signedTransaction = '0x' + valueTx.serialize().toString('hex')
      } else if (this.isMetamask) {
        // this.signedTransaction = '0x1'.toString('hex')
      }
    },
    async sendTransaction () {
      if (this.shipped) {
        return
      }
      if (this.isImportJSON) {
        if (!this.host) {
          this.notify({ text: 'Please enter host!', class: 'is-danger' })
          return
        }
        if (!this.signedTransaction) {
          this.notify({ text: 'Please sign transaction first!', class: 'is-danger' })
          return
        }
      }
      this.send = true
      const ret = this.checkIt()
      if (!ret) {
        this.notify({ text: 'No connection to SkyRHC!', class: 'is-danger' })
        return
      }

      const provider = (this.isMetamask) ? this.metamaskProvider : this.provider
      try {
        let txId = ''

        // seed vw_sessions
        this.host = (this.isMetamask) ? 'https://africa.room-house.com' : this.host // hack ash
        let fData = new FormData()
        fData.append('pass', 'lol')
        fData.append('addr', this.address)
        fData.append('acc_id', this.spAddress)
        fData.append('rpc_server', this.host)
        const urleeSessions = this.makeUrlee('tester_vw.pl')

        await fetch(urleeSessions, {body: fData, method: 'post', credentials: 'include'})
        .then((response) => response.json())
        .then((result) => {
          if (result.result.toString() === 'OK') {
            console.log('Seed vw_sessions', result)
            this.badRpcCall = false
          } else {
            console.log('Connect to RPC server', result)
            this.send = false
            this.signedTransaction = ''
            this.notify({ text: 'Connect to RPC server failed! Try again', class: 'is-danger' })
            throw new TypeError('RPC err')
          }
        })
        .catch((err) => { console.log('Fetch fData Error', err); this.badRpcCall = true; return })

        if (this.isBadRpcCall) return

        if (this.isMetamask) {
          let txParams = {
            from: this.address,
            to: this.toAddress,
            value: this.isHex(this.val) ? this.val : '0x' + (new BigNumber(this.val)).toString(16),
            gasPrice: this.isHex(this.gasPrice) ? this.gasPrice : '0x' + (new BigNumber(this.gasPrice)).toString(16),
            gas: this.isHex(this.gasLimit) ? this.gasLimit : '0x' + (new BigNumber(this.gasLimit)).toString(16)
          }
          if (this.isHex(this.data)) {
            txParams.data = this.data
          }
          txId = await this.metamaskProvider.request({ method: 'eth_sendTransaction', params: [ txParams ] })
          this.send = true
        } else {
          txId = await provider.send('eth_sendRawTransaction', [ this.signedTransaction ])
        }
        this.result = txId
        if (!this.isImportJSON) {
          // provider.getTransactionReceipt(txId).then((receipt) => {
          this.notify({ text: 'Transaction submitted! Please await .. working..', class: 'is-info' })
          // const receipt = await this.metamaskProvider.request({ method: 'eth_getTransactionReceipt', params: [ txId ] })
          let receipt = null
          while (!receipt) receipt = await provider.send('eth_getTransactionReceipt', [ txId ])
          while (!receipt.result) receipt = await provider.send('eth_getTransactionReceipt', [ txId ])
          console.log('receipt', receipt.result)
          if (parseInt(receipt.result.status, 16) === 1) {
            this.setBal()
            let formData = new FormData()
            formData.append('pass', 'lol')
            formData.append('txhash', receipt.result.transactionHash)
            formData.append('addr', this.address)
            formData.append('rpc_server', this.host)

            fetch(urleeSessions, {body: formData, method: 'post', credentials: 'include'})
            .then((response) => response.json())
            .then((result) => { console.log('Update vw_sessions', result); this.send = false; this.shipped = true; this.notify({ text: 'Transaction confirmed!', class: 'is-info' }); this.setAvail(); this.setBal() })
            .catch(function (err) { console.log('Fetch fData Error', err); this.send = false; this.signedTransaction = ''; return })
          } else {
            this.notify({ text: 'Transaction failed!', class: 'is-danger' })
            this.send = false
            this.signedTransaction = ''
            this.shipped = false
          }
          return
          // })
        }
        confirmedTransaction(provider, txId, 1, function (err, tx) {
          // const v = this.isHex(this.val) ? new BigNumber(parseInt(this.val, 16)) : new BigNumber(parseInt(this.val))
          this.setBal()
          let formData = new FormData()
          formData.append('pass', 'lol')
          formData.append('txhash', txId)
          formData.append('addr', this.address)
          formData.append('rpc_server', this.host)

          fetch(urleeSessions, {body: formData, method: 'post', credentials: 'include'})
          .then((response) => response.json())
          .then((result) => { console.log('Update vw_sessions', result); this.send = false; this.shipped = true; this.setAvail() })
          .catch(function (err) { console.log('Fetch fData Error', err) })

          if (err) {
            this.notify({ text: 'Please send transaction again!', class: 'is-danger' })
            console.warn(err.message)
            this.send = false
            this.signedTransaction = ''
            return
          } else {
            // if (!this.shipped) this.shipIt(txId)
          }
          this.notify({ text: 'Transaction confirmed! Please await .. working..', class: 'is-info' })
        }.bind(this))
      } catch (err) {
        this.send = false
        this.signedTransaction = ''
        this.shipped = false
        this.notify({ text: 'Probably low funds? Please SIGN transaction again!', class: 'is-danger' })
        console.warn(err.message)
        return
      }
    },
    resetProvider () {
      if (this.provider) {
        this.provider = {}
      }
    },
    selectHost (e) {
      let host = config.hosts[e.target.value]

      this.host = host.rpcUri
      this.explorer = host.explorerUri
      this.chainId = host.chainId
    },
    isHex (s) {
      if (typeof s !== 'string') {
        return false
      }
      return /^0x[0-9a-f]+/.test(s.toLowerCase())
    },
    async handleAccountsChange (accounts) {
      if (accounts.length === 0) {
        this.notify({ text: 'Please connect to MetaMask!', class: 'is-danger' })
      } else if (accounts[0] !== this.address) {
        this.address = accounts[0]
        this.nonce = await this.metamaskProvider.request({ method: 'eth_getTransactionCount', params: [ accounts[0] ] })
        this.balance = await this.metamaskProvider.request({ method: 'eth_getBalance', params: [ accounts[0] ] })
      }
    },
    ...mapActions([
      'notify'
    ])
  },
  watch: {
    async host (val, oval) {
      if (this.isHostValid) {
        // clean old state
        this.nonce = '0'
        this.balance = '0'
        try {
          this.provider = this.newProvider()
          this.nonce = await this.getNonce()
          let balance = await this.getBalance()
          this.balance = balance.toString(10)
        } catch (err) {
          console.warn(err.message)
        }
      }
    }
  }
}
</script>
