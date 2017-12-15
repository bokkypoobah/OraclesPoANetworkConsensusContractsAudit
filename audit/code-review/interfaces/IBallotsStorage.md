# IBallotsStorage

Source file [../../../contracts/interfaces/IBallotsStorage.sol](../../../contracts/interfaces/IBallotsStorage.sol).

<br />

<hr />

```javascript
pragma solidity ^0.4.18;


// BK Ok
interface IBallotsStorage {
    // BK Ok - Matches implementation
    function setThreshold(uint256, uint8) public;
    // BK Ok - Matches implementation
    function getBallotThreshold(uint8) public view returns(uint256);
    // BK Ok - Matches implementation
    function getVotingToChangeThreshold() public view returns(address);
    // BK Ok - Matches implementation
    function getTotalNumberOfValidators() public view returns(uint256);
    // BK Ok - Matches implementation
    function getProxyThreshold() public view returns(uint256);
    // BK Ok - Matches implementation
    function getBallotLimitPerValidator() public view returns(uint256);
    // BK Ok - Matches implementation
    function getMaxLimitBallot() public view returns(uint256);
}
```
