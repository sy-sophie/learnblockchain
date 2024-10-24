// 格式如下：
// 从 0x099bc3af8a85015d1A39d80c42d10c023F5162F0 转账给 0xA4D65Fd5017bB20904603f0a174BBBD04F81757c 99.12345 USDC ,交易ID：0xd973feef63834ed1e92dd57a1590a4ceadf158f731e44aa84ab5060d17336281


import {createPublicClient, http, parseAbiItem} from 'viem';
import {mainnet} from 'viem/chains';

const client = createPublicClient({
    chain: mainnet,
    transport: http('https://rpc.flashbots.net'), // TODO
});
const USDC_CONTRACT_ADDRESS = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'; // USDC 合约地址

async function getRecentBlockTransfers() {
    const transfers: any[] = [];
    const latestBlockNumber = await client.getBlockNumber();
    const startBlock = BigInt(latestBlockNumber) - BigInt(100);
    const filter = await client.createEventFilter({
        address: USDC_CONTRACT_ADDRESS,
        event: parseAbiItem('event Transfer(address indexed from, address indexed to, uint256 value)'),
        fromBlock: startBlock,
        toBlock: latestBlockNumber,
    })

    const txLogs = await client.getFilterLogs({ filter });
    for (const log of txLogs) {
        let {from, to, value} = log.args
        transfers.push(`从 ${from} 转账给 ${to}  ${value} USDC ,交易ID：${log.transactionHash}`);
    }
    return transfers;
}

getRecentBlockTransfers()
    .then(transfers => {
        console.log('Recent USDC Transfers:', transfers);
    })
    .catch(error => {
        console.error('Error fetching USDC transfers:', error);
    });

// npx ts-node queryUsdcTransfers.ts
