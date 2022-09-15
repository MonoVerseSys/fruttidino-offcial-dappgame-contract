import { ethers } from 'hardhat'
import * as utils from '../utils'
import { Config } from '../utils'
import configJson from './_config.json'
const config: Config = configJson
async function main() {
    // const amount = ethers.utils.parseEther('0.01')

    const gameContractAddress = config.networks[utils.getNetwork()]
    // const c = await utils.attach({
    //     contractName: 'c',
    //     deployedAddress: gameContractAddress,
    // })

    const network = utils.getNetwork()
    let erc20Address = ''
    if (network === 'bsctest') {
        erc20Address = '0x4E44CF15A450c402E3a532f78182c919D7fE908C'
    } else if (network === 'bsc') {
        erc20Address = '0x3a599e584075065eAAAc768D75EaEf85c2f2fF64'
    }

    const signers = await utils.singers()
    const fdt = await ethers.getContractAt('FdtToken', erc20Address, signers[0])
    // console.log(fdt)
    let betAmount = ethers.utils.parseEther('1')
    const data = ethers.utils.defaultAbiCoder.encode(['uint256[]'], [[1, 2, 3, 4, 5, 6, 7]])
    // const data2 = ethers.utils.solidityPack(['uint256[]'], [[1, 2, 3]])
    console.log(data)
    // console.log(fdt['transferAndCall(address,uint256,bytes)'])
    const receipt = await fdt['transferAndCall(address,uint256,bytes)'](gameContractAddress, betAmount, data)
    console.log(receipt)
    const result = await receipt.wait()
    console.log(result)

    // let betAmount = ethers.utils.parseEther('1')

    // const allowance = await fdt.allowance(signers[0].address, gameContractAddress)

    // console.log(`betAmount: ${ethers.utils.formatEther(betAmount)}`)
    // console.log(`allowance: ${ethers.utils.formatEther(allowance)}`)

    // const balance = await fdt.balanceOf(signers[0].address)
    // console.log(`user balance : ${signers[0].address}, balance: ${ethers.utils.formatEther(balance)}`)

    // if (allowance.lt(betAmount)) {
    //     console.error('토큰 허용금액 부족')
    //     console.error('allowance start~!')
    //     const receipt = await fdt.approve(gameContractAddress, betAmount)
    //     console.log('allowance receipt:', receipt)
    //     const tx = await receipt.wait()
    //     console.log('allowance tx:', tx)
    // }
    // // 1 ~ 2
    // const receipt = await c.betFdt(betAmount, [1, 2, 3, 4, 5, 6, 7])
    // console.log('bet receipt: ', receipt)
    // const tx = await receipt.wait()
    // console.log('bet tx:', tx)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
