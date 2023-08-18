# Foundry Template

Template for Smart Contract applications compatible with [foundry](https://github.com/foundry-rs/foundry).

## Usage

### Install dependencies

```bash
# Install tools from the nodejs ecosystem: prettier, solhint, husky and lint-staged
make nodejs-deps
# Install smart contract dependencies through `foundry update`
make update
```

### Create a local `.env` file and change the placeholder values

```bash
cp .env.example .env
```

### Build contracts

```bash
make build
```

### Test contracts

```bash
make test # using a local node listening on http://localhost:8545
# Or
ETH_RPC_URL='https://eth-goerli.alchemyapi.io/v2/<ALCHEMY_API_KEY>' make test # using a remote node
```

### Helper scripts

Wrapper around `forge`/`cast` which figure out wallet and password automatically if you are using [`geth` keystore](https://geth.ethereum.org/docs/interface/managing-your-accounts).

- `scripts/forge-deploy.sh`: Deploys a contract. Accepts the same options as [`forge create`](https://book.getfoundry.sh/reference/forge/forge-create.html)
- `scripts/forge-verify.sh`: Verifies a deployed contract. Accepts the same options as [`forge verify-contract`](https://book.getfoundry.sh/reference/forge/forge-verify-contract.html)
- `scripts/cast-send.sh`: Signs and publish a transaction. Accepts the same options as [`cast send`](https://book.getfoundry.sh/reference/cast/cast-send.html)
