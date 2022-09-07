import { ethers } from 'hardhat'
import * as utils from '../utils'
import { Config } from '../utils'
import configJson from './_config.json'
const config: Config = configJson
async function main() {
    const c = await utils.attach({
        contractName: 'DinoArcade',
        deployedAddress: config.networks[utils.getNetwork()],
    })
    let amount = ethers.utils.parseEther('0.002')
    let successAmt = amount.mul(ethers.BigNumber.from('197')).div(ethers.BigNumber.from('100'))

    const contractBalance = await ethers.provider.getBalance(config.networks[utils.getNetwork()])
    console.log(`contractBalance: ${ethers.utils.formatEther(contractBalance)}`)
    console.log(`successAmt: ${ethers.utils.formatEther(successAmt)}`)

    if (contractBalance.gte(successAmt)) {
        const receipt = await c.betCoin({ value: amount })
        console.log(receipt)
        const tx = await receipt.wait()
        console.log(JSON.stringify(tx, null, 2))
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
