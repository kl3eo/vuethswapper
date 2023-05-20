const args = require('minimist')(process.argv.slice(2))
const th_arg = args['th']
const server = args['server']

async function main () {
const Web3 = require('web3')
const web3 = server === 'https://rpc.callisto.network' ? new Web3(new Web3.providers.HttpProvider('https://rpc.callisto.network')) : new Web3(new Web3.providers.HttpProvider('https://node.expanse.tech'))

const A = "0x" + String(th_arg)
const j = await web3.eth.getTransaction(A);
console.log(j.from.toLowerCase() + '#' + j.value);
}

main().catch(console.error)
