const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');

// Whitelist user addresses
const whitelist = [
  "0x1111111111111111111111111111111111111111",
  "0x2222222222222222222222222222222222222222",
  "0x3333333333333333333333333333333333333333",
  "0x1611D79981b8F25AE979e2f34b05B1Acf56e8Ac9"
];

// Hash the addresses to be used for generating the Merkle tree
const leafNodes = whitelist.map(addr => keccak256(addr));
const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });

// Compute the Merkle tree root
const merkleRoot = merkleTree.getHexRoot();
console.log('Merkle Root:', merkleRoot); // 0x9734607f1e052213793490eb96b613a0fecb9f6e40d1ded7c97d0cd4dbb81e92

// Generate the proof path for a specific address
const claimingAddress ="0x1611D79981b8F25AE979e2f34b05B1Acf56e8Ac9";
const proof = merkleTree.getHexProof(keccak256(claimingAddress));
console.log('Proof for address:', claimingAddress, proof);
// 0x4444444444444444444444444444444444444444 [
//     '0x37d95e0aa71e34defa88b4c43498bc8b90207e31ad0ef4aa6f5bea78bd25a1ab'
//         '0x4beda981c9d34f2dd099131be6049a1d87676d227e63f4a409ee629043314b4f'
//     ]
