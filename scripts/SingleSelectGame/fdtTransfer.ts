import { ethers } from 'hardhat'
import * as utils from '../utils'
import { Config } from '../utils'
import configJson from './_config.json'
const config: Config = configJson
async function main() {
    // const amount = ethers.utils.parseEther('0.01')

    const network = utils.getNetwork()
    const gameContractAddress = config.networks[network]

    let erc20Address = ''
    if (network === 'bsctest') {
        erc20Address = '0x4E44CF15A450c402E3a532f78182c919D7fE908C'
    } else if (network === 'bsc') {
        erc20Address = '0x3a599e584075065eAAAc768D75EaEf85c2f2fF64'
    }

    const signers = await utils.singers()
    const fdt = await ethers.getContractAt('IERC20', erc20Address, signers[0])
    const receipt = await fdt.transfer('0x671cF5Eb5c3Eb9ca0E6dE90DB60DcfA71224D7F1', ethers.utils.parseEther('10000'))
    console.log(receipt)
    const tx = await receipt.wait()
    console.log(tx)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
