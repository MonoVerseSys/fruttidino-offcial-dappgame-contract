import { ethers } from 'hardhat'
import * as utils from '../utils'
import { Config } from '../utils'
import configJson from './_config.json'
import keypair from '../VRF/key'
import BN from 'bn.js'

const config: Config = configJson
async function main() {
    const c = await utils.attach({
        contractName: config.contractName,
        deployedAddress: config.networks[utils.getNetwork()],
    })
    const signer = await utils.singers()
    const oracle = signer[1].address

    const receipt = await c.addOracle(oracle)

    console.log(receipt)

    const tx = await receipt.wait()
    console.log(tx)
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
