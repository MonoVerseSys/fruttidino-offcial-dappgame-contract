import { ethers } from 'hardhat'
import * as utils from '../utils'
async function main() {
    const signers = await utils.singers()
    await utils.deployProxy({
        contractName: 'SingleSelectGameV2',
        deployParams: [signers[0].address],
    })
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
