// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Ownable} from "solady/src/auth/Ownable.sol";
import {SSTORE2} from "solady/src/utils/SSTORE2.sol";
import {LibPRNG} from "solady/src/utils/LibPRNG.sol";

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {ElPoemsSourceMaterial} from "./ElPoemsSourceMaterial.sol";

import {IElPoemsMetadataRenderer} from "./interfaces/IElPoemsMetadataRenderer.sol";
import {IElPoemsTypes} from "./interfaces/IElPoemsTypes.sol";
import {IElPoems} from "./interfaces/IElPoems.sol";

// @author El
contract ElPoems is IElPoems, IElPoemsTypes, ERC721, Ownable, ReentrancyGuard {
  using LibPRNG for LibPRNG.PRNG;

  uint256 private _tokenId;

  uint256 public constant POEMS_MAX_SUPPLY = 250;
  uint256 public constant POEMS_MINT_PRICE = 0.003 ether;


  ElPoemsSourceMaterial public sourceMaterial;
  IElPoemsMetadataRenderer public metadataRenderer;

  mapping(uint256 tokenId => ElPoem poem) private _elPoems;
  mapping(address minter => uint256 tokenId) private _hasPoem; // 1 poem by wallet
  mapping(address minter => uint256[] ids) private _materials;


  constructor(IElPoemsMetadataRenderer _metadataRenderer, ElPoemsSourceMaterial _sourceMaterial) ERC721("EL POEMS", "ELP") {
    metadataRenderer = _metadataRenderer;
    sourceMaterial = _sourceMaterial;

    _initializeOwner(msg.sender);
  }

  function mintSourceMaterial() external {

    if (_tokenId == POEMS_MAX_SUPPLY) revert NoSupplyLeft();

    if (sourceMaterial.nextTokenId() == 1) {
      _mintSourceMaterial(msg.sender, 3);
    } else {
      if (sourceMaterial.balanceOf(msg.sender) != 1) revert CannotMintMaterial();
      if (_hasPoem[msg.sender] > 0) revert AlreadyHasPoem();

      _mintSourceMaterial(msg.sender, 2);
    }
  }

  //tokenId -> material being transfered
  function transferSourceMaterial(uint256 tokenId, address to) external {

    uint256 poemId = _hasPoem[msg.sender];

    if (poemId == 0) revert HasNoPoemActive();

    ElPoem storage poem = _elPoems[poemId];

    if (sourceMaterial.ownerOf(tokenId) != msg.sender) revert NotTokenOwner();
    if (poem.stage >= Stage.TransferedMaterial) revert SourceMaterialAlreadyTransfered();
    if (_hasPoem[to] > 0) revert AlreadyHasPoem();
    if (sourceMaterial.balanceOf(to) > 0) revert AlreadyHasMaterial();
    if (msg.sender == to) revert CannotTransferToYourself();

    poem.stage = Stage.TransferedMaterial;
    poem.transferedMaterial = tokenId; 

    if (_tokenId == POEMS_MAX_SUPPLY) {
      to = address(0);
      _burn(tokenId);
    } else {

      _materials[to].push(tokenId);
      sourceMaterial.transferFrom(msg.sender, to, tokenId);
    }

    emit MaterialTransfered({ to: to });
  }

  function addPersonalContent(string calldata content) external {
    uint256 poemId = _hasPoem[msg.sender];

    if (poemId == 0) revert HasNoPoemActive();

    ElPoem storage poem = _elPoems[poemId];

    if (poem.stage >= Stage.PersonalAdded) revert PersonalContentAlreadyAdded();
    if(bytes(content).length < 50 || bytes(content).length > 300) revert ContentNotInLenRange();

    poem.content = SSTORE2.write(bytes(content));
    poem.stage = Stage.PersonalAdded;

    emit PersonalContentAdded();
  }

  function finishPoem(uint256 tokenId, string calldata title) external {
    ElPoem storage poem = _elPoems[tokenId];

    if (poem.stage == Stage.Finished) revert PoemAlreadyFinished();
    if (msg.sender != poem.friend) revert NotPoemFriend();

    poem.title = title;

    //REMIX, REMIX, REMIX HOW????

    for (uint256 i; i < 3; i++) {
      uint256 materialId = _materials[poem.createdBy][i];

      if (materialId != poem.transferedMaterial) {
        poem.finalMaterials[i] = materialId;
      }
    }

    delete _materials[poem.createdBy];

  }

  function setFriend(address friend) external {
    uint256 poemId = _hasPoem[msg.sender];

    if (poemId == 0) revert HasNoPoemActive();

    ElPoem storage poem = _elPoems[poemId];

    if (msg.sender != poem.createdBy) revert NotPoemCreator();
    if (poem.stage == Stage.Finished) revert PoemAlreadyFinished();
    if (friend == address(0)) revert AddressCannotBeZero();

    poem.friend = friend;

    emit FriendAdded();
  }

  function tokenURI(uint256 tokenId) public view override returns(string memory) {
    return metadataRenderer.tokenURI(tokenId, _elPoems[tokenId]);
  }

  function withdrawAll() external payable onlyOwner nonReentrant {
    (bool sent, ) = payable(msg.sender).call{value: msg.value}("");
    require(sent, "Error when withdrawing the balance sheet");
  }

  function _mintSourceMaterial(address to, uint256 quantity) internal {
    uint256 lastMinted = sourceMaterial.mint(to, quantity);

    ElPoem memory poem;
    poem.createdBy = to;
    poem.stage = Stage.Started;

    _elPoems[++_tokenId] = poem;
    _hasPoem[to] = _tokenId;


    for (uint256 i; i < quantity; i++) {
      _materials[to].push(lastMinted - i);
    }

    _mint(to, _tokenId);
  }

  function elPoemDetails(uint256 tokenId) external view returns (ElPoem memory) {
    return _elPoems[tokenId];
  }

  function elPoemId(address creator) external view returns (uint256) {
    return _hasPoem[creator];
  }

  //CANNOT TRANSFER UNFINISHED POEM
  function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address) {

    //if (_elPoems[tokenId].stage != Stage.Finished) revert CannotTransferUnfinishedPoem();

    super._update(to, tokenId, auth);
  }
}
