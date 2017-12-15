# ProxyStorage

Source file [../../contracts/ProxyStorage.sol](../../contracts/ProxyStorage.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;
// BK Ok
import "./interfaces/IProxyStorage.sol";


// BK Ok
contract ProxyStorage is IProxyStorage {
    // BK Next block Ok
    address public masterOfCeremony;
    address poaConsensus;
    address keysManager;
    address votingToChangeKeys;
    address votingToChangeMinThreshold;
    address votingToChangeProxy;
    address ballotsStorage;
    bool public mocInitialized;

    // BK Ok
    enum ContractTypes {
        Invalid,
        KeysManager,
        VotingToChangeKeys,
        VotingToChangeMinThreshold,
        VotingToChangeProxy,
        BallotsStorage 
    }

    // BK Ok - Event, matches usage below
    event ProxyInitialized(
        address keysManager,
        address votingToChangeKeys,
        address votingToChangeMinThreshold,
        address votingToChangeProxy,
        address ballotsStorage);

    // BK Ok - Event
    event AddressSet(uint256 contractType, address contractAddress);

    // BK Ok
    modifier onlyVotingToChangeProxy() {
        // BK Ok
        require(msg.sender == votingToChangeProxy);
        // BK Ok
        _;
    }

    // Constructor
    function ProxyStorage(address _poaConsensus, address _moc) public {
        // BK Ok
        poaConsensus = _poaConsensus;
        // BK Ok
        masterOfCeremony = _moc;
    }

    // BK Ok - View function
    function getKeysManager() public view returns(address) {
        // BK Ok
        return keysManager;
    }

    // BK Ok - View function
    function getVotingToChangeKeys() public view returns(address) {
        // BK Ok
        return votingToChangeKeys;
    }

    // BK NOTE - Called by BallotsStorage.getVotingToChangeThreshold()
    // BK Ok - View function
    function getVotingToChangeMinThreshold() public view returns(address) {
        // BK Ok
        return votingToChangeMinThreshold;
    }

    // BK Ok - View function
    function getVotingToChangeProxy() public view returns(address) {
        // BK Ok
        return votingToChangeProxy;
    }

    // BK NOTE - Called by BallotsStorage.getTotalNumberOfValidators()
    // BK Ok - View function
    function getPoaConsensus() public view returns(address) {
        // BK Ok
        return poaConsensus;
    }

    // BK Ok - View function
    function getBallotsStorage() public view returns(address) {
        // BK Ok
        return ballotsStorage;
    }

    // BK Ok - Only MoC can execute this function
    function initializeAddresses(
        address _keysManager,
        address _votingToChangeKeys,
        address _votingToChangeMinThreshold,
        address _votingToChangeProxy,
        address _ballotsStorage
    ) public 
    {
        // BK Ok
        require(msg.sender == masterOfCeremony);
        // BK Ok - This function can only be executed once
        require(!mocInitialized);
        // BK Next 5 Ok
        keysManager = _keysManager;
        votingToChangeKeys = _votingToChangeKeys;
        votingToChangeMinThreshold = _votingToChangeMinThreshold;
        votingToChangeProxy = _votingToChangeProxy;
        ballotsStorage = _ballotsStorage;
        // BK Ok
        mocInitialized = true;
        // BK Ok - Log event
        ProxyInitialized(
            keysManager,
            votingToChangeKeys,
            votingToChangeMinThreshold,
            votingToChangeProxy,
            ballotsStorage);
    }

    // BK Ok - Can only be called by VotingToChangeProxyAddress
    function setContractAddress(uint256 _contractType, address _contractAddress) public onlyVotingToChangeProxy {
        // BK Ok
        require(_contractAddress != address(0));
        // BK Ok
        if (_contractType == uint8(ContractTypes.KeysManager)) {
            // BK Ok
            keysManager = _contractAddress;
        // BK Ok
        } else if (_contractType == uint8(ContractTypes.VotingToChangeKeys)) {
            // BK Ok
            votingToChangeKeys = _contractAddress;
        // BK Ok
        } else if (_contractType == uint8(ContractTypes.VotingToChangeMinThreshold)) {
            // BK Ok
            votingToChangeMinThreshold = _contractAddress;
        // BK Ok
        } else if (_contractType == uint8(ContractTypes.VotingToChangeProxy)) {
            // BK Ok
            votingToChangeProxy = _contractAddress;
        // BK Ok
        } else if (_contractType == uint8(ContractTypes.BallotsStorage)) {
            // BK Ok
            ballotsStorage = _contractAddress;
        }
        // BK Ok - Log event
        AddressSet(_contractType, _contractAddress);
    }
}
```
