# VotingToChangeProxyAddress

Source file [../../contracts/VotingToChangeProxyAddress.sol](../../contracts/VotingToChangeProxyAddress.sol).

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
contract VotingToChangeProxyAddress {
    // BK Ok
    using SafeMath for uint256;
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

    // BK Next block Ok
    struct VotingData {
        uint256 startTime;
        uint256 endTime;
        uint256 totalVoters;
        int progress;
        bool isFinalized;
        uint8 quorumState;
        uint256 index;
        uint256 minThresholdOfVoters;
        address proposedValue;
        uint8 contractType;
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

    modifier onlyValidVotingKey(address _votingKey) {
        IKeysManager keysManager = IKeysManager(getKeysManager());
        require(keysManager.isVotingActive(_votingKey));
        _;
    }

    // BK Ok - Constructor
    function VotingToChangeProxyAddress(address _proxyStorage) public {
        // BK Ok
        proxyStorage = IProxyStorage(_proxyStorage);
    }

    // BK Ok - Only valid voting keys can execute
    function createBallotToChangeProxyAddress(
        uint256 _startTime,
        uint256 _endTime,
        address _proposedValue,
        uint8 _contractType
        ) public onlyValidVotingKey(msg.sender) {
        // BK Ok
        require(_startTime > 0 && _endTime > 0);
        // BK Ok
        require(_endTime > _startTime && _startTime > getTime());
        // BK Ok
        require(_proposedValue != address(0));
        // BK Ok
        address creatorMiningKey = getMiningByVotingKey(msg.sender);
        // BK Ok
        require(withinLimit(creatorMiningKey));
        // BK Next block Ok
        VotingData memory data = VotingData({
            startTime: _startTime,
            endTime: _endTime,
            totalVoters: 0,
            progress: 0,
            isFinalized: false,
            quorumState: uint8(QuorumStates.InProgress),
            index: activeBallots.length,
            proposedValue: _proposedValue,
            contractType: _contractType,
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
        // BK Ok
        BallotCreated(nextBallotId, 5, msg.sender);
        // BK Ok
        nextBallotId++;
    }

    // BK Ok - Can only be executed by a valid voting key
    function vote(uint256 _id, uint8 _choice) public onlyValidVotingKey(msg.sender) {
        // BK Ok
        VotingData storage ballot = votingState[_id];
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
    function getProposedValue(uint256 _id) public view returns(address) {
        // BK Ok
        return votingState[_id].proposedValue;
    }
    
    // BK Ok - View function
    function getContractType(uint256 _id) public view returns(uint256) {
        // BK Ok
        return votingState[_id].contractType;
    }

    // BK Ok - View function
    function getGlobalMinThresholdOfVoters() public view returns(uint256) {
        // BK Ok
        IBallotsStorage ballotsStorage = IBallotsStorage(getBallotsStorage());
        // BK Ok
        return ballotsStorage.getProxyThreshold();
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
    function getMiningByVotingKey(address _votingKey) public view returns(address) {
        // BK Ok
        IKeysManager keysManager = IKeysManager(getKeysManager());
        // BK Ok
        return keysManager.getMiningKeyByVoting(_votingKey);
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
        VotingData storage ballot = votingState[_id];
        // BK Ok
        IKeysManager keysManager = IKeysManager(getKeysManager());
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
    function getBallotLimitPerValidator() public view returns(uint256) {
        // BK Ok
        IBallotsStorage ballotsStorage = IBallotsStorage(getBallotsStorage());
        // BK Ok - This is 200/numberOfValidators
        return ballotsStorage.getBallotLimitPerValidator();
    }

    // BK Ok - View function
    function withinLimit(address _miningKey) public view returns(bool) {
        // BK Ok
        return validatorActiveBallots[_miningKey] <= getBallotLimitPerValidator();
    }


    // BK Ok
    function finalizeBallot(uint256 _id) private {
        // BK Ok
        if (getProgress(_id) > 0 && getTotalVoters(_id) >= getMinThresholdOfVoters(_id)) {
            // BK Ok
            updateBallot(_id, uint8(QuorumStates.Accepted));
            // BK Ok
            proxyStorage.setContractAddress(getContractType(_id), getProposedValue(_id));
        // BK Ok
        } else {
            // BK Ok
            updateBallot(_id, uint8(QuorumStates.Rejected));
        }
        // BK Ok
        deactiveBallot(_id);
    }

    // BK Ok
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
