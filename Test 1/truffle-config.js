var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = "<Enter your 12 phrase mnemonic here...>"; //Enter mnemonic here

module.exports = {
  networks: {
    ropsten: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "https://ropsten.infura.io/v3/<infura API key her>") //Enter your infura API key 
      },
      network_id: 3
    }   
  }
};
