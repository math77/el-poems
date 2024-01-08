// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {IElPoemsTypes} from "./IElPoemsTypes.sol";


interface IElPoems {

  event PoemCreated();
  event PoemFinished(uint256 indexed tokenId);
  event PersonalContentAdded();
  event FriendAdded(uint256 indexed tokenId, address indexed friend);
  event MaterialTransfered(address indexed to);
  event SourceMaterialMinted(uint256 indexed lastTokenId);


  error PersonalContentAlreadyAdded();
  error SourceMaterialAlreadyTransfered();
  error PoemAlreadyFinished();
  error AddressCannotBeZero();
  error NotPoemFriend();
  error NoSupplyLeft();
  error AlreadyHasPoem();
  error CannotTransferUnfinishedPoem();
  error HasNoPoemActive();
  error ContentNotInLenRange();
  error AlreadyHasMaterial();
  error CannotMintMaterial();
  error NotTokenOwner();
  error TransferSourceMaterialFirst();
  error AddPersonalContentFirst();
  error FriendCannotBeYourself();
  error WrongPrice();
  error MintNotOpen();


  function mintSourceMaterial() external payable;
  function transferSourceMaterial(uint256 tokenId, address to) external;
  function finishPoem(uint256 tokenId, string calldata title) external;
  function setFriend(address friend) external;
  function addPersonalContent(string calldata content) external;
  function elPoemDetails(uint256 tokenId) external view returns (IElPoemsTypes.ElPoem memory);
  function elPoemId(address creator) external view returns (uint256);
}
