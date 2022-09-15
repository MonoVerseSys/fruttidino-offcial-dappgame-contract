import { HardhatUserConfig, task } from 'hardhat/config'
import '@nomicfoundation/hardhat-toolbox'
import '@openzeppelin/hardhat-upgrades'
import dotenv from 'dotenv'

dotenv.config()

const { mnemonic, mnemonicReal } = process.env

task('accounts', 'Prints the list of accounts', async (taskArgs, hre) => {
    const accounts = await hre.ethers.getSigners()

    for (const account of accounts) {
        const balance = await hre.ethers.provider.getBalance(account.address)

        console.log(account.address, ':', hre.ethers.utils.formatUnits(balance, 'ether'))
    }
})

task('accounts2', 'Prints the list of accounts', async (taskArgs, hre) => {
    const accounts = await hre.ethers.getSigners()

    for (const [index, account] of accounts.entries()) {
        const wallet = hre.ethers.Wallet.fromMnemonic(mnemonic ?? '', `m/44'/60'/0'/0/${index}`)
        const balance = await hre.ethers.provider.getBalance(wallet.address)
        console.log(account.address, ':', hre.ethers.utils.formatUnits(balance, 'ether'), wallet.privateKey)
    }
})

task('transfer', 'transfer coin', async (taskArgs, hre) => {
    const accounts = await hre.ethers.getSigners()

    const receipt = await accounts[0].sendTransaction({ to: '0x671cF5Eb5c3Eb9ca0E6dE90DB60DcfA71224D7F1', value: hre.ethers.utils.parseEther('0.5') })
    console.log(receipt)
    const tx = await receipt.wait()
    console.log(tx)
})

const config: HardhatUserConfig = {
    solidity: '0.8.9',
    networks: {
        local: {
            url: 'http://127.0.0.1:8545/',
        },
        bsctest: {
            url: `https://data-seed-prebsc-1-s1.binance.org:8545/`,
            accounts: { mnemonic: mnemonic },
            gas: 2100000,
            gasPrice: 'auto',
        },
        bsc: {
            url: `https://bsc-dataseed.binance.org/`,
            accounts: { mnemonic: mnemonicReal },
            gas: 2100000,
            gasPrice: 'auto',
        },
    },
}

export default config
