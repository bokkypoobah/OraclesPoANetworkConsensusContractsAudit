# IKeysManager

Source file [../../../contracts/interfaces/IKeysManager.sol](../../../contracts/interfaces/IKeysManager.sol).

<br />

<hr />

```javascript
pragma solidity ^0.4.18;


interface IKeysManager {
    // BK Ok - Same as implementation
    function initiateKeys(address) public;
    // BK Ok - Same as implementation
    function createKeys(address, address, address) public;
    // BK NOTE - No getVotingToChangeKeys()
    // BK Ok - Same as implementation
    function isMiningActive(address) public view returns(bool);
    // BK Ok - Same as implementation
    function isVotingActive(address) public view returns(bool);
    // BK Ok - Same as implementation
    function isPayoutActive(address) public view returns(bool);
    // BK Ok - Same as implementation
    function getVotingByMining(address) public view returns(address);
    // BK Ok - Same as implementation
    function getPayoutByMining(address) public view returns(address);
    // BK Ok - Same as implementation
    function addMiningKey(address) public;
    // BK Ok - Same as implementation
    function addVotingKey(address, address) public;
    // BK Ok - Same as implementation
    function addPayoutKey(address, address) public;
    // BK Ok - Same as implementation
    function removeMiningKey(address) public;
    // BK Ok - Same as implementation
    function removeVotingKey(address) public;
    // BK Ok - Same as implementation
    function removePayoutKey(address) public;
    // BK Ok - Same as implementation
    function swapMiningKey(address, address) public;
    // BK Ok - Same as implementation
    function swapVotingKey(address, address) public;
    // BK Ok - Same as implementation
    function swapPayoutKey(address, address) public;
    // BK Ok - Same as implementation
    function getTime() public view returns(uint256);
    function getMiningKeyHistory(address) public view returns(address);
    function getMiningKeyByVoting(address) public view returns(address);
    function getInitialKey(address) public view returns(uint8);
}
```
