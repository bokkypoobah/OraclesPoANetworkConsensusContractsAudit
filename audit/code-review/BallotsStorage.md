# BallotsStorage

Source file [../../contracts/BallotsStorage.sol](../../contracts/BallotsStorage.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;
import "./interfaces/IBallotsStorage.sol";
import "./interfaces/IProxyStorage.sol";
import "./interfaces/IPoaNetworkConsensus.sol";
// BK Ok
import "./SafeMath.sol";


// BK Ok
contract BallotsStorage is IBallotsStorage {
    // BK Ok
    using SafeMath for uint256;

    // BK NOTE - 0=Invalid, 1=Keys, 2=MetadataChange
    // BK Ok
    enum ThresholdTypes {Invalid, Keys, MetadataChange}
    // BK Ok - Event
    event ThresholdChanged(uint8 indexed thresholdType, uint256 newValue);
    // BK Ok
    IProxyStorage public proxyStorage;
    mapping(uint8 => uint256) ballotThresholds;

    modifier onlyVotingToChangeThreshold() {
        require(msg.sender == getVotingToChangeThreshold());
        _;
    }

    // BK Ok - Constructor
    function BallotsStorage(address _proxyStorage) public {
        // BK Ok
        proxyStorage = IProxyStorage(_proxyStorage);
        ballotThresholds[uint8(ThresholdTypes.Keys)] = 3;
        ballotThresholds[uint8(ThresholdTypes.MetadataChange)] = 2;
    }

    // BK NOTE - Called by VotingToChangeMinTheshold.finalizeBallot()
    // BK Ok
    function setThreshold(uint256 _newValue, uint8 _thresholdType) public onlyVotingToChangeThreshold {
        // BK NOTE - 1=Keys..2=MetadataChange
        // BK Next 2 Ok
        require(_thresholdType > 0);
        require(_thresholdType <= uint8(ThresholdTypes.MetadataChange));
        // BK Ok - Check not the same as the existing value
        require(_newValue > 0 && _newValue != ballotThresholds[_thresholdType]);
        // BK Ok - Assignment
        ballotThresholds[_thresholdType] = _newValue;
        // BK Ok - Log event
        ThresholdChanged(_thresholdType, _newValue);
    }

    // BK Ok - View function
    function getBallotThreshold(uint8 _ballotType) public view returns(uint256) {
        // BK Ok
        return ballotThresholds[_ballotType];
    }

    // BK Ok - View function
    function getVotingToChangeThreshold() public view returns(address) {
        // BK Ok
        return proxyStorage.getVotingToChangeMinThreshold();
    }

    // BK Ok - View function
    function getTotalNumberOfValidators() public view returns(uint256) {
    	// BK Ok
        IPoaNetworkConsensus poa = IPoaNetworkConsensus(proxyStorage.getPoaConsensus());
        // BK Ok
        return poa.getCurrentValidatorsLength();
    }

    function getProxyThreshold() public view returns(uint256) {
        return getTotalNumberOfValidators().div(2).add(1);
    }

    function getBallotLimitPerValidator() public view returns(uint256) {
        return getMaxLimitBallot().div(getTotalNumberOfValidators());
    }
    
    function getMaxLimitBallot() public view returns(uint256) {
        return 200;
    }
}
```
