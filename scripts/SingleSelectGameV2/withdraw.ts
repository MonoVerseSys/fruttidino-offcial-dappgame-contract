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

    const [signer] = await utils.singers()

    const contractBalance = await ethers.provider.getBalance(config.networks[utils.getNetwork()])

    const receipt = await c.withdrawCoin(signer.address, contractBalance)
    console.log(receipt)
    const tx = await receipt.wait()
    console.log(JSON.stringify(tx, null, 2))
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
