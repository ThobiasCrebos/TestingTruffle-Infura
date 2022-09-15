# Truffle-and-Infura

## pre-requisites
1. Truffle

```
npm install -g truffle
```

2.truffle-hdwallet-provider

```
npm install truffle-hdwallet-provider
```
3. infura Account

https://infura.io/register

## Steps

1. Edit truffle-config.js and add your infura url and mnemonic of metamask.

2. Run ```truffle compile``` and ```truffle migrate --network ropsten```

3. Go to Truffle console by running  ```truffle console --network ropsten```

```>const instance = await SimpleStorage.deployed()```

```> await instance.set("hi devs")```

```> await instance.get()```

>```hi devs```

