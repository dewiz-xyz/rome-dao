# Rome DAO

![Rome Empire Standard](rome-empire-flag-small.jpeg "Rome Empire Standard")

This project aims to be Ceasar's coin exchange... No, it's a joke :P

Actually the purpose of this project is to illustrate how the mainly Maker DAO smart contracts are set.

This project is based on Foundry Forge Dewiz Template.

## Enviroment Setup

### Solidity version

This project uses Solidity version **0.6.12**

The reason is due changes in Solidity arithmetics from version 0.5.x to 0.8.x the Maker DAO's DSS Smart Contracts need to be compiled using 0.6.x version to avoid overflow
errors when `frob` method is called.

### Setup auxiliary tooling

Make sure you have **node.js**, **shfmt** and **foundry** installed.

### Install dependencies

```bash
# Install tools from the nodejs ecosystem: prettier, solhint, husky and lint-staged
make nodejs-deps
# Install smart contract dependencies through `foundry update`
make update
```

### Setup localchain using GETH

```bash
geth --datadir ~/temp/ --dev --http --http.api web3,eth,rpc,debug,net,txpool,admin --http.corsdomain "*" --http.vhosts "*" --http.addr 127.0.0.1 --ws --ws.api eth,net,debug,web3 --ws.addr 127.0.0.1 --ws.origins "*" --graphql --graphql.corsdomain "*" --graphql.vhosts "*" --vmdebug
```

### Setup local environment variables

```shell
export ETH_FROM=0x
export FOUNDRY_ETH_FROM=$ETH_FROM
export ETHERSCAN_API_KEY=""
export POLYGONSCAN_API_KEY=""
export ETH_KEYSTORE="/Users/johndoe/temp/keystore"
export FOUNDRY_ETH_KEYSTORE_DIR=$ETH_KEYSTORE
export ETH_PASSWORD="$ETH_KEYSTORE/passwd.txt"
export FOUNDRY_ETH_PASSWORD_FILE=$ETH_PASSWORD
```

### Helper scripts

Wrapper around `forge`/`cast` which figure out wallet and password automatically if you are using [`geth` keystore](https://geth.ethereum.org/docs/interface/managing-your-accounts).

- `scripts/forge-deploy.sh`: Deploys a contract. Accepts the same options as [`forge create`](https://book.getfoundry.sh/reference/forge/forge-create.html)
- `scripts/forge-verify.sh`: Verifies a deployed contract. Accepts the same options as [`forge verify-contract`](https://book.getfoundry.sh/reference/forge/forge-verify-contract.html)
- `scripts/cast-send.sh`: Signs and publish a transaction. Accepts the same options as [`cast send`](https://book.getfoundry.sh/reference/cast/cast-send.html)

## Deploying artifacts

### Deploy your own "Dai" token `$DAI`

Deploy an ERC-20 to simulate `DAI` tokens. It will be managed by the protocol, Rome DAO, that simulates Maker DAO mechanisms.

Example:

```bash
./scripts/forge-script.sh ./src/dai.s.sol:DaiDeploy --fork-url=$RPC_URL --broadcast -vvvv
```

### Deploy `Vat`

Deploy `Vat` from `vat.sol`. VAT is the main compoment of Maker DAO. It manages the DAI supply versus debts tokenized in different collaterals.

Example:

```bash
<rome-dao-path>./scripts/forge-script.sh ./src/vat.s.sol:VatDeploy --fork-url=$RPC_URL --broadcast -vvvv
```

### Deploy `GemJoin` from Rome DAO

Deploy a `GemJoin` contract from `join.sol` and allow it to spend your collateral. `GemJoin` holds your collateral and `Vat` Smart Contract use it to manage
them.

```solidity
GemJoin(address vat, bytes32 ilk, address gem);
denarius.approve(address(gemJoin), type(uint256).max);
```

Where:

- `vat`: `<vat_addr>`
- `ilk`: `'Denarius-A'` //Example collateral token - Denarius was the Rome Empire silver coin
- `gem`: `$DENARIUS` // Example of an ERC20 token address that will be used as collateral to our Rome DAO DAI

Example:

```bash
./scripts/forge-script.sh ./src/GemJoin.s.sol:GemJoinDeploy --fork-url=$RPC_URL --broadcast -vvvv
```

### Deploy `DaiJoin` from Rome DAO

Deploy a `DaiJoin` contract from `join.sol`. `DaiJoin` holds `DAI` and `Vat` Smart Contract use it to manage them.

```solidity
DaiJoin(address vat, address dai)
```

Where:

- `vat_`: `<vat_addr>`
- `dai_`: `$DAI` ERC20 token address

Example:

```bash
./scripts/forge-script.sh ./src/DaiJoin.s.sol:DaiJoinDeploy --fork-url=$RPC_URL --broadcast -vvvv
```

Then, using `Rome DAO` scripts for:

1. Allow `DaiJoin` to **mint** `$DAI`
2. Allow `DaiJoin` to **burn** `$DAI`
3. Give Hope (permission) to `DaiJoin` operates moves `$DAI` for you within `Vat`
4. Make `$DAI` to rely on `DaiJoin`

Example:

```bash
./scripts/forge-script.sh ./src/DaiJoin.s.sol:DaiJoinReceiveAllowance --fork-url=$RPC_URL --broadcast -vvvv
```

### `Vat` initialization from Rome DAO

`Vat` needs to rely on (authorize) `GemJoin` and `DaiJoin` Smart Contracts, initialize it. Also it is needed to set the global debt ceiling, set collateral
debt ceiling, and set the collateral price.

See the sample code below:

```solidity
vat.rely(<gem_join_addr>);
vat.rely(<dai_join_addr>);
vat.init(<bond-or-collateral-name>);
vat.file('Line', 1_000_000 * 10**45); // RAD: 45 decimals
vat.file('Denarius-A', 'line', 1_000_000 * 10**45); // RAD: 45 decimals
vat.file('Denarius-A', 'spot', 1 * 10**27) // RAY: 27 decimals
```

Example:

```bash
./scripts/forge-script.sh ./src/vat.s.sol:VatInitialize --fork-url=$RPC_URL --broadcast -vvvv
```

### Detailed explanation about the debt/collateral definitions in `VAT`

#### Set the global debt ceiling using `Line` (with capital `L`)

```solidity
vat.file('Line', 1_000_000 * 10**45); // RAD: 45 decimals
```

#### Set collateral debt ceiling `line` (with lower `l`)

Pay attention that now you define a name for your collateral, in our case: `Denarius-A`. The collateral data is stored within a struct called `ilk`. There is a
mapping called `ilks` that allow the `Vat` supports several collaterals with different rate configurations.

```solidity
vat.file('Denarius-A', 'line', 1_000_000 * 10**45); // RAD: 45 decimals
```

#### Set collateral price (`spot`)

Spot defines the collateral price within the `Vat`

```solidity
vat.file('Denarius-A', 'spot', 1 * 10**27) // RAY: 27 decimals
```

In the above example, it makes `$DENARIUS` price equals `DAI` price ( 1 to 1 ).

## Next steps

Now you can start to borrow and pay back the DAO.

For more details how to operate the protocol, please visit the project [Understanding Maker DAO VAT Smart Contract]("https://github.com/dewiz-xyz/makerdao-vat-smartcontract-docs")
