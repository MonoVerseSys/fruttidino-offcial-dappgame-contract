import { ethers, upgrades } from 'hardhat'
import fs from 'fs'
import path from 'path'
import { Contract } from 'ethers'
export interface DeployParams {
    contractName: string
    deployParams: any[]
}
export interface ContractAttach {
    deployedAddress: string
    contractName: string
}
export interface Config {
    contractName: string
    networks: { [key: string]: string }
}

const getNetwork = (): string => {
    return process.env.HARDHAT_NETWORK || 'local'
}
const writeConfig = (contractName: string, address: string) => {
    const filePath = path.join(__dirname, contractName, '_config.json')
    const net: string = getNetwork()
    if (fs.existsSync(filePath)) {
        const jsonData = fs.readFileSync(filePath, 'utf8')
        const config: Config = JSON.parse(jsonData) as Config
        config.networks[net] = address
        fs.writeFileSync(filePath, JSON.stringify(config, null, 2))
    } else {
        const config: Config = {
            contractName,
            networks: {
                [net]: address,
            },
        }
        fs.writeFileSync(filePath, JSON.stringify(config, null, 2))
    }
}

const deploy = async (params: DeployParams) => {
    const C = await ethers.getContractFactory(params.contractName)
    console.log(C.deploy)
    const c = await C.deploy.apply(C, params.deployParams)

    const result = await c.deployed()
    console.log(`deployed result ${params.contractName}:`, result, result.address)

    writeConfig(params.contractName, result.address)
}

const deployProxy = async (params: DeployParams) => {
    const C = await ethers.getContractFactory(params.contractName)
    const c = await upgrades.deployProxy(C, params.deployParams)
    const result = await c.deployed()

    console.log(`deployed proxy result ${params.contractName}:`, result, result.address)
    writeConfig(params.contractName, result.address)
}

const upgradeProxy = async (params: ContractAttach) => {
    const C = await ethers.getContractFactory(params.contractName)
    const c = await upgrades.upgradeProxy(params.deployedAddress, C)
    const result = await c.deployed()
    console.log(result, result.address)
    return result
}

const attach = async (params: ContractAttach) => {
    const C = await ethers.getContractFactory(params.contractName)
    const c = await C.attach(params.deployedAddress)
    return c
}

const singers = async () => {
    const list = await ethers.getSigners()

    return list
}

const connectToWallet = async (contract: Contract, prv: string) => {
    const wallet = new ethers.Wallet(prv, ethers.provider)
    const c = contract.connect(wallet)
    return [c, wallet]
}

const connectToSigner = async (contract: Contract, index: number) => {
    const s = await singers()

    console.log(`connect signer address : ${s[index].address}, ${s.length}`)
    const c = contract.connect(s[index])
    return [c, s[index]]
}
export { deploy, deployProxy, upgradeProxy, attach, singers, ethers, connectToSigner, connectToWallet, getNetwork }
