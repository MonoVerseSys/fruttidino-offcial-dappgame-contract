import { ethers } from 'hardhat'
import * as utils from '../utils'
import { Config } from '../utils'
import configJson from './_config.json'
const config: Config = configJson
async function main() {
    const c = await utils.attach({
        contractName: config.contractName,
        deployedAddress: config.networks[utils.getNetwork()],
    })
    let amount = ethers.utils.parseEther('0.002')
    let successAmt = amount.mul(ethers.BigNumber.from('192')).div(ethers.BigNumber.from('100'))

    const contractBalance = await ethers.provider.getBalance(config.networks[utils.getNetwork()])
    console.log(`contractBalance: ${ethers.utils.formatEther(contractBalance)}`)
    console.log(`successAmt: ${ethers.utils.formatEther(successAmt)}`)
    // if (true) return
    if (contractBalance.gte(successAmt)) {
        const receipt = await c.betCoin([1], '0x7f0be27b1b1f25eb3b1cb7a6d00a444a4f501a7e7f0ed8b8f8f3e2a8425be58c', { value: amount })
        console.log(receipt)
        const tx = await receipt.wait()
        console.log(JSON.stringify(tx, null, 2))

        const iface = new ethers.utils.Interface(['event Request(address indexed consumer, uint256 requestId,bytes32 seedHash)'])
        const decodeEvent = iface.parseLog({ data: tx.events[0].data, topics: tx.events[0].topics })
        console.log('decodeEvent: ', decodeEvent)

        console.log(`req id : `, decodeEvent.args.requestId.toHexString())
        console.log(`seed hash : `, decodeEvent.args.seedHash)
    } else {
        console.error('계약 잔액부족')
    }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
