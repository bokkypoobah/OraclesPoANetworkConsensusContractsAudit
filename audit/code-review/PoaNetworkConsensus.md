# PoaNetworkConsensus

Source file [../../contracts/PoaNetworkConsensus.sol](../../contracts/PoaNetworkConsensus.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;

// BK Next 2 Ok
import "./interfaces/IPoaNetworkConsensus.sol";
import "./interfaces/IProxyStorage.sol";


contract PoaNetworkConsensus is IPoaNetworkConsensus {
    /// Issue this log event to signal a desired change in validator set.
    /// This will not lead to a change in active validator set until 
    /// finalizeChange is called.
    ///
    /// Only the last log event of any block can take effect.
    /// If a signal is issued while another is being finalized it may never
    /// take effect.
    /// 
    /// parentHash here should be the parent block hash, or the
    /// signal will not be recognized.
    // BK Next 4 Ok - Events
    event InitiateChange(bytes32 indexed parentHash, address[] newSet);
    event ChangeFinalized(address[] newSet);
    event ChangeReference(string nameOfContract, address newAddress);
    event MoCInitializedProxyStorage(address proxyStorage);
    
    struct ValidatorState {
        // Is this a validator.
        bool isValidator;
        // Index in the currentValidators.
        uint256 index;
    }

	// BK Ok
    bool public finalized = false;
    // BK Ok
    bool public isMasterOfCeremonyInitialized = false;
    // BK Ok
    address public masterOfCeremony;
    // BK Ok
    address public systemAddress = 0xfffffffffffffffffffffffffffffffffffffffe;
    // BK Ok
    address[] public currentValidators;
    // BK Ok
    address[] public pendingList;
    // BK Ok
    uint256 public currentValidatorsLength;
    // BK Ok
    mapping(address => ValidatorState) public validatorsState;
    // BK Ok
    IProxyStorage public proxyStorage;

    // BK Ok
    modifier onlySystemAndNotFinalized() {
        // BK Ok
        require(msg.sender == systemAddress && !finalized);
        // BK Ok
        _;
    }

    // BK Ok
    modifier onlyVotingContract() {
        // BK Ok
        require(msg.sender == getVotingToChangeKeys());
        // BK Ok
        _;
    }

    // BK Ok
    modifier onlyKeysManager() {
        // BK Ok
        require(msg.sender == getKeysManager());
        // BK Ok
        _;
    }
    
    // BK Ok
    modifier isNewValidator(address _someone) {
        // BK Ok
        require(!validatorsState[_someone].isValidator);
        // BK Ok
        _;
    }

    // BK Ok
    modifier isNotNewValidator(address _someone) {
        // BK Ok
        require(validatorsState[_someone].isValidator);
        // BK Ok
        _;
    }

    // BK Ok - Constructor
    function PoaNetworkConsensus(address _masterOfCeremony) public {
        // TODO: When you deploy this contract, make sure you hardcode items below
        // Make sure you have those addresses defined in spec.json
        // BK Ok
        require(_masterOfCeremony != address(0));
        // BK Ok
        masterOfCeremony = _masterOfCeremony;
        // BK Ok
        currentValidators = [masterOfCeremony];
        // BK Ok
        for (uint256 i = 0; i < currentValidators.length; i++) {
            // BK Ok
            validatorsState[currentValidators[i]] = ValidatorState({
                isValidator: true,
                index: i
            });
        }
        // BK Ok
        currentValidatorsLength = currentValidators.length;
        // BK Ok
        pendingList = currentValidators;
    }

    /// Get current validator set (last enacted or initial if no changes ever made)
    // BK Ok - View function
    function getValidators() public view returns(address[]) {
        // BK Ok
        return currentValidators;
    }

    // BK Ok - View function
    function getPendingList() public view returns(address[]) {
        // BK Ok
        return pendingList;
    }

    /// Called when an initiated change reaches finality and is activated. 
    /// Only valid when msg.sender == SUPER_USER (EIP96, 2**160 - 2)
    ///
    /// Also called when the contract is first enabled for consensus. In this case,
    /// the "change" finalized is the activation of the initial set.
    // BK Ok - Run once, by syste
    function finalizeChange() public onlySystemAndNotFinalized {
        // BK Ok
        finalized = true;
        // BK Ok
        currentValidators = pendingList;
        // BK Ok
        currentValidatorsLength = currentValidators.length;
        // BK Ok - Log event
        ChangeFinalized(getValidators());
    }

    // BK Ok - Only the keys manager can execute for new validator accounts
    function addValidator(address _validator) public onlyKeysManager isNewValidator(_validator) {
        // BK Ok
        require(_validator != address(0));
        // BK Next block Ok
        validatorsState[_validator] = ValidatorState({
            isValidator: true,
            index: pendingList.length
        });
        // BK Ok
        pendingList.push(_validator);
        // BK Ok
        finalized = false;
        // BK Ok - Log event
        InitiateChange(block.blockhash(block.number - 1), pendingList);
    }

    // BK Ok - Only the keys manager can execute for existing validator accounts
    function removeValidator(address _validator) public onlyKeysManager isNotNewValidator(_validator) {
        // BK Ok
        uint256 removedIndex = validatorsState[_validator].index;
        // Can not remove the last validator.
        // BK Ok
        uint256 lastIndex = pendingList.length - 1;
        // BK Ok
        address lastValidator = pendingList[lastIndex];
        // Override the removed validator with the last one.
        // BK Ok
        pendingList[removedIndex] = lastValidator;
        // Update the index of the last validator.
        // BK Ok
        validatorsState[lastValidator].index = removedIndex;
        // BK Ok
        delete pendingList[lastIndex];
        // BK Ok
        require(pendingList.length > 0);
        // BK Ok
        pendingList.length--;
        // BK Ok
        validatorsState[_validator].index = 0;
        // BK Ok
        validatorsState[_validator].isValidator = false;
        // BK Ok
        finalized = false;
        // BK Ok - Log event
        InitiateChange(block.blockhash(block.number - 1), pendingList);
    }

    // BK Ok - Only MoC can execute, once
    function setProxyStorage(address _newAddress) public {
        // Address of Master of Ceremony;
        require(msg.sender == masterOfCeremony);
        // BK Ok
        require(!isMasterOfCeremonyInitialized);
        // BK Ok
        require(_newAddress != address(0));
        // BK Ok
        proxyStorage = IProxyStorage(_newAddress);
        // BK Ok
        isMasterOfCeremonyInitialized = true;
        // BK Ok
        MoCInitializedProxyStorage(proxyStorage);
    }

    // BK Ok - View function
    function isValidator(address _someone) public view returns(bool) {
        // BK Ok
        return validatorsState[_someone].isValidator;
    }

    // BK Ok - View function
    function getKeysManager() public view returns(address) {
        // BK Ok
        return proxyStorage.getKeysManager();
    }

    // BK Ok - View function
    function getVotingToChangeKeys() public view returns(address) {
        // BK Ok
        return proxyStorage.getVotingToChangeKeys();
    }

    // BK Ok - View function
    function getCurrentValidatorsLength() public view returns(uint256) {
        // BK Ok
        return currentValidatorsLength;
    }

}
```
