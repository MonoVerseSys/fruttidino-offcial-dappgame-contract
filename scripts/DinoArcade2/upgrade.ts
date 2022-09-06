import { ethers } from 'hardhat'
import * as utils from '../utils'
import { Config } from '../utils'
import configJson from './_config.json'
const config: Config = configJson

async function main() {
    await utils.upgradeProxy({
        contractName: 'DinoArcade',
        deployedAddress: config.networks[utils.getNetwork()],
    })
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
