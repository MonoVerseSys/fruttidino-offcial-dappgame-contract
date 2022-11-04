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

    const result = await c.getWinnerList()
    // console.log(result)
    for (let winner of result) {
        const strUser = ethers.utils.parseBytes32String(winner[0])
        console.log(strUser, ', ', winner[1].toNumber())
    }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
