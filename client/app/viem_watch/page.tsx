"use client"
import {useEffect, useState} from 'react';
import {createPublicClient, http, parseAbiItem} from 'viem';
import {mainnet} from 'viem/chains';

const USDT_CONTRACT_ADDRESS = '0xdac17f958d2ee523a2206206994597c13d831ec7';
const TRANSFER_EVENT_ABI = parseAbiItem('event Transfer(address indexed from, address indexed to, uint256 value)');

const client = createPublicClient({
    chain: mainnet,
    transport: http('https://rpc.flashbots.net'),
});
interface TransferLog {
    blockNumber: string;
    transactionHash: `0x${string}`;
    from: `0x${string}` | undefined;
    to: `0x${string}` | undefined;
    value: bigint | undefined;
}
export default function ViemWatch() {
    const [blockHeight, setBlockHeight] = useState<number | null>(null);
    const [blockHash, setBlockHash] = useState<string | null>(null);

    const [transfersLogs, setTransfersLogs] = useState<TransferLog[]>([]);
    useEffect(() => {
        const getBlockData = async () => {
            const lastBlock = await client.getBlock({blockTag: 'latest'}); // 获取最新区块
            setBlockHeight(Number(lastBlock.number));
            setBlockHash(lastBlock.hash);
        };
        const subscribe = () => {
            client.watchBlockNumber({
                onBlockNumber: async (blockNumber) => {

                    setBlockHeight(Number(blockNumber || 0));


                    const logs = await client.getLogs({
                        address: USDT_CONTRACT_ADDRESS,
                        event: TRANSFER_EVENT_ABI,
                    });

                    const newTransfers = logs.map(log => {
                        const {from, to, value} = log.args || {};
                        return {
                            blockNumber: log.blockNumber.toString(), // 转换为字符串
                            transactionHash: log.transactionHash,
                            from,
                            to,
                            value
                        };
                    });
                    // 更新转账日志，限制为最新的 20 条
                    setTransfersLogs(prevLogs => {
                        const updatedLogs = [...newTransfers, ...prevLogs];
                        return updatedLogs.slice(0, 20); // 只保留最新的 20 条
                    });
                },
            });
        };
        getBlockData();
        subscribe();
    }, [])
    return (
        <div className="bg-gray-100 p-6 min-h-screen">
            <h1 className="text-3xl font-bold text-gray-800 mb-4">ViemWatch</h1>
            <h2 className="text-lg text-gray-700 mb-6">
                <div>
                    Current Block: <span className="font-semibold text-indigo-600">{blockHeight}</span>
                </div>
                <div>
                    Block Hash: <span
                    className="text-gray-600">{blockHash}</span>
                </div>
            </h2>
            <div className="bg-white p-4 rounded-lg shadow-md">
                <h3 className="text-2xl font-semibold text-gray-800 mb-4">Transfer Logs:</h3>
                <ul className="space-y-4">
                    {transfersLogs.map((tx, index) => (
                        <li key={index} className="bg-gray-50 p-4 rounded-md shadow-sm border border-gray-200">
                            <div><strong className="text-gray-800">Block:</strong> <span
                                className="text-indigo-500">{tx.blockNumber}</span></div>
                            <div><strong className="text-gray-800">Transaction:</strong> <span
                                className="text-blue-500">{tx.transactionHash}</span>
                            </div>
                            <div><strong className="text-gray-800">From:</strong> <span
                                className="text-red-500">{tx.from}</span></div>
                            <div><strong className="text-gray-800">To:</strong> <span
                                className="text-green-500">{tx.to}</span></div>
                            <div><strong className="text-gray-800">Value:</strong> <span
                                className="text-purple-500">{tx.value} USDT</span></div>
                        </li>
                    ))}
                </ul>
            </div>
        </div>
    )
}
