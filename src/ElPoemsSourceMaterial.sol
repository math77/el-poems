//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.20;

import {Ownable} from "solady/src/auth/Ownable.sol";
import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

import {IElPoemsMetadataRenderer} from "./interfaces/IElPoemsMetadataRenderer.sol";
import {IElPoemsTypes} from "./interfaces/IElPoemsTypes.sol";
import {ElPoems} from "./ElPoems.sol";

import {LibPRNG} from "solady/src/utils/LibPRNG.sol";


// @author El
contract ElPoemsSourceMaterial is IElPoemsTypes, ERC721, Ownable, ReentrancyGuard {
  using LibPRNG for LibPRNG.PRNG;

  uint256 private _tokenId;

  IElPoemsMetadataRenderer public metadataRenderer;
  ElPoems public elPoems;

  mapping(uint256 tokenId => Material material) private _materials;


  error InvalidCaller();

  modifier onlyElPoems() { 
    if (msg.sender != address(elPoems)) revert InvalidCaller(); 
    _; 
  }
  
  constructor(IElPoemsMetadataRenderer _metadataRenderer) ERC721("EL POEMS SOURCE MATERIAL", "EPSM") { 
    metadataRenderer = _metadataRenderer;

    _initializeOwner(msg.sender);
  }

  function mint(address to, uint256 quantity) external onlyElPoems returns (uint256) {

    for (uint256 i; i < quantity; i++) {
      
      ++_tokenId;

      LibPRNG.PRNG memory prng = LibPRNG.PRNG(uint160(to) + _tokenId);

      _materials[_tokenId] = Material({
        typeIndex: prng.uniform(3),
        elementIndex: prng.uniform(27)
      });

      _mint(to, _tokenId);
    }

    //lastMinted
    return _tokenId;
  }

  function materialDetails(uint256 tokenId) external view returns (Material memory) {
    return _materials[tokenId];
  }

  function tokenURI(uint256 tokenId) public view override returns(string memory) {
    return metadataRenderer.tokenURI(tokenId);
  }

  function setElPoems(ElPoems _elPoems) external onlyOwner {
    elPoems = _elPoems;
  }

  function updateMetadataRenderer(IElPoemsMetadataRenderer newRenderer) external onlyOwner {
    metadataRenderer = newRenderer;
  }

  function transferFrom(address from, address to, uint256 tokenId) public virtual override {
    _transfer(from, to, tokenId);
  }

  function burn(uint256 tokenId) external onlyElPoems {
    _burn(tokenId);
  }

  function _beforeTokenTransfer(
    address /*from*/, 
    address /*to*/, 
    uint256 /*firstTokenId*/, 
    uint256 /*batchSize*/
  ) internal override {
    if(msg.sender != address(elPoems)) revert InvalidCaller();
  }

}
