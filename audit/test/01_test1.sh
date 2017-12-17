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
`perl -pi -e "s/systemAddress \= 0xfffffffffffffffffffffffffffffffffffffffe;/systemAddress \= 0xa11AAE29840fBb5c86E6fd4cF809EBA183AEf433;/" $POANETWORKCONSENSUSSOL`
`perl -pi -e "s/address poaConsensus;/address public poaConsensus;/" $PROXYSTORAGESOL`
`perl -pi -e "s/address keysManager;/address public keysManager;/" $PROXYSTORAGESOL`
`perl -pi -e "s/address votingToChangeKeys;/address public votingToChangeKeys;/" $PROXYSTORAGESOL`
`perl -pi -e "s/address votingToChangeMinThreshold;/address public votingToChangeMinThreshold;/" $PROXYSTORAGESOL`
`perl -pi -e "s/address votingToChangeProxy;/address public votingToChangeProxy;/" $PROXYSTORAGESOL`
`perl -pi -e "s/address ballotsStorage;/address public ballotsStorage;/" $PROXYSTORAGESOL`
`perl -pi -e "s/uint8 thresholdForKeysType \= 1;/uint8 public thresholdForKeysType \= 1;/" $VOTINGTOCHANGEKEYSSOL`
`perl -pi -e "s/uint8 thresholdForKeysType \= 1;/uint8 public thresholdForKeysType \= 1;/" $VOTINGTOCHANGEMINTHRESHOLDSOL`
# `perl -pi -e "s/uint8 thresholdForKeysType \= 1;/uint8 public thresholdForKeysType \= 1;/" $VOTINGTOCHANGEPROXYADDRESSSOL`

DIFFS1=`diff $SOURCEDIR/$POANETWORKCONSENSUSSOL $POANETWORKCONSENSUSSOL`
echo "--- Differences $SOURCEDIR/$POANETWORKCONSENSUSSOL $POANETWORKCONSENSUSSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

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


// -----------------------------------------------------------------------------
var initiateKeys_Message = "Initiate Keys";
// -----------------------------------------------------------------------------
console.log("RESULT: " + initiateKeys_Message);
var initiateKeys_1Tx = km.initiateKeys(initial1, {from: moc, gas: 200000, gasPrice: defaultGasPrice});
var initiateKeys_2Tx = km.initiateKeys(initial2, {from: moc, gas: 200000, gasPrice: defaultGasPrice});
var initiateKeys_3Tx = km.initiateKeys(initial3, {from: moc, gas: 200000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(initiateKeys_1Tx, initiateKeys_Message + " - km.initiateKeys(initial1)");
failIfTxStatusError(initiateKeys_2Tx, initiateKeys_Message + " - km.initiateKeys(initial2)");
failIfTxStatusError(initiateKeys_3Tx, initiateKeys_Message + " - km.initiateKeys(initial3)");
printTxData("initiateKeys_1Tx", initiateKeys_1Tx);
printTxData("initiateKeys_1Tx", initiateKeys_2Tx);
printTxData("initiateKeys_1Tx", initiateKeys_3Tx);
printKeysManagerContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var createKeys_Message = "Create Keys";
// -----------------------------------------------------------------------------
console.log("RESULT: " + createKeys_Message);
var createKeys_1Tx = km.createKeys(mining1, voting1, payout1, {from: initial1, gas: 200000, gasPrice: defaultGasPrice});
var createKeys_2Tx = km.createKeys(mining2, voting2, payout2, {from: initial2, gas: 200000, gasPrice: defaultGasPrice});
var createKeys_3Tx = km.createKeys(mining3, voting3, payout3, {from: initial3, gas: 200000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(createKeys_1Tx, createKeys_Message + " - km.createKeys(mining1, voting1, payout1) from initial1");
failIfTxStatusError(createKeys_2Tx, createKeys_Message + " - km.createKeys(mining2, voting2, payout2) from initial2");
failIfTxStatusError(createKeys_3Tx, createKeys_Message + " - km.createKeys(mining3, voting3, payout3) from initial3");
printTxData("createKeys_1Tx", createKeys_1Tx);
printTxData("createKeys_1Tx", createKeys_2Tx);
printTxData("createKeys_1Tx", createKeys_3Tx);
printKeysManagerContractDetails();
printPoaNetworkConsensusContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var finaliseChange_Message = "Setup PoaNetworkConsensus";
// -----------------------------------------------------------------------------
console.log("RESULT: " + finaliseChange_Message);
var finaliseChange_1Tx = pnc.finalizeChange({from: contractOwnerAccount, gas: 400000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(finaliseChange_1Tx, finaliseChange_Message + " - pnc.finalizeChange");
printTxData("finaliseChange_1Tx", finaliseChange_1Tx);
printPoaNetworkConsensusContractDetails();
console.log("RESULT: ");




EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
