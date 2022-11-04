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

    const reqId = ethers.BigNumber.from('58948494706942145145901428145639236855532918425781142424945975019605760219979').toHexString()
    console.log(`reqId to Hex : ${reqId}`)
    const receipt = await c.getRandomInfo(reqId)
    console.log('receipt:', receipt)

    const req = receipt[0] // request
    const res = receipt[1] // response
    const ran = receipt[2] // ran
    console.log('seed hash1 ', req.seedHash)
    console.log('seed hash2 ', ethers.utils.keccak256(res.seed))
    console.log('seed ', ethers.utils.parseBytes32String(res.seed))

    // const inputData = ethers.utils.defaultAbiCoder.encode(['uint256', 'bytes32', 'uint256'], [reqId, res.seed, 0])
    // const randomHash = ethers.utils.keccak256(inputData)
    // console.log(ethers.BigNumber.from(randomHash))
    // console.log('random: ', ethers.BigNumber.from(randomHash).mod(2).toNumber() + 1)
    // const [req, res, randoms] = receipt

    console.log(`(1)Pre-disclosure seed hash value: ${req.seedHash}`)
    console.log(`(2)game request id\nkeccak256(consumer address + nonce + block.timestamp): ${reqId}`)
    console.log(`(3)Seed Source: ${ethers.utils.parseBytes32String(res.seed)}`)
    console.log(`(4)Seed to bytes32: ${res.seed}`)
    console.log(`(5)Seed Validation = Check to match item(1) = keccak256(Seed bytes32)`, ethers.utils.keccak256(res.seed))
    console.log(req.seedHash, ethers.utils.keccak256(res.seed), req.seedHash === ethers.utils.keccak256(res.seed))

    console.log(`seed to random value : keccak256((2) + (4) + index) => (number mod 2) + 1 `)
    const inputData = ethers.utils.defaultAbiCoder.encode(['uint256', 'bytes32', 'uint256'], [reqId, res.seed, 0])
    const randomHash = ethers.utils.keccak256(inputData)
    console.log('result:', ethers.BigNumber.from(randomHash).mod(2).toNumber() + 1)

    // // console.log(res)
    // console.log(res.seed)
    // console.log(res.randomNumbers[0].toString())

    // const c2 = await utils.attach({
    //     contractName: config2.contractName,
    //     deployedAddress: config2.networks[utils.getNetwork()],
    // })
    // const receipt2 = await c2.getBetInfo('0x455bbe1cd8e8f51a26da836d4e619803f2addbf43c26424f8f5bc57187933775')
    // console.log('receipt2:', receipt2)

    const bytes32 = ethers.utils.formatBytes32String('BcIvfVBCsaWLrBqAYNzgTLLpUiHohh1')
    console.log(`bytes32: ${bytes32}`)
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
