const args = require('minimist')(process.argv.slice(1))
const server = args['server']

async function main () {
const Web3 = require('web3')
const web3 = server === 'https://rpc.callisto.network' ? new Web3(new Web3.providers.HttpProvider('https://rpc.callisto.network')) : new Web3(new Web3.providers.HttpProvider('https://node.expanse.tech'))

web3.eth.getBlockNumber()
.then(console.log)
}

main().catch(console.error)
