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
    // const receipt = await c.testRandom('97665108619971693246135751978017107164006871042401342126403791944783020530062', ['2'])
    // console.log(receipt)

    // const tx = await receipt.wait()

    // console.log(tx)

    const r = await c.getRandom()
    console.log(r)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
