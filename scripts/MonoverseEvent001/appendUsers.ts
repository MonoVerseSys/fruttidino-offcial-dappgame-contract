import { ethers } from 'hardhat'
import * as utils from '../utils'
import { Config } from '../utils'
import configJson from './_config.json'
const config: Config = configJson
async function main() {
    const c = await utils.attach({
        contractName: config.contractName,
        deployedAddress: config.networks[utils.getNetwork()],
    })
    const strIds = [
        'lemtx1994',
        'Nilesh_2424',
        'luizfernandopem',
        'sinhcapital1988',
        'kushina5uzumaki',
        'PauGenerRodrgu1',
        'MkrtichKarapety',
        'yangzai51',
        'NOK9442',
        'AppJ000',
        'CK9941',
        'jeongji43725882',
        'ioucryto',
        'LuceroAlberch53',
        'koreanub',
        'ElioGaliuzi',
        'sonnurbagdigen',
        'udhayaji',
        'YerbangaH',
        'MDISMAIL67',
        'ouchich_lahcen',
        'arrasel52',
        'Jaratra90604358',
        'Anassay65667493',
        'kyc1157',
        'omerinan60',
        'dehbi2222',
        'itsmeIrfandi',
        'v_uzee',
        'ZoeYoho',
        'naveen95244',
        'perfectsunman',
        'Ricky9169624987',
        'AbdeTRX',
        'Alejo77967394',
        'Jihye08842704',
        'teenmeaw',
        '0606tanu',
        'Korimsk9547',
        'Davidblockch',
        'Regina88654576',
        'charlesvane588',
        'Ankit04324488',
        'Fozy059Z',
        'sukur7312',
        'Rachone123',
        'akeelgehad1',
        'Hossain05184846',
        'AlbertoSchwemke',
        'TockaHrt',
        'ayoub1980gh',
        'WalidRadja1',
        'cryptMB',
        'R_Arifinx',
        'Maher_Aldulimi',
        'Rahimoued87',
        'AbdoAlkhateb11',
        'huseyinozhan17',
        'YoussefiFatima',
        'DoganAkcam',
        'Badrg007',
        'Essam1589',
        'HasibSk24287551',
        'RichRichie1903',
        'Hakato196',
        'Farouk98181140',
        'Benmokh22',
        'vinaygo50046419',
        'Freeman365TH',
        'huseyinozhan28',
        'syhwin1',
        'muhammadfaysall',
        'Kimberl17375366',
        'czbchs_',
        'AtikurR05677813',
        'Sustoto5',
        'HABIB_A02',
        'Rejomaget',
        'HeyHarr04679554',
        'extreme_nop',
        'jaypriv93594177',
        'NaeemDeamer',
        'XiaoLenjen',
        'srecahaya',
        'akane_chizu',
        'Vyach235',
        'owoAlva',
        'Thanet100',
        'UNAChoi_',
        'VinchJill',
        'upmoney77',
        'BaCryp',
        'CarpenterCarne1',
        'BguildFi',
        'SpaceyMichael2',
        'nthna11',
        'TaeLaw1',
        'keizi333',
        'Lee__mon',
        'R5r5John',
        'jfsaragih22',
        'Lisa99B99',
        'agungm068',
        'Play_9_Lot',
        'ImS4B',
        'Svetlan79645495',
        'HinNuttha',
        'PetPiriri',
        'Obitosixsense',
        'piployppmk',
        'punchy2204',
        'mungkoodpunchkn',
        'Attawit_Yo',
        'hidayanto6989',
        'Warutploy',
        'max4you0804',
        'kimyun234',
        'VinhOmo',
        'MehmetEminGrb10',
        'splll5',
        'blacketh66',
        'ArsenArsen25',
        'Rhythm_Pond',
        'TurnUp_Kinq',
        'Dule98839252',
        'Htent77',
        'JTHIS043',
        'abidu_rakhman',
        'techarcane1',
        'SaibaYou',
        'GamingytNosaj',
        '9JUTcw1LoJgWU70',
        '_andrew_fritz_',
        'EMRDMRKN53',
        'OsaAlpha',
        'its_deiky',
        'LucasChong77',
        'nganggur_id',
        'UniversalDada20',
        'Amethyst011296',
        'NReghenaz',
        'angelfriend81',
        'rookiebullish',
        'theworldofartv2',
        'skyisdalangit',
        '0xWinPiano',
        'kangudjo90',
        'squad_david',
        'Ali61005481',
        'ArkaDendra',
    ]

    let ids = []
    const bulkSize = 30

    for (let i = 0; i < strIds.length; i++) {
        const id = ethers.utils.formatBytes32String(strIds[i])
        ids.push(id)

        if (ids.length === bulkSize || i === strIds.length - 1) {
            console.log(ids)
            const receipt = await c.appendUsers(ids)
            const tx = await receipt.wait()
            console.log(tx)
            ids = []
        }
    }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
