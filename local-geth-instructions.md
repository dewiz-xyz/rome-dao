# Local GETH testnet account notes

## Install GETH

https://geth.ethereum.org/docs/getting-started/installing-geth

Follow the instructions of the page above.

## Starting the local node

For quick tests to run GETH node in **dev** mode is a good option.
Create a geth-dev-chain directory, add it to .ignore and later you can start it using the following script.

```shell
geth --datadir ~/.temp/ --dev --http --http.api web3,eth,net --http.corsdomain "*" --http.vhosts "*" --http.addr 127.0.0.1 --ws --ws.api eth,net,web3 --ws.addr /127.0.0.1 --ws.origins "*" --graphql --graphql.corsdomain "*" --graphql.vhosts "*"
 
```

## Account list and tx samples

You can attach to the node via IPC and access the account 

Using developer account address=0xF1d2072CaF0c3E9266BEc87B120499c11e5C5d02
geth attach ipc:///Users/yourusername/temp/geth.ipc

Let's assume your coinbase/developer account is:
0xF1d2072CaF0c3E9266BEc87B120499c11e5C5d02
eth.getBalance("0xF1d2072CaF0c3E9266BEc87B120499c11e5C5d02")
web3.fromWei(eth.getBalance("0xF1d2072CaF0c3E9266BEc87B120499c11e5C5d02"), "ether")

eth.sendTransaction({from:"0xF1d2072CaF0c3E9266BEc87B120499c11e5C5d02", to:"0x1F23B596A659D7D056F73e4712630b659634e73B", gasPrice: 875000000, value: web3.toWei(5, "ether")})
