# KeysManager

Source file [../../contracts/KeysManager.sol](../../contracts/KeysManager.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;

// BK Next 3 Ok
import "./interfaces/IPoaNetworkConsensus.sol";
import "./interfaces/IKeysManager.sol";
import "./interfaces/IProxyStorage.sol";


// BK Ok
contract KeysManager is IKeysManager {
    // BK Ok
    enum InitialKeyState { Invalid, Activated, Deactivated }

    // BK Next block Ok
    struct Keys {
        address votingKey;
        address payoutKey;
        bool isMiningActive;
        bool isVotingActive;
        bool isPayoutActive;
    }
    
    // BK Ok
    address public masterOfCeremony;
    // BK Ok
    IProxyStorage public proxyStorage;
    
    // BK Ok
    IPoaNetworkConsensus public poaNetworkConsensus;
    // BK Ok
    uint256 public maxNumberOfInitialKeys = 12;
    // BK Ok
    uint256 public initialKeysCount = 0;
    // BK Ok
    uint256 public maxLimitValidators = 2000;
    // BK Ok
    mapping(address => uint8) public initialKeys;
    // BK Ok
    mapping(address => Keys) public validatorKeys;
    // BK Ok
    mapping(address => address) public miningKeyByVoting;
    // BK Ok
    mapping(address => address) public miningKeyHistory;

    // BK Next 5 Ok - Events
    event PayoutKeyChanged(address key, address indexed miningKey, string action);
    event VotingKeyChanged(address key, address indexed miningKey, string action);
    event MiningKeyChanged(address key, string action);
    event ValidatorInitialized(address indexed miningKey, address indexed votingKey, address indexed payoutKey);
    event InitialKeyCreated(address indexed initialKey, uint256 time, uint256 initialKeysCount);

    // BK Ok
    modifier onlyVotingToChangeKeys() {
        // BK Ok
        require(msg.sender == getVotingToChangeKeys());
        // BK Ok
        _;
    }

    // BK Ok
    modifier onlyValidInitialKey() {
        // BK Ok
        require(initialKeys[msg.sender] == uint8(InitialKeyState.Activated));
        _;
    }

    // BK Ok
    modifier withinTotalLimit() {
        // BK Ok
        require(poaNetworkConsensus.getCurrentValidatorsLength() <= maxLimitValidators);
        // BK Ok
        _;
    }

    // BK Ok - Constructor
    function KeysManager(address _proxyStorage, address _poaConsensus, address _masterOfCeremony) public {
        // BK Ok
        require(_proxyStorage != address(0) && _poaConsensus != address(0));
        // BK Ok
        require(_proxyStorage != _poaConsensus);
        // BK Ok
        require(_masterOfCeremony != address(0) && _masterOfCeremony != _poaConsensus);
        // BK Ok
        masterOfCeremony = _masterOfCeremony;
        // BK Ok
        proxyStorage = IProxyStorage(_proxyStorage);
        // BK Ok
        poaNetworkConsensus = IPoaNetworkConsensus(_poaConsensus);
        // BK Next block Ok
        validatorKeys[masterOfCeremony] = Keys({
            votingKey: address(0),
            payoutKey: address(0),
            isMiningActive: true,
            isVotingActive: false,
            isPayoutActive: false
        });
    }

    // BK - Only MoC can execute this function
    function initiateKeys(address _initialKey) public {
        // BK Ok
        require(msg.sender == masterOfCeremony);
        // BK Ok
        require(_initialKey != address(0));
        // BK Ok
        require(initialKeys[_initialKey] == uint8(InitialKeyState.Invalid));
        // BK Ok
        require(_initialKey != masterOfCeremony);
        // BK Ok
        require(initialKeysCount < maxNumberOfInitialKeys);
        // BK Ok
        initialKeys[_initialKey] = uint8(InitialKeyState.Activated);
        // BK Ok
        initialKeysCount++;
        // BK Ok - Log event
        InitialKeyCreated(_initialKey, getTime(), initialKeysCount);
    }

    // BK Ok - Can only be called by account in initialKeys that have been activated by MoC in initiateKeys above
    function createKeys(address _miningKey, address _votingKey, address _payoutKey) public onlyValidInitialKey {
        // BK Ok
        require(_miningKey != address(0) && _votingKey != address(0) && _payoutKey != address(0));
        // BK Ok
        require(_miningKey != _votingKey && _miningKey != _payoutKey && _votingKey != _payoutKey);
        // BK Ok
        require(_miningKey != msg.sender && _votingKey != msg.sender && _payoutKey != msg.sender);
        // BK Next block Ok
        validatorKeys[_miningKey] = Keys({
            votingKey: _votingKey,
            payoutKey: _payoutKey,
            isMiningActive: true,
            isVotingActive: true,
            isPayoutActive: true
        });
        // BK Ok
        miningKeyByVoting[_votingKey] = _miningKey;
        // BK Ok
        initialKeys[msg.sender] = uint8(InitialKeyState.Deactivated);
        // BK Ok
        poaNetworkConsensus.addValidator(_miningKey);
        // BK Ok - Log event
        ValidatorInitialized(_miningKey, _votingKey, _payoutKey);
    }

    // BK Ok - View function
    function getTime() public view returns(uint256) {
        // BK Ok
        return now;
    }

    // BK Ok - View function
    function getVotingToChangeKeys() public view returns(address) {
        // BK Ok
        return proxyStorage.getVotingToChangeKeys();
    }

    // BK Ok - View function
    function isMiningActive(address _key) public view returns(bool) {
        // BK Ok
        return validatorKeys[_key].isMiningActive;
    }

    // BK Ok - View function
    function isVotingActive(address _votingKey) public view returns(bool) {
        // BK Ok
        address miningKey = miningKeyByVoting[_votingKey];
        // BK Ok
        return validatorKeys[miningKey].isVotingActive;
    }

    // BK Ok - View function
    function isPayoutActive(address _miningKey) public view returns(bool) {
        // BK Ok
        return validatorKeys[_miningKey].isPayoutActive;
    }

    // BK Ok - View function
    function getVotingByMining(address _miningKey) public view returns(address) {
        // BK Ok
        return validatorKeys[_miningKey].votingKey;
    }

    // BK Ok - View function
    function getPayoutByMining(address _miningKey) public view returns(address) {
        // BK Ok
        return validatorKeys[_miningKey].payoutKey;
    }

    // BK Ok - View function
    function getMiningKeyHistory(address _miningKey) public view returns(address) {
        // BK Ok
        return miningKeyHistory[_miningKey];
    }

    // BK Ok - View function
    function getMiningKeyByVoting(address _miningKey) public view returns(address) {
        // BK Ok
        return miningKeyByVoting[_miningKey];
    }

    // BK Ok - View function
    function getInitialKey(address _initialKey) public view returns(uint8) {
        // BK Ok
        return initialKeys[_initialKey];
    }

    // BK NOTE - There is an off-by-one error as the check against the limit is done before the addition of a new key
    // BK Ok - Only VotingToChangeKeys can execute
    function addMiningKey(address _key) public onlyVotingToChangeKeys withinTotalLimit {
        // BK Ok
        _addMiningKey(_key);
    }

    // BK Ok - Only VotingToChangeKeys can execute
    function addVotingKey(address _key, address _miningKey) public onlyVotingToChangeKeys {
        // BK Ok
        _addVotingKey(_key, _miningKey);
    }

    // BK Ok - Only VotingToChangeKeys can execute
    function addPayoutKey(address _key, address _miningKey) public onlyVotingToChangeKeys {
        // BK Ok
        _addPayoutKey(_key, _miningKey);
    }

    // BK Ok - Only VotingToChangeKeys can execute
    function removeMiningKey(address _key) public onlyVotingToChangeKeys {
        // BK Ok
        _removeMiningKey(_key);
    }

    // BK Ok - Only VotingToChangeKeys can execute
    function removeVotingKey(address _miningKey) public onlyVotingToChangeKeys {
        _removeVotingKey(_miningKey);
    }

    // BK Ok - Only VotingToChangeKeys can execute
    function removePayoutKey(address _miningKey) public onlyVotingToChangeKeys {
        // BK Ok
        _removePayoutKey(_miningKey);
    }

    // BK Ok - Only VotingToChangeKeys can execute
    function swapMiningKey(address _key, address _oldMiningKey) public onlyVotingToChangeKeys {
        // BK Ok
        miningKeyHistory[_key] = _oldMiningKey;
        // BK Ok
        _removeMiningKey(_oldMiningKey);
        // BK Ok
        _addMiningKey(_key);
    }

    // BK Ok - Only VotingToChangeKeys can execute
    function swapVotingKey(address _key, address _miningKey) public onlyVotingToChangeKeys {
    // BK Ok
        _swapVotingKey(_key, _miningKey);
    }

    // BK Ok - Only VotingToChangeKeys can execute
    function swapPayoutKey(address _key, address _miningKey) public onlyVotingToChangeKeys {
        // BK Ok
        _swapPayoutKey(_key, _miningKey);
    }

    // BK Ok
    function _swapVotingKey(address _key, address _miningKey) private {
        // BK Ok
        _removeVotingKey(_miningKey);
        // BK Ok
        _addVotingKey(_key, _miningKey);
    }

    // BK Ok
    function _swapPayoutKey(address _key, address _miningKey) private {
        // BK Ok
        _removePayoutKey(_miningKey);
        // BK Ok
        _addPayoutKey(_key, _miningKey);
    }

    // BK Ok
    function _addMiningKey(address _key) private {
        // BK Next block Ok
        validatorKeys[_key] = Keys({
            votingKey: address(0),
            payoutKey: address(0),
            isVotingActive: false,
            isPayoutActive: false,
            isMiningActive: true
        });
        // BK Ok
        poaNetworkConsensus.addValidator(_key);
        // BK Ok
        MiningKeyChanged(_key, "added");
    }

    // BK Ok
    function _addVotingKey(address _key, address _miningKey) private {
        // BK Ok
        Keys storage validator = validatorKeys[_miningKey];
        // BK Ok
        require(validator.isMiningActive && _key != _miningKey);
        // BK Ok
        if (validator.isVotingActive) {
            // BK Ok
            _swapVotingKey(_key, _miningKey);
        // BK Ok
        } else {
            // BK Ok
            validator.votingKey = _key;
            // BK Ok
            validator.isVotingActive = true;
            // BK Ok
            miningKeyByVoting[_key] = _miningKey;
            // BK Ok - Log event
            VotingKeyChanged(_key, _miningKey, "added");
        }
    }

    // BK Ok
    function _addPayoutKey(address _key, address _miningKey) private {
        // BK Ok
        Keys storage validator = validatorKeys[_miningKey];
        // BK Ok
        require(validator.isMiningActive && _key != _miningKey);
        // BK Ok
        if (validator.isPayoutActive && validator.payoutKey != address(0)) {
            // BK Ok
            _swapPayoutKey(_key, _miningKey);
        // BK Ok
        } else {
            // BK Ok
            validator.payoutKey = _key;
            // BK Ok
            validator.isPayoutActive = true;
            // BK Ok - Log event
            PayoutKeyChanged(_key, _miningKey, "added");
        }
    }

    // BK Ok
    function _removeMiningKey(address _key) private {
        // BK Ok
        require(validatorKeys[_key].isMiningActive);
        // BK Ok
        Keys memory keys = validatorKeys[_key];
        // BK Ok
        miningKeyByVoting[keys.votingKey] = address(0);
        // BK Next block Ok
        validatorKeys[_key] = Keys({
            votingKey: address(0),
            payoutKey: address(0),
            isVotingActive: false,
            isPayoutActive: false,
            isMiningActive: false
        });
        // BK Ok
        poaNetworkConsensus.removeValidator(_key);
        // BK Ok - Log event
        MiningKeyChanged(_key, "removed");
    }

    // BK Ok
    function _removeVotingKey(address _miningKey) private {
        // BK Ok
        Keys storage validator = validatorKeys[_miningKey];
        // BK Ok
        require(validator.isVotingActive);
        // BK Ok
        address oldVoting = validator.votingKey;
        // BK Ok
        validator.votingKey = address(0);
        // BK Ok
        validator.isVotingActive = false;
        // BK Ok
        miningKeyByVoting[oldVoting] = address(0);
        // BK Ok - Log event
        VotingKeyChanged(oldVoting, _miningKey, "removed");
    }

    // BK Ok
    function _removePayoutKey(address _miningKey) private {
        // BK Ok
        Keys storage validator = validatorKeys[_miningKey];
        // BK Ok
        require(validator.isPayoutActive);
        // BK Ok
        address oldPayout = validator.payoutKey;
        // BK Ok
        validator.payoutKey = address(0);
        // BK Ok
        validator.isPayoutActive = false;
        // BK Ok - Log event
        PayoutKeyChanged(oldPayout, _miningKey, "removed");
    }
}
```
