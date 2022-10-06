import { ethers } from 'hardhat'
import * as utils from '../utils'
import { Config } from '../utils'
import configJson from './_config.json'
const config: Config = configJson
async function main() {
    // const amount = ethers.utils.parseEther('0.01')
    const successRate = ['7680', '3840', '2560', '1920', '1540', '1280', '1100', '960']

    const gameContractAddress = config.networks[utils.getNetwork()]

    const network = utils.getNetwork()
    let erc20Address = ''
    if (network === 'bsctest') {
        erc20Address = '0x4E44CF15A450c402E3a532f78182c919D7fE908C'
    } else if (network === 'bsc') {
        erc20Address = '0x3a599e584075065eAAAc768D75EaEf85c2f2fF64'
    }

    const signers = await utils.singers()

    const fdt = await ethers.getContractAt('FdtToken', erc20Address, signers[0])

    let betAmount = ethers.utils.parseEther('1')
    const gameFdtBalance = await fdt.balanceOf(gameContractAddress)
    const selected = [1, 3, 5, 7]

    const rate = ethers.BigNumber.from(successRate[selected.length - 1])
    const successAmt = rate.mul(betAmount).div(ethers.BigNumber.from('1000'))

    if (gameFdtBalance.lt(successAmt)) {
        console.error('잔액부족')
        return
    }

    const data = ethers.utils.defaultAbiCoder.encode(['uint256[]'], [selected])
    console.log(data)
    const receipt = await fdt['transferAndCall(address,uint256,bytes)'](gameContractAddress, betAmount, data)
    console.log(receipt)
    const result = await receipt.wait()
    console.log(result)
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
