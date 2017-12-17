# Oracles Network PoA Network Consensus Contracts Audit

Status: Work in progress (Aiming for < 15/12/2017)

## Summary

[Oracles Network](https://oracles.org/) completed it's presale in Dec 2017.

Bok Consulting Pty Ltd was commissioned to perform an audit on the Oracles Network's PoA Network Consensus Ethereum smart contract.

This audit has been conducted on Oracles Network's source code in commits
[f706e4f](https://github.com/oraclesorg/poa-network-consensus-contracts/commit/f706e4fa8d846b03c5f935e22696cc373d28afea),
[9625b09](https://github.com/oraclesorg/poa-network-consensus-contracts/commit/9625b09e3f8af8dd4e30fade6b3ca653f5781f49),
[cec573c](https://github.com/oraclesorg/poa-network-consensus-contracts/commit/cec573cf93480355510c299b5d1b0fd39b5578d3),
[fd8f215](https://github.com/oraclesorg/poa-network-consensus-contracts/commit/fd8f2154b02c132e38ea07e95254f31f7511ca0a) and
[8aea8f5](https://github.com/oraclesorg/poa-network-consensus-contracts/commit/8aea8f53327924618241f933c10a1b12e20a7815).

TODO: Check that no potential vulnerabilities have been identified in the presale contract.

<br />

<hr />

## Table Of Contents

* [Summary](#summary)
* [Testing](#testing)
* [Code Review](#code-review)
* [Example To Demonstrate The Shadowing Of Variables](#example-to-demonstrate-the-shadowing-of-variables)
* [Code To Test The PoaNetworkConsensus PendingList Operations](#code-to-test-the-poanetworkconsensus-pendingList-operations)

<br />

<hr />

## Recommendations

* **MEDIUM IMPORTANCE** The following variables are duplicated in *IPoaNetworkConsensus* and *PoaNetworkConsensus*:
  `finalized`, `systemAddress`, `currentValidators`, `pendingList`, `currentValidatorsLength`. This can lead to strange
  results if functions in *IPoaNetworkConsensus* access it's version of these variables, which is not the case. See
  [Example To Demonstrate The Shadowing Of Variables](#example-to-demonstrate-the-shadowing-of-variables) for an
  example where a function in the base class access the base class variable. Only `currentValidatorsLength` is read
  from the `IPoaNetworkConsensus`, but is written to in *KeysManager* and *BallotsStorage*
  * [x] Fixed in [8aea8f5](https://github.com/oraclesorg/poa-network-consensus-contracts/commit/8aea8f53327924618241f933c10a1b12e20a7815)
* **LOW IMPORTANCE** There is an off-by-one error in *KeysManager* as the check to restrict the number of keys to `maxLimitValidators = 2000`
  is performed before the addition of a new key in `addMiningKey(...)`
  * [x] Developer acknowledged, and 2001 keys is acceptable

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
  * [x] interface IKeysManager
* [x] [code-review/interfaces/IPoaNetworkConsensus.md](code-review/interfaces/IPoaNetworkConsensus.md)
  * [x] interface IPoaNetworkConsensus
* [x] [code-review/interfaces/IProxyStorage.md](code-review/interfaces/IProxyStorage.md)
  * [x] interface IProxyStorage

### contracts

* [x] [code-review/SafeMath.md](code-review/SafeMath.md)
  * [x] library SafeMath
* [x] [code-review/BallotsStorage.md](code-review/BallotsStorage.md)
  * [x] contract BallotsStorage is IBallotsStorage
* [x] [code-review/KeysManager.md](code-review/KeysManager.md)
  * [x] contract KeysManager is IKeysManager
* [x] [code-review/PoaNetworkConsensus.md](code-review/PoaNetworkConsensus.md)
  * [x] contract PoaNetworkConsensus is IPoaNetworkConsensus
    * [x] Check `pendingList` and `validatorsState` insertion and deletion - See [Code To Test The PoaNetworkConsensus PendingList Operations](#code-to-test-the-poanetworkconsensus-pendingList-operations)
* [x] [code-review/ProxyStorage.md](code-review/ProxyStorage.md)
  * [x] contract ProxyStorage is IProxyStorage
* [x] [code-review/ValidatorMetadata.md](code-review/ValidatorMetadata.md)
  * [x] contract ValidatorMetadata
* [x] [code-review/VotingToChangeKeys.md](code-review/VotingToChangeKeys.md)
  * [x] contract VotingToChangeKeys 
* [x] [code-review/VotingToChangeMinThreshold.md](code-review/VotingToChangeMinThreshold.md)
  * [x] contract VotingToChangeMinThreshold 
* [x] [code-review/VotingToChangeProxyAddress.md](code-review/VotingToChangeProxyAddress.md)
  * [x] contract VotingToChangeProxyAddress 

<br />

Not tested as this is a test component:

* [ ] [../contracts/Migrations.sol](../contracts/Migrations.sol)

<br />

<hr />

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

<br />

<hr />

## Code To Test The PoaNetworkConsensus PendingList Operations

Load the following code in [remix.ethereum.org](http://remix.ethereum.org), deploy *Derived*. Click `addValidator* and
*removeValidator* and check using *getPendingList* at each step:

```javascript
pragma solidity ^0.4.18;

contract TestPoaNetworkConsensusPendingList {
    event InitiateChange(bytes32 indexed parentHash, address[] newSet);
    event ChangeFinalized(address[] newSet);
    event ChangeReference(string nameOfContract, address newAddress);
    event MoCInitializedProxyStorage(address proxyStorage);
    
    struct ValidatorState {
        // Is this a validator.
        bool isValidator;
        // Index in the pendingList.
        uint256 index;
    }

    address[] public pendingList;
    mapping(address => ValidatorState) public validatorsState;

    modifier isNewValidator(address _someone) {
        require(!validatorsState[_someone].isValidator);
        _;
    }

    modifier isNotNewValidator(address _someone) {
        require(validatorsState[_someone].isValidator);
        _;
    }

    function TestPoaNetworkConsensusPendingList() public {
        pendingList = [msg.sender];
        for (uint256 i = 0; i < pendingList.length; i++) {
            validatorsState[pendingList[i]] = ValidatorState({
                isValidator: true,
                index: i
            });
        }
    }

    function getPendingList() public view returns(address[]) {
        return pendingList;
    }

    function addValidator(address _validator) public isNewValidator(_validator) {
        require(_validator != address(0));
        validatorsState[_validator] = ValidatorState({
            isValidator: true,
            index: pendingList.length
        });
        pendingList.push(_validator);
        InitiateChange(block.blockhash(block.number - 1), pendingList);
    }

    function removeValidator(address _validator) public isNotNewValidator(_validator) {
        uint256 removedIndex = validatorsState[_validator].index;
        // Can not remove the last validator.
        uint256 lastIndex = pendingList.length - 1;
        address lastValidator = pendingList[lastIndex];
        // Override the removed validator with the last one.
        pendingList[removedIndex] = lastValidator;
        // Update the index of the last validator.
        validatorsState[lastValidator].index = removedIndex;
        delete pendingList[lastIndex];
        require(pendingList.length > 0);
        pendingList.length--;
        validatorsState[_validator].index = 0;
        validatorsState[_validator].isValidator = false;
        InitiateChange(block.blockhash(block.number - 1), pendingList);
    }

    function isValidator(address _someone) public view returns(bool) {
        return validatorsState[_someone].isValidator;
    }
}
```