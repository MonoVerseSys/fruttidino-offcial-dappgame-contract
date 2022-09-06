import { ethers } from 'hardhat'
import * as utils from '../utils'
async function main() {
    await utils.deployProxy({
        contractName: 'DinoArcade2',
        deployParams: ['1772'],
    })
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
