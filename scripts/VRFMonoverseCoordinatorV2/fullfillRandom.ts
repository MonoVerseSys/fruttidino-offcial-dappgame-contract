import { ethers } from 'hardhat'
import * as utils from '../utils'
import { Config } from '../utils'
import configJson from './_config.json'

const config: Config = configJson
async function main() {
    const contract = await utils.attach({
        contractName: config.contractName,
        deployedAddress: config.networks[utils.getNetwork()],
    })
    const reqId = '0x4af03bdf2173272d84728e07e22823cf64184a9f5737013f71a30c0743120d6e'
    const seed = '0x7769634a484c4b4b44546c436b5446566147616752706e44526a6b5559780000'

    const receipt = await contract.fulfillRandomWords(seed, reqId)
    console.log(receipt)

    const tx = await receipt.wait()
    console.log(JSON.stringify(tx, null, 2))
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
