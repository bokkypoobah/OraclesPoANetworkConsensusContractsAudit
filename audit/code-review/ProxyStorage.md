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

    event AddressSet(uint256 contractType, address contractAddress);

    modifier onlyVotingToChangeProxy() {
        require(msg.sender == votingToChangeProxy);
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

    function initializeAddresses(
        address _keysManager,
        address _votingToChangeKeys,
        address _votingToChangeMinThreshold,
        address _votingToChangeProxy,
        address _ballotsStorage
    ) public 
    {
        require(msg.sender == masterOfCeremony);
        require(!mocInitialized);
        keysManager = _keysManager;
        votingToChangeKeys = _votingToChangeKeys;
        votingToChangeMinThreshold = _votingToChangeMinThreshold;
        votingToChangeProxy = _votingToChangeProxy;
        ballotsStorage = _ballotsStorage;
        mocInitialized = true;
        // BK Ok
        ProxyInitialized(
            keysManager,
            votingToChangeKeys,
            votingToChangeMinThreshold,
            votingToChangeProxy,
            ballotsStorage);
    }

    function setContractAddress(uint256 _contractType, address _contractAddress) public onlyVotingToChangeProxy {
        require(_contractAddress != address(0));
        if (_contractType == uint8(ContractTypes.KeysManager)) {
            keysManager = _contractAddress;
        } else if (_contractType == uint8(ContractTypes.VotingToChangeKeys)) {
            votingToChangeKeys = _contractAddress;
        } else if (_contractType == uint8(ContractTypes.VotingToChangeMinThreshold)) {
            votingToChangeMinThreshold = _contractAddress;
        } else if (_contractType == uint8(ContractTypes.VotingToChangeProxy)) {
            votingToChangeProxy = _contractAddress;
        } else if (_contractType == uint8(ContractTypes.BallotsStorage)) {
            ballotsStorage = _contractAddress;
        }
        AddressSet(_contractType, _contractAddress);
    }
}
```
