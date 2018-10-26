pragma solidity ^0.4.25;

import "../AttributeRegistryInterface.sol";


/**
 * @title A simple example of an Attribute Registry implementation.
 */
contract AttributeRegistry is AttributeRegistryInterface {
  // This particular implementation just defines two attribute types.
  enum Affiliation { Whitehat, Blackhat }

  // Top-level information about attribute types held in a static array.
  uint256[2] private _attributeTypeIDs;

  // The number of attributes currently issued tracked in a static array.
  uint256[2] private _issuedAttributeCounters; 

  // Issued attributes held in a nested mapping by account & attribute type.
  mapping(address => mapping(uint256 => bool)) private _issuedAttributes;

  // Issued attribute values held in a nested mapping by account & type.
  mapping(address => mapping(uint256 => uint256)) private _issuedAttributeValues;

  /**
  * @notice The constructor function, defines the two attribute types avaiable
  * on this particular registry.
  */
  constructor() public {
    // Set the attribute type IDs for whitehats (8008) and blackhats (1337).
    _attributeTypeIDs = [8008, 1337];
  }

  /**
   * @notice Assign a "whitehat" attribute type to `msg.sender`.
   * @dev The function may not be called by accounts with a "blackhat" attribute
   * type already assigned. This function is arbitrary and not part of the
   * Attribute Registry specification.
   */
  function joinWhitehats() external {
    // Get the index of the blackhat attribute type on the attribute registry.
    uint256 blackhatIndex = uint256(Affiliation.Blackhat);

    // Get the attribute type ID of the blackhat attribute type.
    uint256 blackhatAttributeTypeID = _attributeTypeIDs[blackhatIndex];
    
    // Do not allow the whitehat attribute to be set if blackhat is already set.
    require(
      !_issuedAttributes[msg.sender][blackhatAttributeTypeID],
      "no blackhats allowed!"
    );

    // Get the index of the whitehat attribute type on the attribute registry.
    uint256 whitehatIndex = uint256(Affiliation.Whitehat);
    
    // Get the attribute type ID of the whitehat attribute type.
    uint256 whitehatAttributeTypeID = _attributeTypeIDs[whitehatIndex];

    // Mark the attribute as issued on the given address.
    _issuedAttributes[msg.sender][whitehatAttributeTypeID] = true;

    // Calculate the new number of total whitehat attributes.
    uint256 incrementCounter = _issuedAttributeCounters[whitehatIndex] + 1;
    
    // Set the attribute value to the new total assigned whitehat attributes.
    _issuedAttributeValues[msg.sender][whitehatAttributeTypeID] = incrementCounter;
    
    // Update the value of the counter for total whitehat attributes.
    _issuedAttributeCounters[whitehatIndex] = incrementCounter;
  }

  /**
   * @notice Assign a "blackhat" attribute type to `msg.sender`.
   * @dev The function may be called by any account, but assigned "whitehat"
   * attributes will be removed. This function is arbitrary and not part of the
   * Attribute Registry specification.
   */
  function joinBlackhats() external {
    // Get the index of the blackhat attribute type on the attribute registry. 
    uint256 blackhatIndex = uint256(Affiliation.Blackhat);

    // Get the attribute type ID of the blackhat attribute type.
    uint256 blackhatAttributeTypeID = _attributeTypeIDs[blackhatIndex];

    // Mark the attribute as issued on the given address.    
    _issuedAttributes[msg.sender][blackhatAttributeTypeID] = true;

    // Calculate the new number of total blackhat attributes.    
    uint256 incrementCounter = _issuedAttributeCounters[blackhatIndex] + 1;

    // Set the attribute value to the new total assigned blackhat attributes.    
    _issuedAttributeValues[msg.sender][blackhatAttributeTypeID] = incrementCounter;

    // Update the value of the counter for total blackhat attributes.    
    _issuedAttributeCounters[blackhatIndex] = incrementCounter;

    // Get the index of the whitehat attribute type on the attribute registry.
    uint256 whitehatIndex = uint256(Affiliation.Whitehat);

    // Get the attribute type ID of the whitehat attribute type.
    uint256 whitehatAttributeTypeID = _attributeTypeIDs[whitehatIndex];

    // Determine if a whitehat attribute type has been assigned.
    if (_issuedAttributes[msg.sender][whitehatAttributeTypeID]) {
      // If so, delete the attribute.
      delete _issuedAttributes[msg.sender][whitehatAttributeTypeID];
      
      // Delete the attribute value as well.
      delete _issuedAttributeValues[msg.sender][whitehatAttributeTypeID];
      
      // Set the attribute value to the new total assigned whitehat attributes.      
      uint256 decrementCounter = _issuedAttributeCounters[whitehatIndex] - 1;
      
      // Update the value of the counter for total whitehat attributes.
      _issuedAttributeCounters[whitehatIndex] = decrementCounter;
    }
  }

  /**
   * @notice Get the total number of assigned whitehat and blackhat attributes.
   * @return Array with counts of assigned whitehat and blackhat attributes.
   * @dev This function is arbitrary and not part of the Attribute Registry
   * specification.
   */
  function totalHats() external view returns (uint256[2]) {
    // Return the array containing counter values.
    return _issuedAttributeCounters;
  }

  /**
   * @notice Check if an attribute of the type with ID `attributeTypeID` has
   * been assigned to the account at `account` and is currently valid.
   * @param account address The account to check for a valid attribute.
   * @param attributeTypeID uint256 The ID of the attribute type to check for.
   * @return True if the attribute is assigned and valid, false otherwise.
   * @dev This function MUST return either true or false - i.e. calling this
   * function MUST NOT cause the caller to revert.
   */
  function hasAttribute(
    address account, 
    uint256 attributeTypeID
  ) external view returns (bool) {
    // Return assignment status of attribute by account and attribute type ID
    return _issuedAttributes[account][attributeTypeID];
  }

  /**
   * @notice Retrieve the value of the attribute of the type with ID
   * `attributeTypeID` on the account at `account`, assuming it is valid.
   * @param account address The account to check for the given attribute value.
   * @param attributeTypeID uint256 The ID of the attribute type to check for.
   * @return The attribute value if the attribute is valid, reverts otherwise.
   * @dev This function MUST revert if a directly preceding or subsequent
   * function call to `hasAttribute` with identical `account` and
   * `attributeTypeID` parameters would return false.
   */
  function getAttributeValue(
    address account,
    uint256 attributeTypeID
  ) external view returns (uint256 value) {
    // Revert if attribute with given account & attribute type ID is unassigned
    require(
      _issuedAttributes[account][attributeTypeID],
      "could not find a value with the provided account and attribute type ID"
    );

    return _issuedAttributeValues[account][attributeTypeID];
  }

  /**
   * @notice Count the number of attribute types defined by the registry.
   * @return The number of available attribute types.
   * @dev This function MUST return a positive integer value  - i.e. calling
   * this function MUST NOT cause the caller to revert.
   */
  function countAttributeTypes() external view returns (uint256) {
    return _attributeTypeIDs.length;
  }

  /**
   * @notice Get the ID of the attribute type at index `index`.
   * @param index uint256 The index of the attribute type in question.
   * @return The ID of the attribute type.
   * @dev This function MUST revert if the provided `index` value falls outside
   * of the range of the value returned from a directly preceding or subsequent
   * function call to `countAttributeTypes`. It MUST NOT revert if the provided
   * `index` value falls inside said range.
   */
  function getAttributeTypeID(uint256 index) external view returns (uint256) {
    require(
      index < _attributeTypeIDs.length,
      "provided index is outside of the range of defined attribute type IDs"
    );

    return _attributeTypeIDs[index];
  }
}