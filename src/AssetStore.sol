// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {SSTORE2} from "solady/src/utils/SSTORE2.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";


//from: https://etherscan.io/address/0x10f974814693966ef68300ad64d35b038d301746#code

contract AssetStore is Ownable {
  mapping(address => bool) allowedWriters;
  mapping(bytes32 => address) public assetMapping;

  error NotAllowedWriter();

  function saveAsset(bytes calldata data) public returns (address) {
    if (allowedWriters[msg.sender] == false) revert NotAllowedWriter();
    address ptr = SSTORE2.write(data);
    assetMapping[keccak256(data)] = ptr;
    return ptr;
  }

  constructor() {
    allowedWriters[msg.sender] = true;
    _initializeOwner(msg.sender);
  }

  function addAllowedWriter(address _writer) external onlyOwner {
    allowedWriters[_writer] = true;
  }

  function removeAllowedWriter(address _writer) external onlyOwner {
    allowedWriters[_writer] = false;
  }

  function assetAddress(bytes32 contentHash) external view returns (address) {
    return assetMapping[contentHash];
  }

  function read(bytes32 contentHash) external view returns (bytes memory) {
    // SSTORE2 will error if hash doesn't exist / is the zero address
    return SSTORE2.read(assetMapping[contentHash]);
  }
}
