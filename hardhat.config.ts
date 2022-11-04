import { HardhatUserConfig, task } from 'hardhat/config'
import '@nomicfoundation/hardhat-toolbox'
import '@openzeppelin/hardhat-upgrades'
import 'hardhat-gas-reporter'

import dotenv from 'dotenv'

dotenv.config()

const { mnemonic, mnemonicReal, mnemonicDeadCat, prodMnemonic, scanKey } = process.env

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
    const receipt = await accounts[1].sendTransaction({
        to: accounts[0].address,
        value: hre.ethers.utils.parseEther('0.5'),
    })
    console.log(receipt)
    const tx = await receipt.wait()
    console.log(tx)
})

const config: HardhatUserConfig = {
    solidity: {
        version: '0.8.9',
        settings: {
            optimizer: {
                enabled: true,
                runs: 200,
            },
        },
    },
    networks: {
        local: {
            url: 'http://127.0.0.1:8545/',
        },
        bsctest: {
            url: `https://data-seed-prebsc-1-s1.binance.org:8545/`,
            accounts: { mnemonic: mnemonic },
            gas: 2100000,
            // gasPrice: 5000000000,
            gasPrice: 'auto',
        },
        bsc: {
            url: `https://bsc-dataseed.binance.org/`,
            accounts: { mnemonic: prodMnemonic },
            gas: 2100000,
            // gasPrice: 5000000000,
        },
        deadcat: {
            url: 'http://52.78.81.195:16812',
            accounts: { mnemonic: mnemonicDeadCat, count: 40 },

            gas: 'auto',
            gasPrice: 'auto',
        },
    },
    etherscan: {
        apiKey: scanKey,
    },
}

export default config
