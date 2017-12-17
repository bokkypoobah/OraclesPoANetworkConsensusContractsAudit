# ValidatorMetadata

Source file [../../contracts/ValidatorMetadata.sol](../../contracts/ValidatorMetadata.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;
// BK Ok
import "./SafeMath.sol";
import "./interfaces/IBallotsStorage.sol";
import "./interfaces/IProxyStorage.sol";
import "./interfaces/IKeysManager.sol";


// BK Ok
contract ValidatorMetadata {
    // BK Ok
    using SafeMath for uint256;

    // BK Next block Ok
    struct Validator {
        bytes32 firstName;
        bytes32 lastName;
        bytes32 licenseId;
        string fullAddress;
        bytes32 state;
        uint256 zipcode;
        uint256 expirationDate;
        uint256 createdDate;
        uint256 updatedDate;
        uint256 minThreshold;
    }
    
    // BK Next block Ok
    struct Confirmation {

        uint256 count;
        address[] voters;
    }
    
    // BK Ok
    IProxyStorage public proxyStorage;
    // BK Next 5 Ok - Events
    event MetadataCreated(address indexed miningKey);
    event ChangeRequestInitiated(address indexed miningKey);
    event CancelledRequest(address indexed miningKey);
    event Confirmed(address indexed miningKey, address votingSender);
    event FinalizedChange(address indexed miningKey);
    // BK Next 3 Ok
    mapping(address => Validator) public validators;
    mapping(address => Validator) public pendingChanges;
    mapping(address => Confirmation) public confirmations;

    // BK Ok
    modifier onlyValidVotingKey(address _votingKey) {
        // BK Ok
        IKeysManager keysManager = IKeysManager(getKeysManager());
        // BK Ok
        require(keysManager.isVotingActive(_votingKey));
        // BK Ok
        _;
    }

    // BK Ok
    modifier onlyFirstTime(address _votingKey) {
        // BK Ok
        address miningKey = getMiningByVotingKey(msg.sender);
        // BK Ok
        Validator storage validator = validators[miningKey];
        // BK Ok
        require(validator.createdDate == 0);
        // BK Ok
        _;
    }

    // BK Ok - Constructor
    function ValidatorMetadata(address _proxyStorage) public {
        // BK Ok
        proxyStorage = IProxyStorage(_proxyStorage);
    }

    // BK Ok - Only valid voting key account can execute
    function createMetadata(
        bytes32 _firstName,
        bytes32 _lastName,
        bytes32 _licenseId,
        string _fullAddress,
        bytes32 _state,
        uint256 _zipcode,
        uint256 _expirationDate ) public onlyValidVotingKey(msg.sender) onlyFirstTime(msg.sender) {
        // BK Next block Ok
        Validator memory validator = Validator({
            firstName: _firstName,
            lastName: _lastName,
            licenseId: _licenseId,
            fullAddress: _fullAddress,
            zipcode: _zipcode,
            state: _state,
            expirationDate: _expirationDate,
            createdDate: getTime(),
            updatedDate: 0,
            minThreshold: getMinThreshold()
        });
        // BK Ok
        address miningKey = getMiningByVotingKey(msg.sender);
        // BK Ok
        validators[miningKey] = validator;
        // BK Ok - Log event
        MetadataCreated(miningKey);
    }

    // BK Ok - Only valid voting key account can execute
    function changeRequest(
        bytes32 _firstName,
        bytes32 _lastName,
        bytes32 _licenseId,
        string _fullAddress,
        bytes32 _state,
        uint256 _zipcode,
        uint256 _expirationDate
        ) public onlyValidVotingKey(msg.sender) returns(bool) {
        // BK Ok
        address miningKey = getMiningByVotingKey(msg.sender);
        // BK Ok
        Validator memory pendingChange = Validator({
            firstName: _firstName,
            lastName: _lastName,
            licenseId: _licenseId,
            fullAddress:_fullAddress,
            state: _state,
            zipcode: _zipcode,
            expirationDate: _expirationDate,
            createdDate: validators[miningKey].createdDate,
            updatedDate: getTime(),
            minThreshold: validators[miningKey].minThreshold
        });
        // BK Ok
        pendingChanges[miningKey] = pendingChange;
        // BK Ok
        delete confirmations[miningKey];
        // BK Ok - Log event
        ChangeRequestInitiated(miningKey);
        // BK Ok
        return true;
    }

    // BK Ok - Only valid voting key can execute
    function cancelPendingChange() public onlyValidVotingKey(msg.sender) returns(bool) {
        // BK Ok
        address miningKey = getMiningByVotingKey(msg.sender);
        // BK Ok
        delete pendingChanges[miningKey];
        // BK Ok - Log event
        CancelledRequest(miningKey);
        // BK Ok
        return true;
    }

    // BK Ok - View function
    function isAddressAlreadyVoted(address _miningKey, address _voter) public view returns(bool) {
        // BK Ok
        Confirmation storage confirmation = confirmations[_miningKey];
        // BK Ok
        for(uint256 i = 0; i < confirmation.voters.length; i++){
            // BK Ok
            if(confirmation.voters[i] == _voter){
                // BK Ok
                return true;   
            }
        }
        // BK Ok
        return false;
    }

    // BK Ok - Only valid voting key can execute
    function confirmPendingChange(address _miningKey) public onlyValidVotingKey(msg.sender) {
        // BK Ok
        Confirmation storage confirmation = confirmations[_miningKey];
        // BK Ok
        require(!isAddressAlreadyVoted(_miningKey, msg.sender));
        // BK Ok
        require(confirmation.voters.length <= 50); // no need for more confirmations
        // BK Ok
        address miningKey = getMiningByVotingKey(msg.sender);
        // BK Ok
        require(miningKey != _miningKey);
        // BK Ok
        confirmation.voters.push(msg.sender);
        // BK Ok
        confirmation.count = confirmation.count.add(1);
        // BK Ok - Log event
        Confirmed(_miningKey, msg.sender);
    }

    // BK Ok - Only valid voting key can execute
    function finalize(address _miningKey) public onlyValidVotingKey(msg.sender) {
        // BK Ok
        require(confirmations[_miningKey].count >= pendingChanges[_miningKey].minThreshold);
        // BK Ok
        validators[_miningKey] = pendingChanges[_miningKey];
        // BK Ok
        delete pendingChanges[_miningKey];
        // BK Ok - Log event
        FinalizedChange(_miningKey);
    }

    // BK Ok - View function
    function getMiningByVotingKey(address _votingKey) public view returns(address) {
        // BK Ok
        IKeysManager keysManager = IKeysManager(getKeysManager());
        // BK Ok
        return keysManager.getMiningKeyByVoting(_votingKey);
    }

    // BK Ok - View function
    function getTime() public view returns(uint256) {
        // BK Ok
        return now;
    }

    // BK Ok - View function
    function getMinThreshold() public view returns(uint256) {
        // BK Ok
        uint8 thresholdType = 2;
        // BK Ok
        IBallotsStorage ballotsStorage = IBallotsStorage(getBallotsStorage());
        // BK Ok
        return ballotsStorage.getBallotThreshold(thresholdType);
    }

    // BK Ok - View function
    function getBallotsStorage() public view returns(address) {
        // BK Ok
        return proxyStorage.getBallotsStorage();
    }

    // BK Ok - View function
    function getKeysManager() public view returns(address) {
        // BK Ok
        return proxyStorage.getKeysManager();
    }


}
```
