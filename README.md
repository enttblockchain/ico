# Ledgit ICO Smart Contract

## ToDo
___


- [x] Whitelist

- [x] Oraclize

- [x] Service fee

- [x] Reach Goal/forwardFunds (Lim Sing)

- [x] Convert Token

- [x] Refund Token

- [x] Buy Token / Invest (Vincent)

- ~~Presale fund collector~~ Pre-ICO and ICO combined.

- [x] Remove Presale contract from codebase.

- Integration with web

- Alpha Test

## After clone

- Install only production dependencies.
> ```
> npm install --production
> ```

Or

- Install development dependencies for running test
> ```
> npm install
> ```

## Run Test
___

(Without specified network, using default network - "test")

truffle test

(With specified network)

truffle test --network your-network-name, eg: ganache

## Connect to oraclize from Private Network or testrpc/ganache-cli
___

### Requirements

> - Installed geth
> - Installed testrpc/ganache-cli (both)
> - Installed [etheruem-bridge](https://github.com/oraclize/ethereum-bridge)

### Connect from testrpc/ganache-cli
1. Start testrpc/ganache-cli with following command
    * ```ganache-cli -m "phrase"```
    * keep "phrase" special and as short as possible
    * reuse the same "phrase", refer to [docs](https://github.com/oraclize/ethereum-bridge) for the reason

2. Go to your ethereum-bridge directory and execute following command
    * ```node bridge -a account_index```
    * account_index could be any account's index generated by testrpc, default 0 - 9, pick one

3. Update your OAR in your oraclize contract's construct, [how-to](https://github.com/oraclize/ethereum-bridge)

### Connect from Private Network
1. Start your private node, **geth**

2. Go to your ethereum-bridge directory and execute following command
    * ```node bridge -H localhost:your-rpc-port -a account_index```
    * eg, your-rpc-port - 9003, account_index - 0

3. **If and Only if needed**, Update your OAR in your oraclize contract's construct, [how-to](https://github.com/oraclize/ethereum-bridge)