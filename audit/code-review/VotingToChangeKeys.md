# VotingToChangeKeys

Source file [../../contracts/VotingToChangeKeys.sol](../../contracts/VotingToChangeKeys.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;
// BK Ok
import "./SafeMath.sol";
import "./interfaces/IProxyStorage.sol";
import "./interfaces/IBallotsStorage.sol";
import "./interfaces/IKeysManager.sol";


// BK Ok
contract VotingToChangeKeys { 
    // BK Ok
    using SafeMath for uint256;
    // BK Ok
    enum BallotTypes {Invalid, Adding, Removal, Swap}
    // BK Ok
    enum KeyTypes {Invalid, MiningKey, VotingKey, PayoutKey}
    // BK Ok
    enum QuorumStates {Invalid, InProgress, Accepted, Rejected}
    // BK Ok
    enum ActionChoice { Invalid, Accept, Reject }
    
    // BK Ok
    IProxyStorage public proxyStorage;
    // BK Ok
    uint8 public maxOldMiningKeysDeepCheck = 25;
    // BK Ok
    uint256 public nextBallotId;
    // BK Ok
    uint256[] public activeBallots;
    // BK Ok
    uint256 public activeBallotsLength;
    // BK Ok
    uint8 thresholdForKeysType = 1;

    // BK Next block Ok
    struct VotingData {
        uint256 startTime;
        uint256 endTime;
        address affectedKey;
        uint256 affectedKeyType;
        address miningKey;
        uint256 totalVoters;
        int progress;
        bool isFinalized;
        uint8 quorumState;
        uint256 ballotType;
        uint256 index;
        uint256 minThresholdOfVoters;
        mapping(address => bool) voters;
        address creator;
    }

    // BK Ok
    mapping(uint256 => VotingData) public votingState;
    // BK Ok
    mapping(address => uint256) public validatorActiveBallots;

    // BK Next 3 Ok - Events
    event Vote(uint256 indexed id, uint256 decision, address indexed voter, uint256 time );
    event BallotFinalized(uint256 indexed id, address indexed voter);
    event BallotCreated(uint256 indexed id, uint256 indexed ballotType, address indexed creator);

    // BK Ok
    modifier onlyValidVotingKey(address _votingKey) {
        // BK Ok
        IKeysManager keysManager = IKeysManager(getKeysManager());
        // BK Ok
        require(keysManager.isVotingActive(_votingKey));
        // BK Ok
        _;
    }

    // BK Ok - Constructor
    function VotingToChangeKeys(address _proxyStorage) public {
        // BK Ok
        proxyStorage = IProxyStorage(_proxyStorage);
    }

    // BK Ok - Only valid voting keys can execute
    function createVotingForKeys(
        uint256 _startTime,
        uint256 _endTime,
        address _affectedKey, 
        uint256 _affectedKeyType, 
        address _miningKey,
        uint256 _ballotType
    ) public onlyValidVotingKey(msg.sender) {
        // BK Ok
        require(_startTime > 0 && _endTime > 0);
        // BK Ok
        require(_endTime > _startTime && _startTime > getTime());
        //only if ballotType is swap or remove
        require(areBallotParamsValid(_ballotType, _affectedKey, _affectedKeyType, _miningKey));
        // BK Ok
        address creatorMiningKey = getMiningByVotingKey(msg.sender);
        // BK Ok
        require(withinLimit(creatorMiningKey));
        // BK Next block Ok
        VotingData memory data = VotingData({
            startTime: _startTime,
            endTime: _endTime,
            affectedKey: _affectedKey,
            affectedKeyType: _affectedKeyType,
            miningKey: _miningKey,
            totalVoters: 0,
            progress: 0,
            isFinalized: false,
            quorumState: uint8(QuorumStates.InProgress),
            ballotType: _ballotType,
            index: activeBallots.length,
            minThresholdOfVoters: getGlobalMinThresholdOfVoters(),
            creator: creatorMiningKey
        });
        // BK Ok
        votingState[nextBallotId] = data;
        // BK Ok
        activeBallots.push(nextBallotId);
        // BK Ok
        activeBallotsLength = activeBallots.length;
        // BK Ok
        _increaseValidatorLimit();
        // BK Ok - Log event
        BallotCreated(nextBallotId, _ballotType, msg.sender);
        // BK Ok
        nextBallotId++;
    }

    // BK Ok - Can only be executed by a valid voting key
    function vote(uint256 _id, uint8 _choice) public onlyValidVotingKey(msg.sender) {
        
        // BK Ok
        VotingData storage ballot = votingState[_id];
        // // check for validation;
        // BK Ok
        address miningKey = getMiningByVotingKey(msg.sender);
        // BK Ok
        require(isValidVote(_id, msg.sender));
        // BK Ok
        if (_choice == uint(ActionChoice.Accept)) {
            // BK Ok
            ballot.progress++;
        // BK Ok
        } else if (_choice == uint(ActionChoice.Reject)) {
            // BK Ok
            ballot.progress--;
        // BK Ok
        } else {
            // BK Ok
            revert();
        }
        // BK Ok
        ballot.totalVoters++;
        // BK Ok
        ballot.voters[miningKey] = true;
        // BK Ok - Log event
        Vote(_id, _choice, msg.sender, getTime());
    }
    // BK Ok - Can only be executed by a valid voting key
    function finalize(uint256 _id) public onlyValidVotingKey(msg.sender) {
        // BK Ok
        require(!isActive(_id));
        // BK Ok
        require(!getIsFinalized(_id));
        // BK Ok
        VotingData storage ballot = votingState[_id];
        // BK Ok
        finalizeBallot(_id);
        // BK Ok
        _decreaseValidatorLimit(_id);
        // BK Ok
        ballot.isFinalized = true;
        // BK Ok - Log event
        BallotFinalized(_id, msg.sender);
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

    // BK Ok - View function
    function getBallotLimitPerValidator() public view returns(uint256) {
        // BK Ok
        IBallotsStorage ballotsStorage = IBallotsStorage(getBallotsStorage());
        // BK Ok - This is 200/numberOfValidators
        return ballotsStorage.getBallotLimitPerValidator();
    }

    // BK Ok - View function
    function getGlobalMinThresholdOfVoters() public view returns(uint256) {
        // BK Ok
        IBallotsStorage ballotsStorage = IBallotsStorage(getBallotsStorage());
        // BK Ok
        return ballotsStorage.getBallotThreshold(thresholdForKeysType);
    }

    // BK Ok - View function
    function getProgress(uint256 _id) public view returns(int) {
        // BK Ok
        return votingState[_id].progress;
    }

    // BK Ok - View function
    function getTotalVoters(uint256 _id) public view returns(uint256) {
        // BK Ok
        return votingState[_id].totalVoters;
    }

    // BK Ok - View function
    function getMinThresholdOfVoters(uint256 _id) public view returns(uint256) {
        // BK Ok
        return votingState[_id].minThresholdOfVoters;
    }

    // BK Ok - View function
    function getAffectedKeyType(uint256 _id) public view returns(uint256) {
        // BK Ok
        return votingState[_id].affectedKeyType;
    }

    // BK Ok - View function
    function getAffectedKey(uint256 _id) public view returns(address) {
        // BK Ok
        return votingState[_id].affectedKey;
    }

    // BK Ok - View function
    function getMiningKey(uint256 _id) public view returns(address) {
        // BK Ok
        return votingState[_id].miningKey;
    }

    // BK Ok - View function
    function getMiningByVotingKey(address _votingKey) public view returns(address) {
        // BK Ok
        IKeysManager keysManager = IKeysManager(getKeysManager());
        // BK Ok
        return keysManager.getMiningKeyByVoting(_votingKey);
    }

    // BK Ok - View function
    function getBallotType(uint256 _id) public view returns(uint256) {
        // BK Ok
        return votingState[_id].ballotType;
    }

    // BK Ok - View function
    function getStartTime(uint256 _id) public view returns(uint256) {
        // BK Ok
        return votingState[_id].startTime;
    }

    // BK Ok - View function
    function getEndTime(uint256 _id) public view returns(uint256) {
        // BK Ok
        return votingState[_id].endTime;
    }

    // BK Ok - View function
    function getIsFinalized(uint256 _id) public view returns(bool) {
        // BK Ok
        return votingState[_id].isFinalized;
    }

    // BK Ok - View function
    function getTime() public view returns(uint256) {
        // BK Ok
        return now;
    }

    // BK Ok - View function
    function isActive(uint256 _id) public view returns(bool) {
        // BK Ok
        bool withinTime = getStartTime(_id) <= getTime() && getTime() <= getEndTime(_id);
        // BK Ok
        return withinTime;
    }

    // BK Ok - View function
    function hasAlreadyVoted(uint256 _id, address _votingKey) public view returns(bool) {
        // BK Ok
        VotingData storage ballot = votingState[_id];
        // BK Ok
        address miningKey = getMiningByVotingKey(_votingKey);
        // BK Ok
        return ballot.voters[miningKey];
    }

    // BK Ok - View function
    function isValidVote(uint256 _id, address _votingKey) public view returns(bool) {
        // BK Ok
        address miningKey = getMiningByVotingKey(_votingKey);
        // BK Ok
        bool notVoted = !hasAlreadyVoted(_id, _votingKey);
        // BK Ok
        bool oldKeysNotVoted = !areOldMiningKeysVoted(_id, miningKey);
        // BK Ok
        return notVoted && isActive(_id) && oldKeysNotVoted;
    }

    // BK Ok - View function
    function areOldMiningKeysVoted(uint256 _id, address _miningKey) public view returns(bool) {
        // BK Ok
        IKeysManager keysManager = IKeysManager(getKeysManager());
        // BK Ok
        VotingData storage ballot = votingState[_id];
        // BK Ok
        for (uint8 i = 0; i < maxOldMiningKeysDeepCheck; i++) {
            // BK Ok
            address oldMiningKey = keysManager.getMiningKeyHistory(_miningKey);
            // BK Ok
            if (oldMiningKey == address(0)) {
                // BK Ok
                return false;
            }
            // BK Ok
            if (ballot.voters[oldMiningKey]) {
                // BK Ok
                return true;
            // BK Ok
            } else {
                // BK Ok
                _miningKey = oldMiningKey;
            }
        }
        // BK Ok
        return false;
    }

    // BK Ok - View function
    function checkIfMiningExisted(address _currentKey, address _affectedKey) public view returns(bool) {
        // BK Ok
        IKeysManager keysManager = IKeysManager(getKeysManager());
        // BK Ok
        for (uint8 i = 0; i < maxOldMiningKeysDeepCheck; i++) {
            // BK Ok
            address oldMiningKey = keysManager.getMiningKeyHistory(_currentKey);
            // BK Ok
            if (oldMiningKey == address(0)) {
                // BK Ok
                return false;
            }
            // BK Ok
            if (oldMiningKey == _affectedKey) {
                // BK Ok
                return true;
            // BK Ok
            } else {
                // BK Ok
                _currentKey = oldMiningKey;
            }
        }
        // BK Ok
        return false;
    }

    // BK Ok - View function
    function withinLimit(address _miningKey) public view returns(bool) {
        // BK Ok
        return validatorActiveBallots[_miningKey] <= getBallotLimitPerValidator();
    }

    // BK Ok - View function
    function areBallotParamsValid(
        uint256 _ballotType,
        address _affectedKey,
        uint256 _affectedKeyType,
        address _miningKey) public view returns(bool) 
    {
        // BK Ok
        if (_affectedKeyType == uint256(KeyTypes.MiningKey) && _ballotType != uint256(BallotTypes.Removal)) {
            require(!checkIfMiningExisted(_miningKey, _affectedKey));
        }
        // BK Ok
        require(_affectedKeyType > 0);
        // BK Ok
        require(_affectedKey != address(0));
        // BK Ok
        IKeysManager keysManager = IKeysManager(getKeysManager());
        // BK Ok
        bool isMiningActive = keysManager.isMiningActive(_miningKey);
        // BK Ok
        if (_affectedKeyType == uint256(KeyTypes.MiningKey)) {
            // BK Ok
            if (_ballotType == uint256(BallotTypes.Removal)) {
                // BK Ok
                return isMiningActive;
            }
            // BK Ok
            if (_ballotType == uint256(BallotTypes.Adding)) {
                // BK Ok
                return true;
            }
        }
        // BK Ok
        require(_affectedKey != _miningKey);
        // BK Ok
        if (_ballotType == uint256(BallotTypes.Removal) || _ballotType == uint256(BallotTypes.Swap)) {
            // BK Ok
            if (_affectedKeyType == uint256(KeyTypes.MiningKey)) {
                // BK Ok
                return isMiningActive;
            }
            // BK Ok
            if (_affectedKeyType == uint256(KeyTypes.VotingKey)) {
                // BK Ok
                address votingKey = keysManager.getVotingByMining(_miningKey);
                // BK Ok
                return keysManager.isVotingActive(votingKey) && _affectedKey == votingKey && isMiningActive;
            }
            // BK Ok
            if (_affectedKeyType == uint256(KeyTypes.PayoutKey)) {
                // BK Ok
                address payoutKey = keysManager.getPayoutByMining(_miningKey);
                // BK Ok
                return keysManager.isPayoutActive(_miningKey) && _affectedKey == payoutKey && isMiningActive;
            }       
        }
        // BK Ok
        return true;
    }

    // BK Ok
    function finalizeBallot(uint256 _id) private {
        // BK Ok
        if (getProgress(_id) > 0 && getTotalVoters(_id) >= getMinThresholdOfVoters(_id)) {
            // BK Ok
            updateBallot(_id, uint8(QuorumStates.Accepted));
            // BK Ok
            if (getBallotType(_id) == uint256(BallotTypes.Adding)) {
                // BK Ok
                finalizeAdding(_id);
            // BK Ok
            } else if (getBallotType(_id) == uint256(BallotTypes.Removal)) {
                // BK Ok
                finalizeRemoval(_id);
            // BK Ok
            } else if (getBallotType(_id) == uint256(BallotTypes.Swap)) {
                // BK Ok
                finalizeSwap(_id);
            }
        // BK Ok
        } else {
            // BK Ok
            updateBallot(_id, uint8(QuorumStates.Rejected));
        }
        // BK Ok
        deactiveBallot(_id);
    }

    // BK Ok - Private function only called by finalizeBallot
    function updateBallot(uint256 _id, uint8 _quorumState) private {
        // BK Ok
        VotingData storage ballot = votingState[_id];
        // BK Ok
        ballot.quorumState = _quorumState;
    }

    // BK Ok
    function deactiveBallot(uint256 _id) private {
        // BK Ok
        VotingData storage ballot = votingState[_id];
        // BK Ok
        uint256 removedIndex = ballot.index;
        // BK Ok
        uint256 lastIndex = activeBallots.length - 1;
        // BK Ok
        uint256 lastBallotId = activeBallots[lastIndex];
        // Override the removed ballot with the last one.
        // BK Ok
        activeBallots[removedIndex] = lastBallotId;
        // Update the index of the last validator.
        // BK Ok
        votingState[lastBallotId].index = removedIndex;
        // BK Ok
        delete activeBallots[lastIndex];
        // BK Ok
        if (activeBallots.length > 0) {
            // BK Ok
            activeBallots.length--;
        }
        // BK Ok
        activeBallotsLength = activeBallots.length;
    }

    // BK Ok
    function finalizeAdding(uint256 _id) private {
        // BK Ok
        require(getBallotType(_id) == uint256(BallotTypes.Adding));
        // BK Ok
        IKeysManager keysManager = IKeysManager(getKeysManager());
        // BK Ok
        if (getAffectedKeyType(_id) == uint256(KeyTypes.MiningKey)) {
            // BK Ok
            keysManager.addMiningKey(getAffectedKey(_id));
        }
        // BK Ok
        if (getAffectedKeyType(_id) == uint256(KeyTypes.VotingKey)) {
            // BK Ok
            keysManager.addVotingKey(getAffectedKey(_id), getMiningKey(_id));
        }
        // BK Ok
        if (getAffectedKeyType(_id) == uint256(KeyTypes.PayoutKey)) {
            // BK Ok
            keysManager.addPayoutKey(getAffectedKey(_id), getMiningKey(_id));
        }
    }

    // BK Ok
    function finalizeRemoval(uint256 _id) private {
        // BK Ok
        require(getBallotType(_id) == uint256(BallotTypes.Removal));
        // BK Ok
        IKeysManager keysManager = IKeysManager(getKeysManager());
        // BK Ok
        if (getAffectedKeyType(_id) == uint256(KeyTypes.MiningKey)) {
            // BK Ok
            keysManager.removeMiningKey(getAffectedKey(_id));
        }
        // BK Ok
        if (getAffectedKeyType(_id) == uint256(KeyTypes.VotingKey)) {
            // BK Ok
            keysManager.removeVotingKey(getMiningKey(_id));
        }
        // BK Ok
        if (getAffectedKeyType(_id) == uint256(KeyTypes.PayoutKey)) {
            // BK Ok
            keysManager.removePayoutKey(getMiningKey(_id));
        }
    }

    // BK Ok
    function finalizeSwap(uint256 _id) private {
        // BK Ok
        require(getBallotType(_id) == uint256(BallotTypes.Swap));
        // BK Ok
        IKeysManager keysManager = IKeysManager(getKeysManager());
        // BK Ok
        if (getAffectedKeyType(_id) == uint256(KeyTypes.MiningKey)) {
            // BK Ok
            keysManager.swapMiningKey(getAffectedKey(_id), getMiningKey(_id));
        }
        // BK Ok
        if (getAffectedKeyType(_id) == uint256(KeyTypes.VotingKey)) {
            // BK Ok
            keysManager.swapVotingKey(getAffectedKey(_id), getMiningKey(_id));
        }
        // BK Ok
        if (getAffectedKeyType(_id) == uint256(KeyTypes.PayoutKey)) {
            // BK Ok
            keysManager.swapPayoutKey(getAffectedKey(_id), getMiningKey(_id));
        }
    }

    // BK Ok
    function _increaseValidatorLimit() private {
        // BK Ok
        address miningKey = getMiningByVotingKey(msg.sender);
        // BK Ok
        validatorActiveBallots[miningKey] = validatorActiveBallots[miningKey].add(1);
    }

    // BK Ok
    function _decreaseValidatorLimit(uint256 _id) private {
        // BK Ok
        VotingData storage ballot = votingState[_id];
        // BK Ok
        address miningKey = ballot.creator;
        // BK Ok
        validatorActiveBallots[miningKey] = validatorActiveBallots[miningKey].sub(1);
    }
}
```
