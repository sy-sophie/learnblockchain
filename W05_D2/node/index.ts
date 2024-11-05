import {createPublicClient, http, toHex, keccak256, hexToBigInt, trim, slice} from 'viem';
import {mainnet} from 'viem/chains';

// 连接到主网
const client = createPublicClient({
    chain: mainnet,
    transport: http("https://sepolia-rollup.arbitrum.io/rpc"), // 替换为你的 RPC URL https://sepolia-rollup.arbitrum.io/rpc
});

const contractAddress = '0x543FF5baFD7fcD727711900A48F040B4405D4618'; // 合约地址 0x67f2885A76e4e0aCD23835D6436246ceD8aD0b2b

/**
 *  struct LockInfo{
 *      address user; // 占20个字节
 *      uint64 startTime; // 占8字节
 *      uint256 amount; // 占32字节一个slot
 *  }
 */
async function fetchLockInfo() {
    try {
        const lengthHex = await client.getStorageAt({
            address: contractAddress,
            slot: toHex(0),
        });
        const length = hexToBigInt(lengthHex!);
        const baseSlot = hexToBigInt(keccak256(toHex(0, { size: 32 })));
        for (let i = 0n; i < length; i++) {
            const userAndStartTimeSlot = baseSlot + i * 2n;
            const amountSlot = userAndStartTimeSlot + 1n;
            const [userAndStartTimeHex, amountHex] = await Promise.all(
                [userAndStartTimeSlot, amountSlot].map((slot) => {
                    return client.getStorageAt({
                        address: contractAddress,
                        slot: toHex(slot, { size: 32 }),
                    });
                })
            );
            const trimedUserAndStartTimeHex = trim(userAndStartTimeHex!);
            const startTimeHex = slice(trimedUserAndStartTimeHex, 0, 8); // uint64占前8个字节
            const userHex = slice(trimedUserAndStartTimeHex, 9); // address占后20个字节
            console.log({
                user: userHex!,
                startTime: hexToBigInt(startTimeHex!),
                amount: hexToBigInt(amountHex!),
            });
        }

    } catch (error) {
        console.error(error);
        return null;
    }
}

// 获取并打印所有锁的信息
async function fetchAllLockInfos() {
    let lockInfo = await fetchLockInfo()
    console.log(lockInfo)
}

// 调用函数获取并打印锁的信息
fetchAllLockInfos().catch(console.error);
