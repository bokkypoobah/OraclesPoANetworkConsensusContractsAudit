#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`

SOURCEDIR=`grep ^SOURCEDIR= settings.txt | sed "s/^.*=//"`

BALLOTSTORAGESOL=`grep ^BALLOTSTORAGESOL= settings.txt | sed "s/^.*=//"`
BALLOTSTORAGEJS=`grep ^BALLOTSTORAGEJS= settings.txt | sed "s/^.*=//"`
KEYSMANAGERSOL=`grep ^KEYSMANAGERSOL= settings.txt | sed "s/^.*=//"`
KEYSMANAGERJS=`grep ^KEYSMANAGERJS= settings.txt | sed "s/^.*=//"`
POANETWORKCONSENSUSSOL=`grep ^POANETWORKCONSENSUSSOL= settings.txt | sed "s/^.*=//"`
POANETWORKCONSENSUSJS=`grep ^POANETWORKCONSENSUSJS= settings.txt | sed "s/^.*=//"`
PROXYSTORAGESOL=`grep ^PROXYSTORAGESOL= settings.txt | sed "s/^.*=//"`
PROXYSTORAGEJS=`grep ^PROXYSTORAGEJS= settings.txt | sed "s/^.*=//"`
VALIDATORMETADATASOL=`grep ^VALIDATORMETADATASOL= settings.txt | sed "s/^.*=//"`
VALIDATORMETADATAJS=`grep ^VALIDATORMETADATAJS= settings.txt | sed "s/^.*=//"`
VOTINGTOCHANGEKEYSSOL=`grep ^VOTINGTOCHANGEKEYSSOL= settings.txt | sed "s/^.*=//"`
VOTINGTOCHANGEKEYSJS=`grep ^VOTINGTOCHANGEKEYSJS= settings.txt | sed "s/^.*=//"`
VOTINGTOCHANGEMINTHRESHOLDSOL=`grep ^VOTINGTOCHANGEMINTHRESHOLDSOL= settings.txt | sed "s/^.*=//"`
VOTINGTOCHANGEMINTHRESHOLDJS=`grep ^VOTINGTOCHANGEMINTHRESHOLDJS= settings.txt | sed "s/^.*=//"`
VOTINGTOCHANGEPROXYADDRESSSOL=`grep ^VOTINGTOCHANGEPROXYADDRESSSOL= settings.txt | sed "s/^.*=//"`
VOTINGTOCHANGEPROXYADDRESSJS=`grep ^VOTINGTOCHANGEPROXYADDRESSJS= settings.txt | sed "s/^.*=//"`

DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST1OUTPUT=`grep ^TEST1OUTPUT= settings.txt | sed "s/^.*=//"`
TEST1RESULTS=`grep ^TEST1RESULTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`

START_DATE=`echo "$CURRENTTIME+60*2+30" | bc`
START_DATE_S=`date -r $START_DATE -u`
END_DATE=`echo "$CURRENTTIME+60*4" | bc`
END_DATE_S=`date -r $END_DATE -u`

printf "MODE                          = '$MODE'\n" | tee $TEST1OUTPUT
printf "GETHATTACHPOINT               = '$GETHATTACHPOINT'\n" | tee -a $TEST1OUTPUT
printf "PASSWORD                      = '$PASSWORD'\n" | tee -a $TEST1OUTPUT
printf "SOURCEDIR                     = '$SOURCEDIR'\n" | tee -a $TEST1OUTPUT
printf "BALLOTSTORAGESOL              = '$BALLOTSTORAGESOL'\n" | tee -a $TEST1OUTPUT
printf "BALLOTSTORAGEJS               = '$BALLOTSTORAGEJS'\n" | tee -a $TEST1OUTPUT
printf "KEYSMANAGERSOL                = '$KEYSMANAGERSOL'\n" | tee -a $TEST1OUTPUT
printf "KEYSMANAGERJS                 = '$KEYSMANAGERJS'\n" | tee -a $TEST1OUTPUT
printf "POANETWORKCONSENSUSSOL        = '$POANETWORKCONSENSUSSOL'\n" | tee -a $TEST1OUTPUT
printf "POANETWORKCONSENSUSJS         = '$POANETWORKCONSENSUSJS'\n" | tee -a $TEST1OUTPUT
printf "PROXYSTORAGESOL               = '$PROXYSTORAGESOL'\n" | tee -a $TEST1OUTPUT
printf "PROXYSTORAGEJS                = '$PROXYSTORAGEJS'\n" | tee -a $TEST1OUTPUT
printf "VALIDATORMETADATASOL          = '$VALIDATORMETADATASOL'\n" | tee -a $TEST1OUTPUT
printf "VALIDATORMETADATAJS           = '$VALIDATORMETADATAJS'\n" | tee -a $TEST1OUTPUT
printf "VOTINGTOCHANGEKEYSSOL         = '$VOTINGTOCHANGEKEYSSOL'\n" | tee -a $TEST1OUTPUT
printf "VOTINGTOCHANGEKEYSJS          = '$VOTINGTOCHANGEKEYSJS'\n" | tee -a $TEST1OUTPUT
printf "VOTINGTOCHANGEMINTHRESHOLDSOL = '$VOTINGTOCHANGEMINTHRESHOLDSOL'\n" | tee -a $TEST1OUTPUT
printf "VOTINGTOCHANGEMINTHRESHOLDJS  = '$VOTINGTOCHANGEMINTHRESHOLDJS'\n" | tee -a $TEST1OUTPUT
printf "VOTINGTOCHANGEPROXYADDRESSSOL = '$VOTINGTOCHANGEPROXYADDRESSSOL'\n" | tee -a $TEST1OUTPUT
printf "VOTINGTOCHANGEPROXYADDRESSJS  = '$VOTINGTOCHANGEPROXYADDRESSJS'\n" | tee -a $TEST1OUTPUT
printf "DEPLOYMENTDATA                = '$DEPLOYMENTDATA'\n" | tee -a $TEST1OUTPUT
printf "INCLUDEJS                     = '$INCLUDEJS'\n" | tee -a $TEST1OUTPUT
printf "TEST1OUTPUT                   = '$TEST1OUTPUT'\n" | tee -a $TEST1OUTPUT
printf "TEST1RESULTS                  = '$TEST1RESULTS'\n" | tee -a $TEST1OUTPUT
printf "CURRENTTIME                   = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST1OUTPUT
printf "START_DATE                    = '$START_DATE' '$START_DATE_S'\n" | tee -a $TEST1OUTPUT
printf "END_DATE                      = '$END_DATE' '$END_DATE_S'\n" | tee -a $TEST1OUTPUT

# Make copy of SOL file and modify start and end times ---
# `cp modifiedContracts/SnipCoin.sol .`
`cp -rp $SOURCEDIR/* .`

# --- Modify parameters ---
`perl -pi -e "s/address poaConsensus;/address public poaConsensus;/" $PROXYSTORAGESOL`
`perl -pi -e "s/address keysManager;/address public keysManager;/" $PROXYSTORAGESOL`
`perl -pi -e "s/address votingToChangeKeys;/address public votingToChangeKeys;/" $PROXYSTORAGESOL`
`perl -pi -e "s/address votingToChangeMinThreshold;/address public votingToChangeMinThreshold;/" $PROXYSTORAGESOL`
`perl -pi -e "s/address votingToChangeProxy;/address public votingToChangeProxy;/" $PROXYSTORAGESOL`
`perl -pi -e "s/address ballotsStorage;/address public ballotsStorage;/" $PROXYSTORAGESOL`
`perl -pi -e "s/uint8 thresholdForKeysType \= 1;/uint8 public thresholdForKeysType \= 1;/" $VOTINGTOCHANGEKEYSSOL`
`perl -pi -e "s/uint8 thresholdForKeysType \= 1;/uint8 public thresholdForKeysType \= 1;/" $VOTINGTOCHANGEMINTHRESHOLDSOL`
# `perl -pi -e "s/uint8 thresholdForKeysType \= 1;/uint8 public thresholdForKeysType \= 1;/" $VOTINGTOCHANGEPROXYADDRESSSOL`

DIFFS1=`diff $SOURCEDIR/$PROXYSTORAGESOL $PROXYSTORAGESOL`
echo "--- Differences $SOURCEDIR/$PROXYSTORAGESOL $PROXYSTORAGESOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

DIFFS1=`diff $SOURCEDIR/$VOTINGTOCHANGEKEYSSOL $VOTINGTOCHANGEKEYSSOL`
echo "--- Differences $SOURCEDIR/$VOTINGTOCHANGEKEYSSOL $VOTINGTOCHANGEKEYSSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

DIFFS1=`diff $SOURCEDIR/$VOTINGTOCHANGEMINTHRESHOLDSOL $VOTINGTOCHANGEMINTHRESHOLDSOL`
echo "--- Differences $SOURCEDIR/$VOTINGTOCHANGEMINTHRESHOLDSOL $VOTINGTOCHANGEMINTHRESHOLDSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

# DIFFS1=`diff $SOURCEDIR/$VOTINGTOCHANGEPROXYADDRESSSOL $VOTINGTOCHANGEPROXYADDRESSSOL`
# echo "--- Differences $SOURCEDIR/$VOTINGTOCHANGEPROXYADDRESSSOL $VOTINGTOCHANGEPROXYADDRESSSOL ---" | tee -a $TEST1OUTPUT
# echo "$DIFFS1" | tee -a $TEST1OUTPUT

solc_0.4.18 --version | tee -a $TEST1OUTPUT

echo "var bsOutput=`solc_0.4.18 --optimize --pretty-json --combined-json abi,bin,interface $BALLOTSTORAGESOL`;" > $BALLOTSTORAGEJS
echo "var kmOutput=`solc_0.4.18 --optimize --pretty-json --combined-json abi,bin,interface $KEYSMANAGERSOL`;" > $KEYSMANAGERJS
echo "var pncOutput=`solc_0.4.18 --optimize --pretty-json --combined-json abi,bin,interface $POANETWORKCONSENSUSSOL`;" > $POANETWORKCONSENSUSJS
echo "var psOutput=`solc_0.4.18 --optimize --pretty-json --combined-json abi,bin,interface $PROXYSTORAGESOL`;" > $PROXYSTORAGEJS
echo "var vmOutput=`solc_0.4.18 --optimize --pretty-json --combined-json abi,bin,interface $VALIDATORMETADATASOL`;" > $VALIDATORMETADATAJS
echo "var vtckOutput=`solc_0.4.18 --optimize --pretty-json --combined-json abi,bin,interface $VOTINGTOCHANGEKEYSSOL`;" > $VOTINGTOCHANGEKEYSJS
echo "var vtcmtOutput=`solc_0.4.18 --optimize --pretty-json --combined-json abi,bin,interface $VOTINGTOCHANGEMINTHRESHOLDSOL`;" > $VOTINGTOCHANGEMINTHRESHOLDJS
echo "var vtcpaOutput=`solc_0.4.18 --optimize --pretty-json --combined-json abi,bin,interface $VOTINGTOCHANGEPROXYADDRESSSOL`;" > $VOTINGTOCHANGEPROXYADDRESSJS

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST1OUTPUT
loadScript("$BALLOTSTORAGEJS");
loadScript("$KEYSMANAGERJS");
loadScript("$POANETWORKCONSENSUSJS");
loadScript("$PROXYSTORAGEJS");
loadScript("$VALIDATORMETADATAJS");
loadScript("$VOTINGTOCHANGEKEYSJS");
loadScript("$VOTINGTOCHANGEMINTHRESHOLDJS");
loadScript("$VOTINGTOCHANGEPROXYADDRESSJS");
loadScript("functions.js");

var bsAbi = JSON.parse(bsOutput.contracts["$BALLOTSTORAGESOL:BallotsStorage"].abi);
var bsBin = "0x" + bsOutput.contracts["$BALLOTSTORAGESOL:BallotsStorage"].bin;
var kmAbi = JSON.parse(kmOutput.contracts["$KEYSMANAGERSOL:KeysManager"].abi);
var kmBin = "0x" + kmOutput.contracts["$KEYSMANAGERSOL:KeysManager"].bin;
var pncAbi = JSON.parse(pncOutput.contracts["$POANETWORKCONSENSUSSOL:PoaNetworkConsensus"].abi);
var pncBin = "0x" + pncOutput.contracts["$POANETWORKCONSENSUSSOL:PoaNetworkConsensus"].bin;
var psAbi = JSON.parse(psOutput.contracts["$PROXYSTORAGESOL:ProxyStorage"].abi);
var psBin = "0x" + psOutput.contracts["$PROXYSTORAGESOL:ProxyStorage"].bin;
var vmAbi = JSON.parse(vmOutput.contracts["$VALIDATORMETADATASOL:ValidatorMetadata"].abi);
var vmBin = "0x" + vmOutput.contracts["$VALIDATORMETADATASOL:ValidatorMetadata"].bin;
var vtckAbi = JSON.parse(vtckOutput.contracts["$VOTINGTOCHANGEKEYSSOL:VotingToChangeKeys"].abi);
var vtckBin = "0x" + vtckOutput.contracts["$VOTINGTOCHANGEKEYSSOL:VotingToChangeKeys"].bin;
var vtcmtAbi = JSON.parse(vtcmtOutput.contracts["$VOTINGTOCHANGEMINTHRESHOLDSOL:VotingToChangeMinThreshold"].abi);
var vtcmtBin = "0x" + vtcmtOutput.contracts["$VOTINGTOCHANGEMINTHRESHOLDSOL:VotingToChangeMinThreshold"].bin;
var vtcpaAbi = JSON.parse(vtcpaOutput.contracts["$VOTINGTOCHANGEPROXYADDRESSSOL:VotingToChangeProxyAddress"].abi);
var vtcpaBin = "0x" + vtcpaOutput.contracts["$VOTINGTOCHANGEPROXYADDRESSSOL:VotingToChangeProxyAddress"].bin;

// console.log("DATA: bsAbi=" + JSON.stringify(bsAbi));
// console.log("DATA: bsBin=" + JSON.stringify(bsBin));
// console.log("DATA: kmAbi=" + JSON.stringify(kmAbi));
// console.log("DATA: kmBin=" + JSON.stringify(kmBin));
// console.log("DATA: pncAbi=" + JSON.stringify(pncAbi));
// console.log("DATA: pncBin=" + JSON.stringify(pncBin));
// console.log("DATA: psAbi=" + JSON.stringify(psAbi));
// console.log("DATA: psBin=" + JSON.stringify(psBin));
// console.log("DATA: vmAbi=" + JSON.stringify(vmAbi));
// console.log("DATA: vmBin=" + JSON.stringify(vmBin));
// console.log("DATA: vtckAbi=" + JSON.stringify(vtckAbi));
// console.log("DATA: vtckBin=" + JSON.stringify(vtckBin));
// console.log("DATA: vtcmtAbi=" + JSON.stringify(vtcmtAbi));
// console.log("DATA: vtcmtBin=" + JSON.stringify(vtcmtBin));
// console.log("DATA: vtcpaAbi=" + JSON.stringify(vtcpaAbi));
// console.log("DATA: vtcpaBin=" + JSON.stringify(vtcpaBin));

unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var pncMessage = "PoaNetworkConsensus";
// -----------------------------------------------------------------------------
console.log("RESULT: " + pncMessage);
var pncContract = web3.eth.contract(pncAbi);
// console.log(JSON.stringify(pncContract));
var pncTx = null;
var pncAddress = null;
var pnc = pncContract.new(moc, {from: contractOwnerAccount, data: pncBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        pncTx = contract.transactionHash;
      } else {
        pncAddress = contract.address;
        addAccount(pncAddress, "PoaNetworkConsensus");
        addPoaNetworkConsensusContractAddressAndAbi(pncAddress, pncAbi);
        console.log("DATA: pncAddress=" + pncAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(pncTx, pncMessage);
printTxData("pncTx", pncTx);
printPoaNetworkConsensusContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var psMessage = "ProxyStorage";
// -----------------------------------------------------------------------------
console.log("RESULT: " + psMessage);
var psContract = web3.eth.contract(psAbi);
// console.log(JSON.stringify(psContract));
var psTx = null;
var psAddress = null;
var ps = psContract.new(pncAddress, moc, {from: contractOwnerAccount, data: psBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        psTx = contract.transactionHash;
      } else {
        psAddress = contract.address;
        addAccount(psAddress, "ProxyStorage");
        addProxyStorageContractAddressAndAbi(psAddress, psAbi);
        console.log("DATA: psAddress=" + psAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(psTx, psMessage);
printTxData("psTx", psTx);
printProxyStorageContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var setupPnc_Message = "Setup PoaNetworkConsensus";
// -----------------------------------------------------------------------------
console.log("RESULT: " + setupPnc_Message);
var setupPnc_1Tx = pnc.setProxyStorage(psAddress, {from: moc, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(setupPnc_1Tx, setupPnc_Message + " - pnc.setProxyStorage(ps)");
printTxData("setupPnc_1Tx", setupPnc_1Tx);
printPoaNetworkConsensusContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var bsMessage = "BallotsStorage";
var vmMessage = "ValidatorMetadata";
var vtckMessage = "VotingToChangeKeys";
var vtcmtMessage = "VotingToChangeMinThreshold";
var vtcpaMessage = "VotingToChangeProxyAddress";
// -----------------------------------------------------------------------------
console.log("RESULT: " + bsMessage);
console.log("RESULT: " + vmMessage);
console.log("RESULT: " + vtckMessage);
console.log("RESULT: " + vtcmtMessage);
console.log("RESULT: " + vtcpaMessage);
var bsContract = web3.eth.contract(bsAbi);
// console.log(JSON.stringify(bsContract));
var bsTx = null;
var bsAddress = null;
var bs = bsContract.new(psAddress, {from: contractOwnerAccount, data: bsBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        bsTx = contract.transactionHash;
      } else {
        bsAddress = contract.address;
        addAccount(bsAddress, "BallotsStorage");
        addBallotsStorageContractAddressAndAbi(bsAddress, bsAbi);
        console.log("DATA: bsAddress=" + bsAddress);
      }
    }
  }
);
var vmContract = web3.eth.contract(vmAbi);
// console.log(JSON.stringify(vmContract));
var vmTx = null;
var vmAddress = null;
var vm = vmContract.new(psAddress, {from: contractOwnerAccount, data: vmBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        vmTx = contract.transactionHash;
      } else {
        vmAddress = contract.address;
        addAccount(vmAddress, "ValidatorMetadata");
        addValidatorMetadataContractAddressAndAbi(vmAddress, vmAbi);
        console.log("DATA: vmAddress=" + vmAddress);
      }
    }
  }
);
var vtckContract = web3.eth.contract(vtckAbi);
// console.log(JSON.stringify(vtckContract));
var vtckTx = null;
var vtckAddress = null;
var vtck = vtckContract.new(psAddress, {from: contractOwnerAccount, data: vtckBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        vtckTx = contract.transactionHash;
      } else {
        vtckAddress = contract.address;
        addAccount(vtckAddress, "VotingToChangeKeys");
        addVotingToChangeKeysContractAddressAndAbi(vtckAddress, vtckAbi);
        console.log("DATA: vtckAddress=" + vtckAddress);
      }
    }
  }
);
var vtcmtContract = web3.eth.contract(vtcmtAbi);
// console.log(JSON.stringify(vtcmtContract));
var vtcmtTx = null;
var vtcmtAddress = null;
var vtcmt = vtcmtContract.new(psAddress, {from: contractOwnerAccount, data: vtcmtBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        vtcmtTx = contract.transactionHash;
      } else {
        vtcmtAddress = contract.address;
        addAccount(vtcmtAddress, "VotingToChangeMinThreshold");
        addVotingToChangeMinThresholdContractAddressAndAbi(vtcmtAddress, vtcmtAbi);
        console.log("DATA: vtcmtAddress=" + vtcmtAddress);
      }
    }
  }
);
var vtcpaContract = web3.eth.contract(vtcpaAbi);
// console.log(JSON.stringify(vtcpaContract));
var vtcpaTx = null;
var vtcpaAddress = null;
var vtcpa = vtcpaContract.new(psAddress, {from: contractOwnerAccount, data: vtcpaBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        vtcpaTx = contract.transactionHash;
      } else {
        vtcpaAddress = contract.address;
        addAccount(vtcpaAddress, "VotingToChangeProxyAddress");
        addVotingToChangeProxyAddressContractAddressAndAbi(vtcpaAddress, vtcpaAbi);
        console.log("DATA: vtcpaAddress=" + vtcpaAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(bsTx, bsMessage);
failIfTxStatusError(vmTx, vmMessage);
failIfTxStatusError(vtckTx, vtckMessage);
failIfTxStatusError(vtcmtTx, vtcmtMessage);
failIfTxStatusError(vtcpaTx, vtcpaMessage);
printTxData("bsTx", bsTx);
printTxData("vmTx", vmTx);
printTxData("vtckTx", vtckTx);
printTxData("vtcmtTx", vtcmtTx);
printTxData("vtcpaTx", vtcpaTx);
printBallotsStorageContractDetails();
printValidatorMetadataContractDetails();
printVotingToChangeKeysContractDetails();
printVotingToChangeMinThresholdContractDetails();
printVotingToChangeProxyAddressContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var kmMessage = "KeysManager";
// -----------------------------------------------------------------------------
console.log("RESULT: " + kmMessage);
var kmContract = web3.eth.contract(kmAbi);
// console.log(JSON.stringify(kmContract));
var kmTx = null;
var kmAddress = null;
var km = kmContract.new(psAddress, pncAddress, moc, {from: contractOwnerAccount, data: kmBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        kmTx = contract.transactionHash;
      } else {
        kmAddress = contract.address;
        addAccount(kmAddress, "KeysManager");
        addKeysManagerContractAddressAndAbi(kmAddress, kmAbi);
        console.log("DATA: kmAddress=" + kmAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(kmTx, kmMessage);
printTxData("kmTx", kmTx);
printKeysManagerContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var setupPs_Message = "Setup ProxyStorage";
// -----------------------------------------------------------------------------
console.log("RESULT: " + setupPs_Message);
var setupPs_1Tx = ps.initializeAddresses(kmAddress, vtckAddress, vtcmtAddress, vtcpaAddress, bsAddress, {from: moc, gas: 200000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(setupPs_1Tx, setupPs_Message + " - ps.initializeAddresses(km, vtck, vtcmt, vtcpa, bs)");
printTxData("setupPs_1Tx", setupPs_1Tx);
printProxyStorageContractDetails();
console.log("RESULT: ");


exit;


// -----------------------------------------------------------------------------
var deployTokenFactoryMessage = "Deploy BTTSTokenFactory";
// -----------------------------------------------------------------------------
console.log("RESULT: " + deployTokenFactoryMessage);
// console.log("RESULT: tokenFactoryBin='" + tokenFactoryBin + "'");
var newTokenFactoryBin = tokenFactoryBin.replace(/__BTTSTokenFactory\.sol\:BTTSLib__________/g, tokenFactoryLibBTTSAddress.substring(2, 42));
// console.log("RESULT: newTokenFactoryBin='" + newTokenFactoryBin + "'");
var tokenFactoryContract = web3.eth.contract(tokenFactoryAbi);
// console.log(JSON.stringify(tokenFactoryAbi));
// console.log(tokenFactoryBin);
var tokenFactoryTx = null;
var tokenFactoryAddress = null;
var tokenFactory = tokenFactoryContract.new({from: contractOwnerAccount, data: newTokenFactoryBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenFactoryTx = contract.transactionHash;
      } else {
        tokenFactoryAddress = contract.address;
        addAccount(tokenFactoryAddress, "BTTSTokenFactory");
        addTokenFactoryContractAddressAndAbi(tokenFactoryAddress, tokenFactoryAbi);
        console.log("DATA: tokenFactoryAddress=" + tokenFactoryAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(tokenFactoryTx, deployTokenFactoryMessage);
printTxData("tokenFactoryTx", tokenFactoryTx);
printTokenFactoryContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var tokenMessage = "Deploy Token Contract";
var symbol = "GZE";
var name = "GazeCoin";
var decimals = 18;
var initialSupply = 0;
var mintable = true;
var transferable = false;
// -----------------------------------------------------------------------------
console.log("RESULT: " + tokenMessage);
var tokenContract = web3.eth.contract(tokenAbi);
// console.log(JSON.stringify(tokenContract));
var deployTokenTx = tokenFactory.deployBTTSTokenContract(symbol, name, decimals, initialSupply, mintable, transferable, {from: contractOwnerAccount, gas: 4000000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var bttsTokens = getBTTSFactoryTokenListing();
console.log("RESULT: bttsTokens=#" + bttsTokens.length + " " + JSON.stringify(bttsTokens));
// Can check, but the rest will not work anyway - if (bttsTokens.length == 1)
var tokenAddress = bttsTokens[0];
var token = web3.eth.contract(tokenAbi).at(tokenAddress);
// console.log("RESULT: token=" + JSON.stringify(token));
addAccount(tokenAddress, "Token '" + token.symbol() + "' '" + token.name() + "'");
addTokenContractAddressAndAbi(tokenAddress, tokenAbi);
printBalances();
printTxData("deployTokenTx", deployTokenTx);
printTokenFactoryContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var lockedWalletMessage = "Deploy Locked Wallet Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: " + lockedWalletMessage);
var lockedWalletContract = web3.eth.contract(lockedWalletAbi);
// console.log(JSON.stringify(lockedWalletContract));
var lockedWalletTx = null;
var lockedWalletAddress = null;
var lockedWallet = lockedWalletContract.new({from: contractOwnerAccount, data: lockedWalletBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        lockedWalletTx = contract.transactionHash;
      } else {
        lockedWalletAddress = contract.address;
        addAccount(lockedWalletAddress, "Locked Wallet");
        addLockedWalletContractAddressAndAbi(lockedWalletAddress, lockedWalletAbi);
        console.log("DATA: lockedWalletAddress=" + lockedWalletAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(lockedWalletTx, lockedWalletMessage);
printTxData("lockedWalletAddress=" + lockedWalletAddress, lockedWalletTx);
printLockedWalletContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var crowdsaleMessage = "Deploy GazeCoin Crowdsale Contract";
var bonusListMessage = "Deploy Bonus List Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: " + crowdsaleMessage);
var crowdsaleContract = web3.eth.contract(crowdsaleAbi);
// console.log(JSON.stringify(crowdsaleContract));
var crowdsaleTx = null;
var crowdsaleAddress = null;
var crowdsale = crowdsaleContract.new(wallet, lockedWalletAddress, {from: contractOwnerAccount, data: crowdsaleBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        crowdsaleTx = contract.transactionHash;
      } else {
        crowdsaleAddress = contract.address;
        addAccount(crowdsaleAddress, "GazeCoin Crowdsale");
        addCrowdsaleContractAddressAndAbi(crowdsaleAddress, crowdsaleAbi);
        console.log("DATA: crowdsaleAddress=" + crowdsaleAddress);
      }
    }
  }
);
console.log("RESULT: " + bonusListMessage);
var bonusListContract = web3.eth.contract(bonusListAbi);
// console.log(JSON.stringify(bonusListContract));
var bonusListTx = null;
var bonusListAddress = null;
var bonusList = bonusListContract.new({from: contractOwnerAccount, data: bonusListBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        bonusListTx = contract.transactionHash;
      } else {
        bonusListAddress = contract.address;
        addAccount(bonusListAddress, "Bonus List");
        addBonusListContractAddressAndAbi(bonusListAddress, bonusListAbi);
        console.log("DATA: bonusListAddress=" + bonusListAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(crowdsaleTx, crowdsaleMessage);
failIfTxStatusError(bonusListTx, bonusListMessage);
printTxData("crowdsaleAddress=" + crowdsaleAddress, crowdsaleTx);
printTxData("bonusListAddress=" + bonusListAddress, bonusListTx);
printCrowdsaleContractDetails();
printBonusListContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var setup_Message = "Setup";
// -----------------------------------------------------------------------------
console.log("RESULT: " + setup_Message);
var setup_1Tx = crowdsale.setBTTSToken(tokenAddress, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setup_2Tx = crowdsale.setBonusList(bonusListAddress, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setup_3Tx = crowdsale.setEndDate($END_DATE, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setup_4Tx = token.setMinter(crowdsaleAddress, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setup_5Tx = bonusList.add([account4], 1, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setup_6Tx = bonusList.add([account5], 2, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(setup_1Tx, setup_Message + " - crowdsale.setBTTSToken(tokenAddress)");
failIfTxStatusError(setup_2Tx, setup_Message + " - crowdsale.setBonusList(bonusListAddress)");
failIfTxStatusError(setup_3Tx, setup_Message + " - crowdsale.setEndDate($END_DATE)");
failIfTxStatusError(setup_4Tx, setup_Message + " - token.setMinter(crowdsaleAddress)");
failIfTxStatusError(setup_5Tx, setup_Message + " - bonusList.add([account4], 1)");
failIfTxStatusError(setup_6Tx, setup_Message + " - bonusList.add([account5], 2)");
printTxData("setup_1Tx", setup_1Tx);
printTxData("setup_2Tx", setup_2Tx);
printTxData("setup_3Tx", setup_3Tx);
printTxData("setup_4Tx", setup_4Tx);
printTxData("setup_5Tx", setup_5Tx);
printTxData("setup_6Tx", setup_6Tx);
printCrowdsaleContractDetails();
printBonusListContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var addPrecommitment_Message = "Add Precommitment";
// -----------------------------------------------------------------------------
console.log("RESULT: " + addPrecommitment_Message);
var addPrecommitment_1Tx = crowdsale.addPrecommitment(account8, web3.toWei(1000, "ether"), 35, {from: contractOwnerAccount, gas: 1000000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(addPrecommitment_1Tx, addPrecommitment_Message);
printTxData("addPrecommitment_1Tx", addPrecommitment_1Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


waitUntil("START_DATE", crowdsale.START_DATE(), 0);


// -----------------------------------------------------------------------------
var sendContribution1Message = "Send Contribution #1";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution1Message);
var sendContribution1_1Tx = eth.sendTransaction({from: account4, to: crowdsaleAddress, gas: 400000, value: web3.toWei("100", "ether")});
var sendContribution1_2Tx = eth.sendTransaction({from: account5, to: crowdsaleAddress, gas: 400000, value: web3.toWei("100", "ether")});
var sendContribution1_3Tx = eth.sendTransaction({from: account6, to: crowdsaleAddress, gas: 400000, value: web3.toWei("100", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution1_1Tx, sendContribution1Message + " - ac4 100 ETH - Bonus Tier 1 20%");
failIfTxStatusError(sendContribution1_2Tx, sendContribution1Message + " - ac5 100 ETH - Bonus Tier 2 15%");
failIfTxStatusError(sendContribution1_3Tx, sendContribution1Message + " - ac6 100 ETH - No Bonus");
printTxData("sendContribution1_1Tx", sendContribution1_1Tx);
printTxData("sendContribution1_2Tx", sendContribution1_2Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
printLockedWalletContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var sendContribution2Message = "Send Contribution #2";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution2Message);
var sendContribution2_1Tx = eth.sendTransaction({from: account6, to: crowdsaleAddress, gas: 400000, value: web3.toWei("50000", "ether")});
while (txpool.status.pending > 0) {
}
var sendContribution2_2Tx = eth.sendTransaction({from: account7, to: crowdsaleAddress, gas: 400000, value: web3.toWei("30000", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution2_1Tx, sendContribution2Message + " - ac6 50,000 ETH");
failIfTxStatusError(sendContribution2_2Tx, sendContribution2Message + " - ac7 30,000 ETH");
printTxData("sendContribution2_1Tx", sendContribution2_1Tx);
printTxData("sendContribution2_2Tx", sendContribution2_2Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
printLockedWalletContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var addPrecommitmentAdjustment_Message = "Add Precommitment Adjustment";
// -----------------------------------------------------------------------------
console.log("RESULT: " + addPrecommitmentAdjustment_Message);
var addPrecommitmentAdjustment_1Tx = crowdsale.addPrecommitmentAdjustment(account8, new BigNumber("111").shift(18), {from: contractOwnerAccount, gas: 1000000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(addPrecommitmentAdjustment_1Tx, addPrecommitmentAdjustment_Message);
printTxData("addPrecommitmentAdjustment_1Tx", addPrecommitmentAdjustment_1Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var finalise_Message = "Finalise Crowdsale";
// -----------------------------------------------------------------------------
console.log("RESULT: " + finalise_Message);
var finalise_1Tx = crowdsale.finalise({from: contractOwnerAccount, gas: 1000000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(finalise_1Tx, finalise_Message);
printTxData("finalise_1Tx", finalise_1Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


exit;

// -----------------------------------------------------------------------------
var whitelistAccounts_Message = "Whitelist Accounts";
// -----------------------------------------------------------------------------
console.log("RESULT: " + whitelistAccounts_Message);
var whitelistAccounts_1Tx = whitelist.multiAdd([account3, account5], [1, 1], {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(whitelistAccounts_1Tx, whitelistAccounts_Message + " - multiAdd([account3, account4, account5], [1, 1, 1])");
printTxData("whitelistAccounts_1Tx", whitelistAccounts_1Tx);
printWhitelistContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var picopsCertifierMessage = "Deploy Test PICOPS Certifier Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: " + picopsCertifierMessage);
var picopsCertifierContract = web3.eth.contract(picopsCertifierAbi);
// console.log(JSON.stringify(picopsCertifierContract));
var picopsCertifierTx = null;
var picopsCertifierAddress = null;
var picopsCertifier = picopsCertifierContract.new({from: contractOwnerAccount, data: picopsCertifierBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        picopsCertifierTx = contract.transactionHash;
      } else {
        picopsCertifierAddress = contract.address;
        addAccount(picopsCertifierAddress, "Test PICOPS Certifier");
        console.log("DATA: picopsCertifierAddress=" + picopsCertifierAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(picopsCertifierTx, picopsCertifierMessage);
printTxData("picopsCertifierAddress=" + picopsCertifierAddress, picopsCertifierTx);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var tokenMessage = "Deploy Token Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: " + tokenMessage);
var tokenContract = web3.eth.contract(tokenAbi);
// console.log(JSON.stringify(tokenContract));
var tokenTx = null;
var tokenAddress = null;
var token = tokenContract.new(wallet, {from: contractOwnerAccount, data: tokenBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenTx = contract.transactionHash;
      } else {
        tokenAddress = contract.address;
        addAccount(tokenAddress, "Token '" + token.symbol() + "' '" + token.name() + "'");
        addTokenContractAddressAndAbi(tokenAddress, tokenAbi);
        console.log("DATA: tokenAddress=" + tokenAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(tokenTx, tokenMessage);
printTxData("tokenAddress=" + tokenAddress, tokenTx);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var setTokenParameters_Message = "Set Token Contract Parameters";
// -----------------------------------------------------------------------------
console.log("RESULT: " + setTokenParameters_Message);
var setTokenParameters_1Tx = token.setEthMinContribution(web3.toWei(10, "ether"), {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setTokenParameters_2Tx = token.setUsdCap(2200000, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setTokenParameters_3Tx = token.setUsdPerKEther(444444, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setTokenParameters_4Tx = token.setWhitelist(whitelistAddress, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setTokenParameters_5Tx = token.setPICOPSCertifier(picopsCertifierAddress, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(setTokenParameters_1Tx, setTokenParameters_Message + " - token.setEthMinContribution(10 ETH)");
failIfTxStatusError(setTokenParameters_2Tx, setTokenParameters_Message + " - token.setUsdCap(2,200,000)");
failIfTxStatusError(setTokenParameters_3Tx, setTokenParameters_Message + " - token.setUsdPerKEther(444,444)");
failIfTxStatusError(setTokenParameters_4Tx, setTokenParameters_Message + " - token.setWhitelist(whitelistAddress)");
failIfTxStatusError(setTokenParameters_5Tx, setTokenParameters_Message + " - token.setPICOPSCertifier(picopsCertifierAddress)");
printTxData("setTokenParameters_1Tx", setTokenParameters_1Tx);
printTxData("setTokenParameters_2Tx", setTokenParameters_2Tx);
printTxData("setTokenParameters_3Tx", setTokenParameters_3Tx);
printTxData("setTokenParameters_4Tx", setTokenParameters_4Tx);
printTxData("setTokenParameters_5Tx", setTokenParameters_5Tx);
printTokenContractDetails();
console.log("RESULT: ");


waitUntil("START_DATE", token.START_DATE(), 0);


// -----------------------------------------------------------------------------
var sendContribution1Message = "Send Contribution #1";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution1Message);
var sendContribution1_1Tx = eth.sendTransaction({from: account3, to: tokenAddress, gas: 400000, value: web3.toWei("4000", "ether")});
var sendContribution1_2Tx = eth.sendTransaction({from: account6, to: tokenAddress, gas: 400000, value: web3.toWei("3000", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution1_1Tx, sendContribution1Message + " - ac3 4,000 ETH");
passIfTxStatusError(sendContribution1_2Tx, sendContribution1Message + " - ac6 3,000 ETH - Expecting failure as not whitelisted");
printTxData("sendContribution1_1Tx", sendContribution1_1Tx);
printTxData("sendContribution1_2Tx", sendContribution1_2Tx);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var sendContribution2Message = "Send Contribution #2";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution2Message);
var sendContribution2_1Tx = eth.sendTransaction({from: account4, to: tokenAddress, gas: 400000, value: web3.toWei("4000", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution2_1Tx, sendContribution2Message + " - ac4 4,000 ETH - Only partial amount accepted");
printTxData("sendContribution2_1Tx", sendContribution2_1Tx);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var sendContribution3Message = "Send Contribution #3";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution3Message);
var sendContribution3_1Tx = eth.sendTransaction({from: account5, to: tokenAddress, gas: 400000, value: web3.toWei("4000", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
passIfTxStatusError(sendContribution3_1Tx, sendContribution3Message + " - ac5 4,000 ETH - Expecting failure");
printTxData("sendContribution3_1Tx", sendContribution3_1Tx);
printTokenContractDetails();
console.log("RESULT: ");


exit;

// -----------------------------------------------------------------------------
var moveToken1_Message = "Move Tokens After Presale - To Redemption Wallet";
// -----------------------------------------------------------------------------
console.log("RESULT: " + moveToken1_Message);
var moveToken1_1Tx = token.transfer(redemptionWallet, "1000000", {from: account3, gas: 100000});
var moveToken1_2Tx = token.approve(account6,  "30000000", {from: account4, gas: 100000});
while (txpool.status.pending > 0) {
}
var moveToken1_3Tx = token.transferFrom(account4, redemptionWallet, "30000000", {from: account6, gas: 100000});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("moveToken1_1Tx", moveToken1_1Tx);
printTxData("moveToken1_2Tx", moveToken1_2Tx);
printTxData("moveToken1_3Tx", moveToken1_3Tx);
failIfTxStatusError(moveToken1_1Tx, moveToken1_Message + " - transfer 1 token ac3 -> redemptionWallet. CHECK for movement");
failIfTxStatusError(moveToken1_2Tx, moveToken1_Message + " - approve 30 tokens ac4 -> ac6");
failIfTxStatusError(moveToken1_3Tx, moveToken1_Message + " - transferFrom 30 tokens ac4 -> redemptionWallet by ac6. CHECK for movement");
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var moveToken2_Message = "Move Tokens After Presale - Not To Redemption Wallet";
// -----------------------------------------------------------------------------
console.log("RESULT: " + moveToken2_Message);
var moveToken2_1Tx = token.transfer(account5, "1000000", {from: account3, gas: 100000});
var moveToken2_2Tx = token.approve(account6,  "30000000", {from: account4, gas: 100000});
while (txpool.status.pending > 0) {
}
var moveToken2_3Tx = token.transferFrom(account4, account7, "30000000", {from: account6, gas: 100000});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("moveToken2_1Tx", moveToken2_1Tx);
printTxData("moveToken2_2Tx", moveToken2_2Tx);
printTxData("moveToken2_3Tx", moveToken2_3Tx);
passIfTxStatusError(moveToken2_1Tx, moveToken2_Message + " - transfer 1 token ac3 -> ac5. Expecting failure");
failIfTxStatusError(moveToken2_2Tx, moveToken2_Message + " - approve 30 tokens ac4 -> ac6");
passIfTxStatusError(moveToken2_3Tx, moveToken2_Message + " - transferFrom 30 tokens ac4 -> ac7 by ac6. Expecting failure");
printTokenContractDetails();
console.log("RESULT: ");


EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
