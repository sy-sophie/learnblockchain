import {createPublicClient, http, stringify, parseAbiItem} from 'viem';
import {mainnet} from 'viem/chains';

// 创建公用客户端
const client = createPublicClient({
    chain: mainnet,
    transport: http(),
});

const USDT_CONTRACT_ADDRESS = '0xdac17f958d2ee523a2206206994597c13d831ec7';
const TRANSFER_EVENT_ABI = parseAbiItem('event Transfer(address indexed from, address indexed to, uint256 value)');

client.watchBlockNumber({
    onBlockNumber: async (blockNumber) => {
        console.log( `Block number: ${blockNumber}`);
        const logs = await client.getLogs({
            address: USDT_CONTRACT_ADDRESS,
            event: TRANSFER_EVENT_ABI,
        });
        console.log(logs, "watchBlockNumber-Logs");
    },
})

client.watchBlocks({
    onBlock:async (block) => {
        console.log(`Block: ${stringify(block, null, 2)}`)
        const logs = await client.getLogs({
            address: USDT_CONTRACT_ADDRESS,
            event: TRANSFER_EVENT_ABI,
        });
        console.log(logs,"watchBlocks-Logs" )
    },
})

//  npx ts-node index.ts

