import { ethers } from 'hardhat'
import * as utils from '../utils'
import { Config } from '../utils'
import configJson from './_config.json'
const config: Config = configJson
async function main() {
    const c = await utils.attach({
        contractName: 'VRFMonoverseCoordinator',
        deployedAddress: config.networks[utils.getNetwork()],
    })
    // const signers = await utils.singers()
    const receipt = await c.addConsumer('0xdD95faC2D0c807A3CC7F93D6179187C200CDD4D3')
    console.log(receipt)
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
