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

    const result = await c.getEventUsersLen()
    for (let i = 0; i < result.toNumber(); i++) {
        const user = await c.getEventUser(i)
        const strUser = ethers.utils.parseBytes32String(user)
        console.log(strUser)
    }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
