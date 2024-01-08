//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.20;

import {IElPoemsTypes} from "./IElPoemsTypes.sol";


// @author El
interface IElPoemsMetadataRenderer {
  function tokenURI(uint256 tokenId, IElPoemsTypes.ElPoem memory elPoem) external view returns (string memory);
  function tokenURI(uint256 tokenId) external view returns (string memory);
}
