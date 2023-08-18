# include .env file and export its env vars
# (-include to ignore error if it does not exist)-include .env
-include .env

# install solc version
# example to install other versions: `make solc 0_6_12`
SOLC_VERSION := 0_6_12
solc:; nix-env -f https://github.com/dapphub/dapptools/archive/master.tar.gz -iA solc-static-versions.solc_${SOLC_VERSION}

clean:; forge clean
update:; forge update
# Build & test
build:; forge build
test:; forge test # --ffi # enable if you need the `ffi` cheat code on HEVM

flatten:; forge flatten --source-file src/DappTemplate.sol

deploy:; @scripts/forge-deploy.sh src/DappTemplate.sol:DappTemplate --verify
verify:; @scripts/forge-verify.sh ${address} src/DappTemplate.sol:DappTemplate
send:; @scripts/cast-send.sh ${args}

nodejs-deps:; yarn install
lint:; yarn run lint
