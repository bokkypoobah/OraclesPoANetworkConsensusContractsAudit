// ETH/USD 8 Dec 2017 11:00 EST => 8 Dec 2017 16:00 UTC => 9 Dec 2017 03:00 AEST => 453.55 from CMC
var ethPriceUSD = 453.55;
var defaultGasPrice = web3.toWei(50, "gwei");

// -----------------------------------------------------------------------------
// Accounts
// -----------------------------------------------------------------------------
var accounts = [];
var accountNames = {};

addAccount(eth.accounts[0], "Account #0 - Miner");
addAccount(eth.accounts[1], "Account #1 - Contract Owner");
addAccount(eth.accounts[2], "Account #2 - MoC");
addAccount(eth.accounts[3], "Account #3 - Initial #1");
addAccount(eth.accounts[4], "Account #4 - Initial #2");
addAccount(eth.accounts[5], "Account #5 - Initial #3");
addAccount(eth.accounts[6], "Account #6 - Mining #1");
addAccount(eth.accounts[7], "Account #7 - Mining #2");
addAccount(eth.accounts[8], "Account #8 - Mining #3");
addAccount(eth.accounts[9], "Account #9 - Voting #1");
addAccount(eth.accounts[10], "Account #10 - Voting #2");
addAccount(eth.accounts[11], "Account #11 - Voting #3");
addAccount(eth.accounts[12], "Account #12 - Payout #1");
addAccount(eth.accounts[13], "Account #13 - Payout #2");
addAccount(eth.accounts[14], "Account #14 - Payout #3");


var minerAccount = eth.accounts[0];
var contractOwnerAccount = eth.accounts[1];
var moc = eth.accounts[2];
var initial1 = eth.accounts[3];
var initial2 = eth.accounts[4];
var initial3 = eth.accounts[5];
var mining1 = eth.accounts[6];
var mining2 = eth.accounts[7];
var mining3 = eth.accounts[8];
var voting1 = eth.accounts[9];
var voting2 = eth.accounts[10];
var voting3 = eth.accounts[11];
var payout1 = eth.accounts[12];
var payout2 = eth.accounts[13];
var payout3 = eth.accounts[14];

var baseBlock = eth.blockNumber;

function unlockAccounts(password) {
  for (var i = 0; i < eth.accounts.length && i < accounts.length; i++) {
    personal.unlockAccount(eth.accounts[i], password, 100000);
  }
}

function addAccount(account, accountName) {
  accounts.push(account);
  accountNames[account] = accountName;
}


// -----------------------------------------------------------------------------
// Token Contract
// -----------------------------------------------------------------------------
var tokenContractAddress = null;
var tokenContractAbi = null;

function addTokenContractAddressAndAbi(address, tokenAbi) {
  tokenContractAddress = address;
  tokenContractAbi = tokenAbi;
}


// -----------------------------------------------------------------------------
// Account ETH and token balances
// -----------------------------------------------------------------------------
function printBalances() {
  // console.log("RESULT: baseBlock=" + baseBlock);
  var token = tokenContractAddress == null || tokenContractAbi == null ? null : web3.eth.contract(tokenContractAbi).at(tokenContractAddress);
  var decimals = token == null ? 18 : token.decimals();
  var i = 0;
  var totalTokenBalance = new BigNumber(0);
  console.log("RESULT:  # Account                                             EtherBalanceChange                          Token Name");
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------");
  accounts.forEach(function(e) {
    var etherBalanceBaseBlock = eth.getBalance(e, baseBlock);
    var etherBalance = web3.fromWei(eth.getBalance(e).minus(etherBalanceBaseBlock), "ether");
    var tokenBalance = token == null ? new BigNumber(0) : token.balanceOf(e).shift(-decimals);
    totalTokenBalance = totalTokenBalance.add(tokenBalance);
    console.log("RESULT: " + pad2(i) + " " + e  + " " + pad(etherBalance) + " " + padToken(tokenBalance, decimals) + " " + accountNames[e]);
    i++;
  });
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------");
  console.log("RESULT:                                                                           " + padToken(totalTokenBalance, decimals) + " Total Token Balances");
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------");
  console.log("RESULT: ");
}

function pad2(s) {
  var o = s.toFixed(0);
  while (o.length < 2) {
    o = " " + o;
  }
  return o;
}

function pad(s) {
  var o = s.toFixed(18);
  while (o.length < 27) {
    o = " " + o;
  }
  return o;
}

function padToken(s, decimals) {
  var o = s.toFixed(decimals);
  var l = parseInt(decimals)+12;
  while (o.length < l) {
    o = " " + o;
  }
  return o;
}


// -----------------------------------------------------------------------------
// Transaction status
// -----------------------------------------------------------------------------
function printTxData(name, txId) {
  var tx = eth.getTransaction(txId);
  var txReceipt = eth.getTransactionReceipt(txId);
  var gasPrice = tx.gasPrice;
  var gasCostETH = tx.gasPrice.mul(txReceipt.gasUsed).div(1e18);
  var gasCostUSD = gasCostETH.mul(ethPriceUSD);
  var block = eth.getBlock(txReceipt.blockNumber);
  console.log("RESULT: " + name + " status=" + txReceipt.status + (txReceipt.status == 0 ? " Failure" : " Success") + " gas=" + tx.gas +
    " gasUsed=" + txReceipt.gasUsed + " costETH=" + gasCostETH + " costUSD=" + gasCostUSD +
    " @ ETH/USD=" + ethPriceUSD + " gasPrice=" + web3.fromWei(gasPrice, "gwei") + " gwei block=" +
    txReceipt.blockNumber + " txIx=" + tx.transactionIndex + " txId=" + txId +
    " @ " + block.timestamp + " " + new Date(block.timestamp * 1000).toUTCString());
}

function assertEtherBalance(account, expectedBalance) {
  var etherBalance = web3.fromWei(eth.getBalance(account), "ether");
  if (etherBalance == expectedBalance) {
    console.log("RESULT: OK " + account + " has expected balance " + expectedBalance);
  } else {
    console.log("RESULT: FAILURE " + account + " has balance " + etherBalance + " <> expected " + expectedBalance);
  }
}

function failIfTxStatusError(tx, msg) {
  var status = eth.getTransactionReceipt(tx).status;
  if (status == 0) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function passIfTxStatusError(tx, msg) {
  var status = eth.getTransactionReceipt(tx).status;
  if (status == 1) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function gasEqualsGasUsed(tx) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  return (gas == gasUsed);
}

function failIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function passIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: PASS " + msg);
    return 1;
  } else {
    console.log("RESULT: FAIL " + msg);
    return 0;
  }
}

function failIfGasEqualsGasUsedOrContractAddressNull(contractAddress, tx, msg) {
  if (contractAddress == null) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    var gas = eth.getTransaction(tx).gas;
    var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
    if (gas == gasUsed) {
      console.log("RESULT: FAIL " + msg);
      return 0;
    } else {
      console.log("RESULT: PASS " + msg);
      return 1;
    }
  }
}


//-----------------------------------------------------------------------------
//Wait until some unixTime + additional seconds
//-----------------------------------------------------------------------------
function waitUntil(message, unixTime, addSeconds) {
  var t = parseInt(unixTime) + parseInt(addSeconds) + parseInt(1);
  var time = new Date(t * 1000);
  console.log("RESULT: Waiting until '" + message + "' at " + unixTime + "+" + addSeconds + "s =" + time + " now=" + new Date());
  while ((new Date()).getTime() <= time.getTime()) {
  }
  console.log("RESULT: Waited until '" + message + "' at at " + unixTime + "+" + addSeconds + "s =" + time + " now=" + new Date());
  console.log("RESULT: ");
}


//-----------------------------------------------------------------------------
//Wait until some block
//-----------------------------------------------------------------------------
function waitUntilBlock(message, block, addBlocks) {
  var b = parseInt(block) + parseInt(addBlocks);
  console.log("RESULT: Waiting until '" + message + "' #" + block + "+" + addBlocks + " = #" + b + " currentBlock=" + eth.blockNumber);
  while (eth.blockNumber <= b) {
  }
  console.log("RESULT: Waited until '" + message + "' #" + block + "+" + addBlocks + " = #" + b + " currentBlock=" + eth.blockNumber);
  console.log("RESULT: ");
}


// -----------------------------------------------------------------------------
// BallotsStorage Contract
// -----------------------------------------------------------------------------
var ballotsStorageContractAddress = null;
var ballotsStorageContractAbi = null;

function addBallotsStorageContractAddressAndAbi(address, ballotsStorageAbi) {
  ballotsStorageContractAddress = address;
  ballotsStorageContractAbi = ballotsStorageAbi;
}

var ballotsStorageManagerFromBlock = 0;
function printBallotsStorageContractDetails() {
  console.log("RESULT: ballotsStorageContractAddress=" + ballotsStorageContractAddress);
  if (ballotsStorageContractAddress != null && ballotsStorageContractAbi != null) {
    var contract = eth.contract(ballotsStorageContractAbi).at(ballotsStorageContractAddress);
    console.log("RESULT: ballotsStorage.proxyStorage=" + contract.proxyStorage());

    var latestBlock = eth.blockNumber;
    var i;

    var thresholdChangedEvents = contract.ThresholdChanged({}, { fromBlock: ballotsStorageManagerFromBlock, toBlock: latestBlock });
    i = 0;
    thresholdChangedEvents.watch(function (error, result) {
      console.log("RESULT: ThresholdChanged " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    thresholdChangedEvents.stopWatching();

    ballotsStorageManagerFromBlock = latestBlock + 1;
  }
}


// -----------------------------------------------------------------------------
// KeysManager Contract
// -----------------------------------------------------------------------------
var keysManagerContractAddress = null;
var keysManagerContractAbi = null;

function addKeysManagerContractAddressAndAbi(address, keysManagerAbi) {
  keysManagerContractAddress = address;
  keysManagerContractAbi = keysManagerAbi;
}

var keysManagerFromBlock = 0;
function printKeysManagerContractDetails() {
  console.log("RESULT: keysManagerContractAddress=" + keysManagerContractAddress);
  if (keysManagerContractAddress != null && keysManagerContractAbi != null) {
    var contract = eth.contract(keysManagerContractAbi).at(keysManagerContractAddress);
    console.log("RESULT: keysManager.masterOfCeremony=" + contract.masterOfCeremony());
    console.log("RESULT: keysManager.proxyStorage=" + contract.proxyStorage());
    console.log("RESULT: keysManager.poaNetworkConsensus=" + contract.poaNetworkConsensus());
    console.log("RESULT: keysManager.maxNumberOfInitialKeys=" + contract.maxNumberOfInitialKeys());
    console.log("RESULT: keysManager.initialKeysCount=" + contract.initialKeysCount());
    console.log("RESULT: keysManager.maxLimitValidators=" + contract.maxLimitValidators());

    var latestBlock = eth.blockNumber;
    var i;

    var payoutKeyChangedEvents = contract.PayoutKeyChanged({}, { fromBlock: keysManagerFromBlock, toBlock: latestBlock });
    i = 0;
    payoutKeyChangedEvents.watch(function (error, result) {
      console.log("RESULT: PayoutKeyChanged " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    payoutKeyChangedEvents.stopWatching();

    var votingKeyChangedEvents = contract.VotingKeyChanged({}, { fromBlock: keysManagerFromBlock, toBlock: latestBlock });
    i = 0;
    votingKeyChangedEvents.watch(function (error, result) {
      console.log("RESULT: VotingKeyChanged " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    votingKeyChangedEvents.stopWatching();

    var miningKeyChangedEvents = contract.MiningKeyChanged({}, { fromBlock: keysManagerFromBlock, toBlock: latestBlock });
    i = 0;
    miningKeyChangedEvents.watch(function (error, result) {
      console.log("RESULT: MiningKeyChanged " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    miningKeyChangedEvents.stopWatching();

    var validatorInitializedEvents = contract.ValidatorInitialized({}, { fromBlock: keysManagerFromBlock, toBlock: latestBlock });
    i = 0;
    validatorInitializedEvents.watch(function (error, result) {
      console.log("RESULT: ValidatorInitialized " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    validatorInitializedEvents.stopWatching();

    var initialKeyCreatedEvents = contract.InitialKeyCreated({}, { fromBlock: keysManagerFromBlock, toBlock: latestBlock });
    i = 0;
    initialKeyCreatedEvents.watch(function (error, result) {
      console.log("RESULT: InitialKeyCreated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    initialKeyCreatedEvents.stopWatching();

    keysManagerFromBlock = latestBlock + 1;
  }
}


// -----------------------------------------------------------------------------
// PoaNetworkConsensus Contract
// -----------------------------------------------------------------------------
var poaNetworkConsensusContractAddress = null;
var poaNetworkConsensusContractAbi = null;

function addPoaNetworkConsensusContractAddressAndAbi(address, poaNetworkConsensusAbi) {
  poaNetworkConsensusContractAddress = address;
  poaNetworkConsensusContractAbi = poaNetworkConsensusAbi;
}

var poaNetworkConsensusFromBlock = 0;
function printPoaNetworkConsensusContractDetails() {
  console.log("RESULT: poaNetworkConsensusContractAddress=" + poaNetworkConsensusContractAddress);
  if (poaNetworkConsensusContractAddress != null && poaNetworkConsensusContractAbi != null) {
    var contract = eth.contract(poaNetworkConsensusContractAbi).at(poaNetworkConsensusContractAddress);
    console.log("RESULT: poaNetworkConsensus.finalized=" + contract.finalized());
    console.log("RESULT: poaNetworkConsensus.isMasterOfCeremonyInitialized=" + contract.isMasterOfCeremonyInitialized());
    console.log("RESULT: poaNetworkConsensus.systemAddress=" + contract.systemAddress());
    console.log("RESULT: poaNetworkConsensus.currentValidators(0)=" + contract.currentValidators(0));
    console.log("RESULT: poaNetworkConsensus.pendingList(0)=" + contract.pendingList(0));
    console.log("RESULT: poaNetworkConsensus.currentValidatorsLength=" + contract.currentValidatorsLength());
    console.log("RESULT: poaNetworkConsensus.proxyStorage=" + contract.proxyStorage());

    var latestBlock = eth.blockNumber;
    var i;

    var initiateChangeEvents = contract.InitiateChange({}, { fromBlock: poaNetworkConsensusFromBlock, toBlock: latestBlock });
    i = 0;
    initiateChangeEvents.watch(function (error, result) {
      console.log("RESULT: InitiateChange " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    initiateChangeEvents.stopWatching();

    var changeFinalizedEvents = contract.ChangeFinalized({}, { fromBlock: poaNetworkConsensusFromBlock, toBlock: latestBlock });
    i = 0;
    changeFinalizedEvents.watch(function (error, result) {
      console.log("RESULT: ChangeFinalized " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    changeFinalizedEvents.stopWatching();

    var changeReferenceEvents = contract.ChangeReference({}, { fromBlock: poaNetworkConsensusFromBlock, toBlock: latestBlock });
    i = 0;
    changeReferenceEvents.watch(function (error, result) {
      console.log("RESULT: ChangeReference " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    changeReferenceEvents.stopWatching();

    var moCInitializedProxyStorageEvents = contract.MoCInitializedProxyStorage({}, { fromBlock: poaNetworkConsensusFromBlock, toBlock: latestBlock });
    i = 0;
    moCInitializedProxyStorageEvents.watch(function (error, result) {
      console.log("RESULT: MoCInitializedProxyStorage " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    moCInitializedProxyStorageEvents.stopWatching();

    poaNetworkConsensusFromBlock = latestBlock + 1;
  }
}


// -----------------------------------------------------------------------------
// ProxyStorage Contract
// -----------------------------------------------------------------------------
var proxyStorageContractAddress = null;
var proxyStorageContractAbi = null;

function addProxyStorageContractAddressAndAbi(address, proxyStorageAbi) {
  proxyStorageContractAddress = address;
  proxyStorageContractAbi = proxyStorageAbi;
}

var proxyStorageFromBlock = 0;
function printProxyStorageContractDetails() {
  console.log("RESULT: proxyStorageContractAddress=" + proxyStorageContractAddress);
  if (proxyStorageContractAddress != null && proxyStorageContractAbi != null) {
    var contract = eth.contract(proxyStorageContractAbi).at(proxyStorageContractAddress);
    console.log("RESULT: proxyStorage.masterOfCeremony=" + contract.masterOfCeremony());
    console.log("RESULT: proxyStorage.poaConsensus=" + contract.poaConsensus());
    console.log("RESULT: proxyStorage.keysManager=" + contract.keysManager());
    console.log("RESULT: proxyStorage.votingToChangeKeys=" + contract.votingToChangeKeys());
    console.log("RESULT: proxyStorage.votingToChangeMinThreshold=" + contract.votingToChangeMinThreshold());
    console.log("RESULT: proxyStorage.votingToChangeProxy=" + contract.votingToChangeProxy());
    console.log("RESULT: proxyStorage.ballotsStorage=" + contract.ballotsStorage());
    console.log("RESULT: proxyStorage.mocInitialized=" + contract.mocInitialized());

    var latestBlock = eth.blockNumber;
    var i;

    var proxyInitializedEvents = contract.ProxyInitialized({}, { fromBlock: proxyStorageFromBlock, toBlock: latestBlock });
    i = 0;
    proxyInitializedEvents.watch(function (error, result) {
      console.log("RESULT: ProxyInitialized " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    proxyInitializedEvents.stopWatching();

    var addressSetEvents = contract.AddressSet({}, { fromBlock: proxyStorageFromBlock, toBlock: latestBlock });
    i = 0;
    addressSetEvents.watch(function (error, result) {
      console.log("RESULT: AddressSet " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    addressSetEvents.stopWatching();

    proxyStorageFromBlock = latestBlock + 1;
  }
}


// -----------------------------------------------------------------------------
// ValidatorMetadata Contract
// -----------------------------------------------------------------------------
var validatorMetadataContractAddress = null;
var validatorMetadataContractAbi = null;

function addValidatorMetadataContractAddressAndAbi(address, validatorMetadataAbi) {
  validatorMetadataContractAddress = address;
  validatorMetadataContractAbi = validatorMetadataAbi;
}

var validatorMetadataFromBlock = 0;
function printValidatorMetadataContractDetails() {
  console.log("RESULT: validatorMetadataContractAddress=" + validatorMetadataContractAddress);
  if (validatorMetadataContractAddress != null && validatorMetadataContractAbi != null) {
    var contract = eth.contract(validatorMetadataContractAbi).at(validatorMetadataContractAddress);
    console.log("RESULT: validatorMetadata.proxyStorage=" + contract.proxyStorage());

    var latestBlock = eth.blockNumber;
    var i;

    var metadataCreatedEvents = contract.MetadataCreated({}, { fromBlock: validatorMetadataFromBlock, toBlock: latestBlock });
    i = 0;
    metadataCreatedEvents.watch(function (error, result) {
      console.log("RESULT: MetadataCreated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    metadataCreatedEvents.stopWatching();

    var changeRequestInitiatedEvents = contract.ChangeRequestInitiated({}, { fromBlock: validatorMetadataFromBlock, toBlock: latestBlock });
    i = 0;
    changeRequestInitiatedEvents.watch(function (error, result) {
      console.log("RESULT: ChangeRequestInitiated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    changeRequestInitiatedEvents.stopWatching();

    var cancelledRequestEvents = contract.CancelledRequest({}, { fromBlock: validatorMetadataFromBlock, toBlock: latestBlock });
    i = 0;
    cancelledRequestEvents.watch(function (error, result) {
      console.log("RESULT: CancelledRequest " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    cancelledRequestEvents.stopWatching();

    var confirmedEvents = contract.Confirmed({}, { fromBlock: validatorMetadataFromBlock, toBlock: latestBlock });
    i = 0;
    confirmedEvents.watch(function (error, result) {
      console.log("RESULT: Confirmed " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    confirmedEvents.stopWatching();

    var finalizedChangeEvents = contract.FinalizedChange({}, { fromBlock: validatorMetadataFromBlock, toBlock: latestBlock });
    i = 0;
    finalizedChangeEvents.watch(function (error, result) {
      console.log("RESULT: FinalizedChange " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    finalizedChangeEvents.stopWatching();

    validatorMetadataFromBlock = latestBlock + 1;
  }
}


// -----------------------------------------------------------------------------
// VotingToChangeKeys Contract
// -----------------------------------------------------------------------------
var votingToChangeKeysContractAddress = null;
var votingToChangeKeysContractAbi = null;

function addVotingToChangeKeysContractAddressAndAbi(address, votingToChangeKeysAbi) {
  votingToChangeKeysContractAddress = address;
  votingToChangeKeysContractAbi = votingToChangeKeysAbi;
}

var votingToChangeKeysFromBlock = 0;
function printVotingToChangeKeysContractDetails() {
  console.log("RESULT: votingToChangeKeysContractAddress=" + votingToChangeKeysContractAddress);
  if (votingToChangeKeysContractAddress != null && votingToChangeKeysContractAbi != null) {
    var contract = eth.contract(votingToChangeKeysContractAbi).at(votingToChangeKeysContractAddress);
    console.log("RESULT: votingToChangeKeys.proxyStorage=" + contract.proxyStorage());
    console.log("RESULT: votingToChangeKeys.maxOldMiningKeysDeepCheck=" + contract.maxOldMiningKeysDeepCheck());
    console.log("RESULT: votingToChangeKeys.nextBallotId=" + contract.nextBallotId());
    console.log("RESULT: votingToChangeKeys.activeBallots(0)=" + contract.activeBallots(0));
    console.log("RESULT: votingToChangeKeys.activeBallotsLength=" + contract.activeBallotsLength());
    console.log("RESULT: votingToChangeKeys.thresholdForKeysType=" + contract.thresholdForKeysType());

    var latestBlock = eth.blockNumber;
    var i;

    var voteEvents = contract.Vote({}, { fromBlock: votingToChangeKeysFromBlock, toBlock: latestBlock });
    i = 0;
    voteEvents.watch(function (error, result) {
      console.log("RESULT: Vote " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    voteEvents.stopWatching();

    var ballotFinalizedEvents = contract.BallotFinalized({}, { fromBlock: votingToChangeKeysFromBlock, toBlock: latestBlock });
    i = 0;
    ballotFinalizedEvents.watch(function (error, result) {
      console.log("RESULT: BallotFinalized " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    ballotFinalizedEvents.stopWatching();

    var ballotCreatedEvents = contract.BallotCreated({}, { fromBlock: votingToChangeKeysFromBlock, toBlock: latestBlock });
    i = 0;
    ballotCreatedEvents.watch(function (error, result) {
      console.log("RESULT: BallotCreated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    ballotCreatedEvents.stopWatching();

    votingToChangeKeysFromBlock = latestBlock + 1;
  }
}


// -----------------------------------------------------------------------------
// VotingToChangeMinThreshold Contract
// -----------------------------------------------------------------------------
var votingToChangeMinThresholdContractAddress = null;
var votingToChangeMinThresholdContractAbi = null;

function addVotingToChangeMinThresholdContractAddressAndAbi(address, votingToChangeMinThresholdAbi) {
  votingToChangeMinThresholdContractAddress = address;
  votingToChangeMinThresholdContractAbi = votingToChangeMinThresholdAbi;
}

var votingToChangeMinThresholdFromBlock = 0;
function printVotingToChangeMinThresholdContractDetails() {
  console.log("RESULT: votingToChangeMinThresholdContractAddress=" + votingToChangeMinThresholdContractAddress);
  if (votingToChangeMinThresholdContractAddress != null && votingToChangeMinThresholdContractAbi != null) {
    var contract = eth.contract(votingToChangeMinThresholdContractAbi).at(votingToChangeMinThresholdContractAddress);
    console.log("RESULT: votingToChangeMinThreshold.proxyStorage=" + contract.proxyStorage());
    console.log("RESULT: votingToChangeMinThreshold.maxOldMiningKeysDeepCheck=" + contract.maxOldMiningKeysDeepCheck());
    console.log("RESULT: votingToChangeMinThreshold.nextBallotId=" + contract.nextBallotId());
    console.log("RESULT: votingToChangeMinThreshold.activeBallots(0)=" + contract.activeBallots(0));
    console.log("RESULT: votingToChangeMinThreshold.activeBallotsLength=" + contract.activeBallotsLength());
    console.log("RESULT: votingToChangeMinThreshold.thresholdForKeysType=" + contract.thresholdForKeysType());

    var latestBlock = eth.blockNumber;
    var i;

    var voteEvents = contract.Vote({}, { fromBlock: votingToChangeMinThresholdFromBlock, toBlock: latestBlock });
    i = 0;
    voteEvents.watch(function (error, result) {
      console.log("RESULT: Vote " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    voteEvents.stopWatching();

    var ballotFinalizedEvents = contract.BallotFinalized({}, { fromBlock: votingToChangeMinThresholdFromBlock, toBlock: latestBlock });
    i = 0;
    ballotFinalizedEvents.watch(function (error, result) {
      console.log("RESULT: BallotFinalized " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    ballotFinalizedEvents.stopWatching();

    var ballotCreatedEvents = contract.BallotCreated({}, { fromBlock: votingToChangeMinThresholdFromBlock, toBlock: latestBlock });
    i = 0;
    ballotCreatedEvents.watch(function (error, result) {
      console.log("RESULT: BallotCreated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    ballotCreatedEvents.stopWatching();

    votingToChangeMinThresholdFromBlock = latestBlock + 1;
  }
}


// -----------------------------------------------------------------------------
// VotingToChangeMinThreshold Contract
// -----------------------------------------------------------------------------
var votingToChangeMinThresholdContractAddress = null;
var votingToChangeMinThresholdContractAbi = null;

function addVotingToChangeMinThresholdContractAddressAndAbi(address, votingToChangeMinThresholdAbi) {
  votingToChangeMinThresholdContractAddress = address;
  votingToChangeMinThresholdContractAbi = votingToChangeMinThresholdAbi;
}

var votingToChangeMinThresholdFromBlock = 0;
function printVotingToChangeMinThresholdContractDetails() {
  console.log("RESULT: votingToChangeMinThresholdContractAddress=" + votingToChangeMinThresholdContractAddress);
  if (votingToChangeMinThresholdContractAddress != null && votingToChangeMinThresholdContractAbi != null) {
    var contract = eth.contract(votingToChangeMinThresholdContractAbi).at(votingToChangeMinThresholdContractAddress);
    console.log("RESULT: votingToChangeMinThreshold.proxyStorage=" + contract.proxyStorage());
    console.log("RESULT: votingToChangeMinThreshold.maxOldMiningKeysDeepCheck=" + contract.maxOldMiningKeysDeepCheck());
    console.log("RESULT: votingToChangeMinThreshold.nextBallotId=" + contract.nextBallotId());
    console.log("RESULT: votingToChangeMinThreshold.activeBallots(0)=" + contract.activeBallots(0));
    console.log("RESULT: votingToChangeMinThreshold.activeBallotsLength=" + contract.activeBallotsLength());
    console.log("RESULT: votingToChangeMinThreshold.thresholdForKeysType=" + contract.thresholdForKeysType());

    var latestBlock = eth.blockNumber;
    var i;

    var voteEvents = contract.Vote({}, { fromBlock: votingToChangeMinThresholdFromBlock, toBlock: latestBlock });
    i = 0;
    voteEvents.watch(function (error, result) {
      console.log("RESULT: Vote " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    voteEvents.stopWatching();

    var ballotFinalizedEvents = contract.BallotFinalized({}, { fromBlock: votingToChangeMinThresholdFromBlock, toBlock: latestBlock });
    i = 0;
    ballotFinalizedEvents.watch(function (error, result) {
      console.log("RESULT: BallotFinalized " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    ballotFinalizedEvents.stopWatching();

    var ballotCreatedEvents = contract.BallotCreated({}, { fromBlock: votingToChangeMinThresholdFromBlock, toBlock: latestBlock });
    i = 0;
    ballotCreatedEvents.watch(function (error, result) {
      console.log("RESULT: BallotCreated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    ballotCreatedEvents.stopWatching();

    votingToChangeMinThresholdFromBlock = latestBlock + 1;
  }
}


// -----------------------------------------------------------------------------
// VotingToChangeProxyAddress Contract
// -----------------------------------------------------------------------------
var votingToChangeProxyAddressContractAddress = null;
var votingToChangeProxyAddressContractAbi = null;

function addVotingToChangeProxyAddressContractAddressAndAbi(address, votingToChangeProxyAddressAbi) {
  votingToChangeProxyAddressContractAddress = address;
  votingToChangeProxyAddressContractAbi = votingToChangeProxyAddressAbi;
}

var votingToChangeProxyAddressFromBlock = 0;
function printVotingToChangeProxyAddressContractDetails() {
  console.log("RESULT: votingToChangeProxyAddressContractAddress=" + votingToChangeProxyAddressContractAddress);
  if (votingToChangeProxyAddressContractAddress != null && votingToChangeProxyAddressContractAbi != null) {
    var contract = eth.contract(votingToChangeProxyAddressContractAbi).at(votingToChangeProxyAddressContractAddress);
    console.log("RESULT: votingToChangeProxyAddress.proxyStorage=" + contract.proxyStorage());
    console.log("RESULT: votingToChangeProxyAddress.maxOldMiningKeysDeepCheck=" + contract.maxOldMiningKeysDeepCheck());
    console.log("RESULT: votingToChangeProxyAddress.nextBallotId=" + contract.nextBallotId());
    console.log("RESULT: votingToChangeProxyAddress.activeBallots(0)=" + contract.activeBallots(0));
    console.log("RESULT: votingToChangeProxyAddress.activeBallotsLength=" + contract.activeBallotsLength());
    // console.log("RESULT: votingToChangeProxyAddress.thresholdForKeysType=" + contract.thresholdForKeysType());

    var latestBlock = eth.blockNumber;
    var i;

    var voteEvents = contract.Vote({}, { fromBlock: votingToChangeProxyAddressFromBlock, toBlock: latestBlock });
    i = 0;
    voteEvents.watch(function (error, result) {
      console.log("RESULT: Vote " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    voteEvents.stopWatching();

    var ballotFinalizedEvents = contract.BallotFinalized({}, { fromBlock: votingToChangeProxyAddressFromBlock, toBlock: latestBlock });
    i = 0;
    ballotFinalizedEvents.watch(function (error, result) {
      console.log("RESULT: BallotFinalized " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    ballotFinalizedEvents.stopWatching();

    var ballotCreatedEvents = contract.BallotCreated({}, { fromBlock: votingToChangeProxyAddressFromBlock, toBlock: latestBlock });
    i = 0;
    ballotCreatedEvents.watch(function (error, result) {
      console.log("RESULT: BallotCreated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    ballotCreatedEvents.stopWatching();

    votingToChangeProxyAddressFromBlock = latestBlock + 1;
  }
}

