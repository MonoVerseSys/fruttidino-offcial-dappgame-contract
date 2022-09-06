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
    const receipt = await c.betCoin({ value: ethers.utils.parseEther('0.01') })
    console.log(receipt)

    const tx = await receipt.wait()

    console.log(tx)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
