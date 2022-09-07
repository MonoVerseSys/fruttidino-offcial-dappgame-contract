import { ethers } from 'hardhat'
import * as utils from '../utils'
import { Config } from '../utils'
import configJson from './_config.json'
const config: Config = configJson
async function main() {
    // const amount = ethers.utils.parseEther('0.01')

    const gameContractAddress = config.networks[utils.getNetwork()]
    const c = await utils.attach({
        contractName: 'DinoArcade',
        deployedAddress: gameContractAddress,
    })

    const network = utils.getNetwork()
    let erc20Address = ''
    if (network === 'bsctest') {
        erc20Address = '0x474A423Fe3b530894c4dCe0ce61Ea38Ab0E157c7'
    } else if (network === 'bsc') {
        erc20Address = '0x3a599e584075065eAAAc768D75EaEf85c2f2fF64'
    }

    const signers = await utils.singers()
    const fdt = await ethers.getContractAt('IERC20', erc20Address, signers[0])
    let betAmount = ethers.utils.parseEther('1')

    const allowance = await fdt.allowance(signers[0].address, gameContractAddress)

    console.log(`betAmount: ${ethers.utils.formatEther(betAmount)}`)
    console.log(`allowance: ${ethers.utils.formatEther(allowance)}`)

    const balance = await fdt.balanceOf(signers[0].address)
    console.log(`user balance : ${signers[0].address}, balance: ${ethers.utils.formatEther(balance)}`)

    if (allowance.lt(betAmount)) {
        console.error('토큰 허용금액 부족')
        console.error('allowance start~!')
        const receipt = await fdt.approve(gameContractAddress, betAmount)
        console.log('allowance receipt:', receipt)
        const tx = await receipt.wait()
        console.log('allowance tx:', tx)
    }

    const receipt = await c.betFdt(betAmount)
    console.log('bet receipt: ', receipt)
    const tx = await receipt.wait()
    console.log('bet tx:', tx)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
