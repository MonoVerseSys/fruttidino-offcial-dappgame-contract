import { ethers } from 'hardhat'
import * as utils from '../utils'
import { Config } from '../utils'
import configJson from './_config.json'
import keypair from '../VRF/key'
import { keygen, prove, decode, getFastVerifyComponents, verify } from '../VRF/vrf'

const config: Config = configJson
async function main() {
    const contract = await utils.attach({
        contractName: 'VRFMonoverseCoordinator',
        deployedAddress: config.networks[utils.getNetwork()],
    })
    const reqId = '0xb73ffbb91a9285e576024af8ceabd664dabe1eecdb03b08fb2fc3e782d3e1507'
    // const reqTrHash = '0x9f062ee33ab273833fdc2836f150d42363573baf4ee97b613c50a670dba56f35'
    // const logIndex = '1'
    // const alpha = `${reqTrHash}${logIndex}`
    const alpha = new Date().valueOf().toString()

    const proof = prove(keypair.secret_key, alpha)
    console.log(proof)
    const [Gamma, c, s] = decode(proof || '')
    console.log(`Gamma: `, Gamma)
    const fast = getFastVerifyComponents(keypair.public_key.key, proof || '', alpha)
    console.log(fast)
    // const signers = await utils.singers()
    const receipt = await contract.fulfillRandomWords(
        [keypair.public_key.x.toString(), keypair.public_key.y.toString()],
        [Gamma.x.toString(), Gamma.y.toString(), c.toString(), s.toString()],
        Buffer.from(alpha, 'hex'),
        [fast?.uX, fast?.uY],
        [fast?.sHX, fast?.sHY, fast?.cGX, fast?.cGY],
        reqId,
        { gasPrice: ethers.BigNumber.from('10000000000') }
    )
    console.log(receipt)

    const tx = await receipt.wait()
    console.log(JSON.stringify(tx, null, 2))
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
