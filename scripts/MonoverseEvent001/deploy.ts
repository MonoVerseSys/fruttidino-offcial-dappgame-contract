import { ethers } from 'hardhat'
import * as utils from '../utils'
async function main() {
    const signers = await utils.singers()
    await utils.deploy({
        contractName: 'MonoverseEvent001',
        // deployParams: ['2092'], // teset net
        deployParams: ['595'], // main net
    })
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
