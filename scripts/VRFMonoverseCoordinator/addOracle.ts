import { ethers } from 'hardhat'
import * as utils from '../utils'
import { Config } from '../utils'
import configJson from './_config.json'
import keypair from '../VRF/key'
import BN from 'bn.js'

const config: Config = configJson
async function main() {
    const c = await utils.attach({
        contractName: 'VRFMonoverseCoordinator',
        deployedAddress: config.networks[utils.getNetwork()],
    })

    const receipt = await c.registerOracle('0xED22C760846af30fC50735181D9d71c8Efdb83D0', [
        new BN('90ba5df0576b39a36dc722cc7b46d5a12808c67be287151e3c72b53c5b5fb75f', 16).toString(),
        new BN('a25db8dfe8ed139fa1286d6c12ba98233ef64ad1c3feb821d1c4367b3a23b7d8', 16).toString(),
    ])
    // const receipt = await c.registerOracle('0x7e36C07AF7df5EFf2C6747b28ACce747E615A221', [
    //     new BN('e62fe52b317f685b7e50cca620d3981e8d50c5996e19900a1f73e3b977be129d', 16).toString(),
    //     new BN('61c5894b83c35a0b44065d13e7bd5c4b49cbd713d16daac583d626ccf11a1473', 16).toString(),
    // ])

    console.log(receipt)

    const tx = await receipt.wait()
    console.log(tx)
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
