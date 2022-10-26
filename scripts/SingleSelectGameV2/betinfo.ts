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

    const betInfo = await c.getBetInfo('0x4abe466a27b1b5d13484f3135b45f21647ebcda01490c61d5c8e5fbd35ca96a1')
    console.log(betInfo)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
