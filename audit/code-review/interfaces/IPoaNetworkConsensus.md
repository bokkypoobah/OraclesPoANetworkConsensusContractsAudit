# IPoaNetworkConsensus

Source file [../../../contracts/interfaces/IPoaNetworkConsensus.sol](../../../contracts/interfaces/IPoaNetworkConsensus.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;


// BK Ok
interface IPoaNetworkConsensus {
    // BK Ok - Same as implementation
    function getValidators() public view returns(address[]);
    // BK Ok - Same as implementation
    function getPendingList() public view returns(address[]);
    // BK Ok - Same as implementation
    function finalizeChange() public;
    // BK Ok - Same as implementation
    function addValidator(address) public;
    // BK Ok - Same as implementation
    function removeValidator(address) public;
    // BK Ok - Same as implementation
    function isValidator(address) public view returns(bool);
    // BK Ok - Same as implementation
    function getCurrentValidatorsLength() public view returns(uint256);
}
```
