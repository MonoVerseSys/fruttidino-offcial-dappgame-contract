import { ethers } from 'hardhat'
import * as utils from '../utils'
import { Config } from '../utils'
import configJson from './_config.json'
const config: Config = configJson
async function main() {
    const c = await utils.attach({
        contractName: 'SingleSelectGame',
        deployedAddress: config.networks[utils.getNetwork()],
    })
    const signers = await utils.singers()
    const filter = c.filters.RequestBet()
    // console.log(filter)

    const events = await c.queryFilter(filter, -1000, 'latest')
    console.log(events)

    const betInfo = await c.getBetInfo('0x40fde8fc59ecb4c626bf0c26e1a972c9721dd889fb290782737847388e286d2e')
    console.log(betInfo)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
