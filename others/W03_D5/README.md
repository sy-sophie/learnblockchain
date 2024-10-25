graph理解为索引
```sh 
# 初始化项目（1）要有 合约地址：0x9e72881669c7b39d4283B3ce11922C248B2c5755
graph init --studio nft-factory 
```

```sh 
  "scripts": {
    "codegen": "graph codegen",
    "build": "graph build",
    "deploy": "graph deploy --node https://api.studio.thegraph.com/deploy/ nft-factory",
    "create-local": "graph create --node http://localhost:8020/ nft-factory",
    "remove-local": "graph remove --node http://localhost:8020/ nft-factory",
    "deploy-local": "graph deploy --node http://localhost:8020/ --ipfs http://localhost:5001 nft-factory",
    "meta": "yarn remove-local && yarn create-local",
    "test": "graph test"
  },
```
