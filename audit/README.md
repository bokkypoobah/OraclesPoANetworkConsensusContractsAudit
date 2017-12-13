# Oracles Network PoA Network Consensus Contracts Audit

Status: Work in progress (Aiming for < 15/12/2017)

## Summary

[Oracles Network](https://oracles.org/) completed it's presale in Dec 2017.

Bok Consulting Pty Ltd was commissioned to perform an audit on the Oracles Network's PoA Network Consensus Ethereum smart contract.

This audit has been conducted on Oracles Network's source code in commits
[f706e4f](https://github.com/oraclesorg/poa-network-consensus-contracts/commit/f706e4fa8d846b03c5f935e22696cc373d28afea),
[9625b09](https://github.com/oraclesorg/poa-network-consensus-contracts/commit/9625b09e3f8af8dd4e30fade6b3ca653f5781f49) and
[cec573c](https://github.com/oraclesorg/poa-network-consensus-contracts/commit/cec573cf93480355510c299b5d1b0fd39b5578d3).

TODO: Check that no potential vulnerabilities have been identified in the presale contract.

<br />

<hr />

## Table Of Contents

* [Summary](#summary)
* [Testing](#testing)
* [Code Review](#code-review)

<br />

<hr />

## Testing

<br />

<hr />

## Code Review

* [x] [code-review/SafeMath.md](code-review/SafeMath.md)
  * [x] library SafeMath
* [ ] [code-review/interfaces/IBallotsStorage.md](code-review/interfaces/IBallotsStorage.md)
  * [ ] interface IBallotsStorage
* [ ] [code-review/interfaces/IKeysManager.md](code-review/interfaces/IKeysManager.md)
  * [ ] contract IKeysManager
* [ ] [code-review/interfaces/IPoaNetworkConsensus.md](code-review/interfaces/IPoaNetworkConsensus.md)
  * [ ] contract IPoaNetworkConsensus
* [ ] [code-review/interfaces/IProxyStorage.md](code-review/interfaces/IProxyStorage.md)
  * [ ] interface IProxyStorage
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
