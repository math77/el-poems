// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Ownable} from "solady/src/auth/Ownable.sol";
import {SSTORE2} from "solady/src/utils/SSTORE2.sol";
import {LibString} from "solady/src/utils/LibString.sol";

import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

import {ElPoemsSourceMaterial} from "./ElPoemsSourceMaterial.sol";

import {IElPoemsMetadataRenderer} from "./interfaces/IElPoemsMetadataRenderer.sol";
import {IElPoemsTypes} from "./interfaces/IElPoemsTypes.sol";
import {IElPoems} from "./interfaces/IElPoems.sol";


// @author El
contract ElPoems is IElPoems, IElPoemsTypes, ERC721, Ownable, ReentrancyGuard {

  uint256 private _tokenId;

  uint256 public constant POEMS_MAX_SUPPLY = 200;
  uint256 public constant POEMS_MINT_PRICE = 0.011 ether;


  ElPoemsSourceMaterial public sourceMaterial;
  IElPoemsMetadataRenderer public metadataRenderer;

  mapping(uint256 tokenId => ElPoem poem) private _elPoems;
  mapping(address minter => uint256 tokenId) private _hasPoem; // 1 poem by wallet
  mapping(address minter => uint256[] ids) private _materials;

  bool public openMint;

  receive() external payable {}
  fallback() external payable {}

  constructor(IElPoemsMetadataRenderer _metadataRenderer, ElPoemsSourceMaterial _sourceMaterial) ERC721("EL POEMS", "ELP") {
    metadataRenderer = _metadataRenderer;
    sourceMaterial = _sourceMaterial;

    _initializeOwner(msg.sender);
  }

  function mintSourceMaterial() external payable nonReentrant {
    if (!openMint) revert MintNotOpen();
    if (_tokenId == POEMS_MAX_SUPPLY) revert NoSupplyLeft();
    if (msg.value != POEMS_MINT_PRICE) revert WrongPrice();
    if (sourceMaterial.balanceOf(msg.sender) != 1) revert CannotMintMaterial();
    
    _mintSourceMaterial(msg.sender, 2);
  }

  //tokenId -> material being transfered
  function transferSourceMaterial(uint256 tokenId, address to) external {

    uint256 poemId = _hasPoem[msg.sender];

    if (poemId == 0) revert HasNoPoemActive();

    ElPoem storage poem = _elPoems[poemId];

    if (sourceMaterial.ownerOf(tokenId) != msg.sender) revert NotTokenOwner();
    if (poem.stage >= Stage.TransferedMaterial) revert SourceMaterialAlreadyTransfered();
    if (sourceMaterial.balanceOf(to) > 0) revert AlreadyHasMaterial();
    if (_hasPoem[to] > 0) revert AlreadyHasPoem();

    poem.stage = Stage.TransferedMaterial;
    poem.transferedMaterial = tokenId; 

    if (_tokenId == POEMS_MAX_SUPPLY) {
      to = address(0);
      sourceMaterial.burn(tokenId);
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

    if (poem.stage < Stage.TransferedMaterial) revert TransferSourceMaterialFirst();
    if (poem.stage >= Stage.PersonalAdded) revert PersonalContentAlreadyAdded();
    if (LibString.runeCount(content) < 20 || LibString.runeCount(content) > 200) revert ContentNotInLenRange();

    poem.content = SSTORE2.write(bytes(content));
    poem.stage = Stage.PersonalAdded;

    emit PersonalContentAdded();
  }

  function finishPoem(uint256 tokenId, string calldata title) external {
    ElPoem storage poem = _elPoems[tokenId];

    if (msg.sender != poem.friend) revert NotPoemFriend();
    if (poem.stage == Stage.Finished) revert PoemAlreadyFinished();

    poem.title = title;
    poem.stage = Stage.Finished;
    poem.finishedAt = block.timestamp;

    uint256 count;
    for (uint256 i; i < 3; i++) {
      uint256 materialId = _materials[poem.createdBy][i];

      if (materialId != poem.transferedMaterial) {
        poem.finalMaterials[count] = materialId;
        count++;

        sourceMaterial.burn(materialId);
      }
    }

    delete _materials[poem.createdBy];

    emit PoemFinished({ tokenId: tokenId });
  }

  function setFriend(address friend) external {
    uint256 poemId = _hasPoem[msg.sender];

    if (poemId == 0) revert HasNoPoemActive();

    ElPoem storage poem = _elPoems[poemId];

    if (poem.stage < Stage.PersonalAdded) revert AddPersonalContentFirst();
    if (poem.stage == Stage.Finished) revert PoemAlreadyFinished();
    if (friend == address(0)) revert AddressCannotBeZero();
    if (friend == msg.sender) revert FriendCannotBeYourself();

    poem.friend = friend;

    emit FriendAdded({
      tokenId: poemId,
      friend: friend
    });
  }

  function tokenURI(uint256 tokenId) public view override returns(string memory) {
    return metadataRenderer.tokenURI(tokenId, _elPoems[tokenId]);
  }

  function elPoemDetails(uint256 tokenId) external view returns (ElPoem memory) {
    return _elPoems[tokenId];
  }

  function elPoemId(address creator) external view returns (uint256) {
    return _hasPoem[creator];
  }

  function withdraw(address to) external onlyOwner {
    (bool success, ) = to.call{value: address(this).balance}("");
    require(success, "Withdraw failed");
  }

  function updateMetadataRenderer(IElPoemsMetadataRenderer newRenderer) external onlyOwner {
    metadataRenderer = newRenderer;
  }

  function updateSourceMaterial(ElPoemsSourceMaterial newSourceMaterial) external onlyOwner {
    sourceMaterial = newSourceMaterial;
  }

  function ownerMint() external onlyOwner {
    openMint = true;
    _mintSourceMaterial(msg.sender, 3);
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

    emit SourceMaterialMinted({ lastTokenId: lastMinted });
  }


  /* CANNOT TRANSFER UNFINISHED POEM */

  function _beforeTokenTransfer(
    address from, 
    address /*to*/, 
    uint256 /*firstTokenId*/, 
    uint256 /*batchSize*/
  ) internal override {
    if (from != address(0)) {
      if (_elPoems[_hasPoem[from]].stage != Stage.Finished) revert CannotTransferUnfinishedPoem();
    }
  }
}
