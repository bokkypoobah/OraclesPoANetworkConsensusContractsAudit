# Oracles Network PoA Network Consensus Contracts Audit

Status: Work in progress (Aiming for < 15/12/2017)

## Summary

[Oracles Network](https://oracles.org/) completed it's presale in Dec 2017.

Bok Consulting Pty Ltd was commissioned to perform an audit on the Oracles Network's PoA Network Consensus Ethereum smart contract.

This audit has been conducted on Oracles Network's source code in commits
[f706e4f](https://github.com/oraclesorg/poa-network-consensus-contracts/commit/f706e4fa8d846b03c5f935e22696cc373d28afea),
[9625b09](https://github.com/oraclesorg/poa-network-consensus-contracts/commit/9625b09e3f8af8dd4e30fade6b3ca653f5781f49),
[cec573c](https://github.com/oraclesorg/poa-network-consensus-contracts/commit/cec573cf93480355510c299b5d1b0fd39b5578d3) and
[fd8f215](https://github.com/oraclesorg/poa-network-consensus-contracts/commit/fd8f2154b02c132e38ea07e95254f31f7511ca0a).

TODO: Check that no potential vulnerabilities have been identified in the presale contract.

<br />

<hr />

## Table Of Contents

* [Summary](#summary)
* [Testing](#testing)
* [Code Review](#code-review)
* [Example To Demonstrate The Shadowing Of Variables](#example-to-demonstrate-the-shadowing-of-variables)

<br />

<hr />

## Recommendations

* **MEDIUM IMPORTANCE** The following variables are duplicated in *IPoaNetworkConsensus* and *PoaNetworkConsensus*:
  `finalized`, `systemAddress`, `currentValidators`, `pendingList`, `currentValidatorsLength`. This can lead to strange
  results if functions in *IPoaNetworkConsensus* access it's version of these variables, which is not the case. See
  [Example To Demonstrate The Shadowing Of Variables](#example-to-demonstrate-the-shadowing-of-variables) for an
  example where a function in the base class access the base class variable. Only `currentValidatorsLength` is read
  from the `IPoaNetworkConsensus`, but is written to in *KeysManager* and *BallotsStorage*

<br />

<hr />

## Testing

* Setting up contracts
  * Deploy `PoaNetworkConsensus(mocWallet)`
  * Deploy `ProxyStorage(poaNetworkConsensus, mocWallet)`
  * `PoaNetworkConsensus.setProxyStorage(proxyStorageAddress)`
  * Deploy `BallotsStorage(poaNetworkConsensusAddress`
  * Deploy `ValidatorMetadata(poaNetworkConsensusAddress`
  * Deploy `VotingToChangeKeys(poaNetworkConsensusAddress)`
  * Deploy `VotingToChangeMinThreshold(poaNetworkConsensusAddress)`
  * Deploy `VotingToChangeProxyAddress(poaNetworkConsensusAddress)`
  * Deploy `KeysManager(proxyStorageAddress, poaNetworkConsensusAddress, mocWallet)`
  * `proxyStorage.initializeAddresses(kmAddress, vtckAddress, vtcmtAddress, vtcpaAddress, bsAddress)`

<br />

<hr />

## Code Review

### contracts/interfaces

* [x] [code-review/interfaces/IBallotsStorage.md](code-review/interfaces/IBallotsStorage.md)
  * [x] interface IBallotsStorage
* [x] [code-review/interfaces/IKeysManager.md](code-review/interfaces/IKeysManager.md)
  * [x] contract IKeysManager
* [x] [code-review/interfaces/IPoaNetworkConsensus.md](code-review/interfaces/IPoaNetworkConsensus.md)
  * [x] contract IPoaNetworkConsensus
* [ ] [code-review/interfaces/IProxyStorage.md](code-review/interfaces/IProxyStorage.md)
  * [ ] interface IProxyStorage

### contracts

* [x] [code-review/SafeMath.md](code-review/SafeMath.md)
  * [x] library SafeMath
* [ ] [code-review/BallotsStorage.md](code-review/BallotsStorage.md)
  * [ ] contract BallotsStorage is IBallotsStorage
* [ ] [code-review/KeysManager.md](code-review/KeysManager.md)
  * [ ] contract KeysManager is IKeysManager
* [ ] [code-review/PoaNetworkConsensus.md](code-review/PoaNetworkConsensus.md)
  * [ ] contract PoaNetworkConsensus is IPoaNetworkConsensus
* [ ] [code-review/ProxyStorage.md](code-review/ProxyStorage.md)
  * [ ] contract ProxyStorage is IProxyStorage
* [ ] [code-review/ValidatorMetadata.md](code-review/ValidatorMetadata.md)
  * [ ] contract ValidatorMetadata
* [ ] [code-review/VotingToChangeKeys.md](code-review/VotingToChangeKeys.md)
  * [ ] contract VotingToChangeKeys 
* [ ] [code-review/VotingToChangeMinThreshold.md](code-review/VotingToChangeMinThreshold.md)
  * [ ] contract VotingToChangeMinThreshold 
* [ ] [code-review/VotingToChangeProxyAddress.md](code-review/VotingToChangeProxyAddress.md)
  * [ ] contract VotingToChangeProxyAddress 

<br />

Not tested as this is a test component:

* [ ] [../contracts/Migrations.sol](../contracts/Migrations.sol)

<br />

## Example To Demonstrate The Shadowing Of Variables

Load the following code in [remix.ethereum.org](http://remix.ethereum.org), deploy *Derived*, click `increment()` then
click `decrement()`. Click on the getter functions `baseTotalSupply()` and `derivedTotalSupply()` to get the results
in the screen below:

```javascript
pragma solidity ^0.4.18;

contract Base {
    uint totalSupply;
    
    function decrement() public {
        totalSupply--;
    }
    
    function baseTotalSupply() public view returns (uint) {
        return totalSupply;
    }
}

contract Derived is Base {
    uint totalSupply;
    
    function increment() public {
        totalSupply++;
    }
    
    function derivedTotalSupply() public view returns (uint) {
        return totalSupply;
    }
}
```

![](ShadowExample.png)

<br />

A real-life example can be found by viewing the `totalSupply` for the *RareToken* at
[0x584AA8297eDfCB7d8853a426bb0f5252C4aF9437](https://etherscan.io/token/0x584AA8297eDfCB7d8853a426bb0f5252C4aF9437).

The contract code at this address does not have it's source attached, but you can see `totalSupply` is defined
in [token](https://github.com/bokkypoobah/RAREPeperiumToken/blob/master/contracts/RARE_original.sol#L27) and
`totalSupply` is also defined in
[RareToken](https://github.com/bokkypoobah/RAREPeperiumToken/blob/master/contracts/RARE_original.sol#L99).