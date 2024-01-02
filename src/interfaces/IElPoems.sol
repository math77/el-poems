// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;


import {IElPoemsTypes} from "./IElPoemsTypes.sol";

interface IElPoems {

  event PoemCreated();

  event TitleAdded();

  event PersonalContentAdded();

  event FriendAdded();

  event MaterialTransfered(address indexed to);


  error PersonalContentAlreadyAdded();

  error TitleAlreadyAdded();

  error SourceMaterialAlreadyTransfered();

  error PersonalContentIsEmpty();

  error PoemAlreadyFinished();

  error AddressCannotBeZero();

  error NotPoemFriend();

  error NotPoemCreator();

  error NoSupplyLeft();

  error AlreadyHasPoem();

  error CannotTransferUnfinishedPoem();

  error HasNoPoemActive();

  error ContentNotInLenRange();

  error AlreadyHasMaterial();

  error CannotTransferToYourself();

  error CannotMintMaterial();

  error NotTokenOwner();


  function mintSourceMaterial() external;

  function transferSourceMaterial(uint256 tokenId, address to) external;

  function finishPoem(uint256 tokenId, string calldata title) external;

  function setFriend(address friend) external;

  function addPersonalContent(string calldata content) external;

  function elPoemDetails(uint256 tokenId) external view returns (IElPoemsTypes.ElPoem memory);

  function elPoemId(address creator) external view returns (uint256);
}
