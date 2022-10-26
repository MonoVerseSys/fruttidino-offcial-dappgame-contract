import { ethers } from 'hardhat'
import * as utils from '../utils'
import { Config } from '../utils'
import configJson from './_config.json'

import configJson2 from '../SingleSelectGameV2/_config.json'

const config: Config = configJson
const config2: Config = configJson2

async function main() {
    const c = await utils.attach({
        contractName: config.contractName,
        deployedAddress: config.networks[utils.getNetwork()],
    })

    const receipt = await c.getRandomInfo(ethers.BigNumber.from('83027676651409085075612638837889067302076173298715257648671145115978923548289').toHexString())
    console.log('receipt:', receipt)

    // const [req, res, randoms] = receipt

    // // console.log(res)
    // console.log(res.seed)
    // console.log(res.randomNumbers[0].toString())

    // const c2 = await utils.attach({
    //     contractName: config2.contractName,
    //     deployedAddress: config2.networks[utils.getNetwork()],
    // })
    // const receipt2 = await c2.getBetInfo('0x455bbe1cd8e8f51a26da836d4e619803f2addbf43c26424f8f5bc57187933775')
    // console.log('receipt2:', receipt2)
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
