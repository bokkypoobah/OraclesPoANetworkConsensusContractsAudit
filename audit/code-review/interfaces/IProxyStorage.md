# IProxyStorage

Source file [../../../contracts/interfaces/IProxyStorage.sol](../../../contracts/interfaces/IProxyStorage.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;


// BK Ok
interface IProxyStorage {
    // BK Ok - Same as implementation
    function getKeysManager() public view returns(address);
    // BK Ok - Same as implementation
    function getBallotsStorage() public view returns(address);
    // BK Ok - Same as implementation
    function getVotingToChangeKeys() public view returns(address);
    // BK Ok - Same as implementation
    function getVotingToChangeMinThreshold() public view returns(address);
    // BK Ok - Same as implementation
    function getPoaConsensus() public view returns(address);
    // BK Ok - Same as implementation
    function initializeAddresses(address, address, address, address, address) public;
    // BK Ok - Same as implementation
    function setContractAddress(uint256, address) public;
}
```
