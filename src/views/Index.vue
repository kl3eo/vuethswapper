<template>
  <div class="container">
    <h1 class="title">Swap EXP or CLO to RHC 1:1</h1>

    <p><strong>EXP or CLO</strong> Swap to <strong>RHC</strong> Instructions:</p>
    <div>&nbsp;</div>
    <p>1. Create a new account with "<strong>Create Wallet</strong>" menu in this page (see "<strong>Wallet Actions</strong>" above).</p>
    <p>2. Get a strong password, with no white space: for example, "OrchiLiveStreamCluster" is good. Click "<strong>Generate Wallet</strong>" and wait the red "<strong>Download</strong>" button. Click to save your new account as a JSON file.</p>
    <p>3. Make sure that you can import this file in "<strong>Import Wallet</strong>" menu.
    <p>4. Send some EXP or CLO to your new account from another account using your favorite wallet, an amount you intend to swap plus gas ~ 0.001 just enough for 1-2 transactions.</p>
    <p>5. You need a Substrate account to receive the swapped RHC. Please use our <a href='https://wallet.room-house.com' target=new>Light Wallet</a> or our <a href='https://skypirl.net' target=new>Explorer</a> to create a new Substrate account, or restore from file.</p>
    <p>6. Click "<strong>Sign Transaction</strong>", then "<strong>Send Transaction</strong>", - or "<strong>Cancel</strong>"; wait until you see "<strong>Swap Complete</strong>". Check you've received the swap (see "<strong>Swap History</strong>" above).</p>
    <p>7. Proceed doing steps 4-6, until you've swapped as much as you like. Have a nice day! </p>
  </div>
</template>

<script>
export default {
  name: 'index'
}
</script>

<style>
.panel-block .column {
  padding-left: 1rem;
  padding-right: 1rem;
}
</style>
