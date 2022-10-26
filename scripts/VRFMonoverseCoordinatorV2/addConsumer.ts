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
    // const signers = await utils.singers()
    const receipt = await c.addConsumer('0xd04ec6e054342dD0ff74683e938Ed30361B63f1d')
    console.log(receipt)
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
