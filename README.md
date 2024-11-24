# Mintable Starknet Token

This repository is a simple implementation of a mintable ERC20 token on Starknet using Cairo, and below is the tutorial of how to deploy this contract.

---

## 1. Setup Environment

Before deployment, you need two client tools: **Starkli** and **Scarb**. **Starkli** is a command-line interface that allows you to interact with Starknet, and **Scarb** is a build toolchain and package manager for Cairo and Starknet ecosystems.

### 1.1 Install Starkli

Firstly, install **Starkliup**, the installer for the Starkli environment:

```bash
curl https://get.starkli.sh | sh
```

Restart your terminal and install **Starkli** by:

```bash
starkliup -v 0.3.5
```

While 0.3.5 is the latest version at the time of writing, you can check the [latest release version](https://github.com/xJonathanLEI/starkli/releases) supported by Starkli.

Check your installation by:

```bash
starkli --version       # 0.3.5 (fa4f0e3)
```

### 1.2 Install Scarb

It's recommended by the official documentation to install Scarb via the asdf version manager. Follow the steps below:

```bash
brew install asdf
asdf plugin add scarb
asdf install scarb 2.8.4 
asdf global scarb 2.8.4 
```

Check your installation by:

```bash
scarb --version       # 2.8.4 (2aa4e193e 2024-10-07
```

The version of **Starkli** and **Scarb** should be matched, otherwise you may not be able to declare the contract successfully.

See [Starknet Docs - Setting up your environment](https://docs.starknet.io/quick-start/environment-setup/) for more details.

### 1.3 Setup `.env`

Copy the `.env.example` file to `.env` and fill in the values:

```bash
cp .env.example .env
```

You can use your private RPC provider from [Quicknode](https://dashboard.quicknode.com/endpoints/new/STRK).

---

## 2. Setup Account

Starknet uses smart wallets to manage accounts, not a simple private-key pattern. You should firstly create a wallet in [Argent X Wallet](https://chromewebstore.google.com/detail/argent-x-starknet-wallet/dlcobpjiigpikoobohmabehhmhfoodbb), which is the most popular Starknet wallet. Select `Standard Account` when creating a new account.

### 2.1 Create Keystore

In the Argent X Wallet, navigate to: `Settings section` -> `Select your Account` -> `Export Private Key`.

Create a keystore file with the private key by:

```bash
mkdir -p ~/.starkli-wallets/deployer
starkli signer keystore from-key ~/.starkli-wallets/deployer/keystore.json
# Paste the private key and press Enter
```

You will get a keystore file stored in `~/.starkli-wallets/deployer/keystore.json`. If you use a different path, please also update the `STARKNET_KEYSTORE` in the `.env` file.

### 2.2 Fund Account

- If you're using Starknet Sepolia Testnet, fund your account of Argent X Wallet by [Starknet Faucet](https://blastapi.io/faucets/starknet-sepolia-eth) (recommended). You can also bridge your tETH from Ethereum Sepolia Testnet, but it may take a while.
- If you're using Starknet Mainnet, directly transfer ETH to your account.

In the Argent X Wallet, navigate to: `Settings section` -> `Select your Account` -> `Deploy account`. Because Starknet uses smart wallets to manage accounts, you need to deploy your account before using it.

### 2.3 Create Account Store

After deploying your account in Argent X Wallet, collect your account information by:

```bash
source .env
starkli account fetch <SMART_WALLET_ADDRESS> --output ~/.starkli-wallets/deployer/account.json
```

If it returns a `ContractNotFound` error, it's probably because your account is not deployed yet. Please redo the steps in [2.2 Fund Account](#22-fund-account) and wait for a few seconds.

Also, if you've changed the default path of the keystore and account store, please update the `STARKNET_ACCOUNT` in the `.env` file.

---

## 3. Deploy Contract

In Starknet, you must declare a contract before deploying it. `Declare` means sending your contract’s code to the network, while `Deploy` means creating an instance of the code you previously declared here.

### 3.1 Compile Contract

Modify the token name and symbol in [contract constructor](src/lib.cairo#L43), then compile the contract by:

```bash
scarb build
```

### 3.2 Declare Contract

Declare the contract by:

```bash
source .env
starkli declare target/dev/starknet_token_PumpBTC.contract_class.json
```

You will get a result like this:

```log
Declaring Cairo 1 class: 0x0755050b197cae4c836ca09d7c0ec218630851b1e42a73061bb7588db2df425a
Compiling Sierra class to CASM with compiler version 2.8.2...
CASM class hash: 0x033ac464d3c68e089d90a36155906f30312a2ecb69fd8d03f7f857b7d14fc6f0
Contract declaration transaction: 0x03ee91eccc313acd3ca76e31d4ede2d07979565ad506f21a0942681dacb09f25
Class hash declared:
0x0755050b197cae4c836ca09d7c0ec218630851b1e42a73061bb7588db2df425a
```

The `Class hash` is the hash of the contract code, which is used to identify the contract on the network.

### 3.3 Deploy Contract

Deploy the contract by:

```bash
source .env
starkli deploy <CLASS_HASH> <OWNER_ADDRESS>
# e.g. starkli deploy 0x0755050b197cae4c836ca09d7c0ec218630851b1e42a73061bb7588db2df425a 0x06a9E6bC1cf6c32cef74eB3B043d6c9A1B9e57C803FfFb238e545b22b273d84a
```

Where `<CLASS_HASH>` is the class hash of the contract you just declared, and `<OWNER_ADDRESS>` is the address of the token owner. It have the ability to set token minter.

You will get a result like this:

```log
Deploying class 0x0755050b197cae4c836ca09d7c0ec218630851b1e42a73061bb7588db2df425a with salt 0x02f990da1e791d40dabc38e8464ed26884be5ba60c4a90911687f0cef0dbaa18...
The contract will be deployed at address 0x01fe21204b4187392ab281a1fea13a5efb71d97f689bd56947ef04e3fbf0c370
Contract deployment transaction: 0x04b3ab29c97ae124941bdfc4c2b22b2b872ca676ae4108dea0cbaf3a32dbaeba
Contract deployed:
0x01fe21204b4187392ab281a1fea13a5efb71d97f689bd56947ef04e3fbf0c370
```

The `Contract deployed` is the address of the deployed contract.

---

## 4. Interact with Contract

Finally, you can interact with the contract by using `Starkli`. Use `starkli call` to call the view functions, and use `starkli invoke` to call the write functions.

### 4.1 Set Minter

Set the minter by:

```bash
source .env
starkli invoke <CONTRACT_ADDRESS> set_minter <MINTER_ADDRESS> 0x1   # 0x1 is true, 0x0 is false
# e.g. starkli invoke 0x01fe21204b4187392ab281a1fea13a5efb71d97f689bd56947ef04e3fbf0c370 set_minter 0x06a9E6bC1cf6c32cef74eB3B043d6c9A1B9e57C803FfFb238e545b22b273d84a 0x1
```

Check the minter by:

```bash
starkli call <CONTRACT_ADDRESS> is_minter <MINTER_ADDRESS>
```

### 4.2 Mint and Transfer

Mint the token or transfer the token by:

```bash
source .env
starkli invoke <CONTRACT_ADDRESS> mint <RECIPIENT_ADDRESS> <AMOUNT>
# e.g. starkli invoke 0x002588ee6b6781830e1ae98386ef666972561833e989b355bdbf618418b5df4c mint 0x10d40d06b29350bdad0df077e5bc001c6aaf62903d81f44230a1e7c195a1396 u256:3000000000000000000
starkli invoke <CONTRACT_ADDRESS> transfer <RECIPIENT_ADDRESS> <AMOUNT>
# e.g. starkli invoke 0x002588ee6b6781830e1ae98386ef666972561833e989b355bdbf618418b5df4c transfer 0x04565Ab9a5083a15328e4EDf282BcdADfbD230bCE937E811292cc962183e254c u256:1000000000000000000
```

Remember to annotate the amount with `u256:` prefix. You can view the result in the [starknet explorer](https://sepolia.starkscan.co/).

Then check the balance of the token by:

```bash
starkli call <CONTRACT_ADDRESS> balance_of <ADDRESS>
# e.g. starkli call 0x002588ee6b6781830e1ae98386ef666972561833e989b355bdbf618418b5df4c balance_of 0x10d40d06b29350bdad0df077e5bc001c6aaf62903d81f44230a1e7c195a1396
```

It will return the balance in `u256` format, like this:

```log
[
    "0x0000000000000000000000000000000000000000000000001bc16d674ec80000",
    "0x0000000000000000000000000000000000000000000000000000000000000000"
]
```

The first value is the low 128 bits of the balance, while the second value is the high 128 bits. So the balance is `0x0000000000000000000000000000000000000000000000001bc16d674ec80000 = 2000000000000000000 = 2e18`.
