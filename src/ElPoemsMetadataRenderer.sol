//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.20;


import {Ownable} from "solady/src/auth/Ownable.sol";


import {ElPoemsSourceMaterial} from "./ElPoemsSourceMaterial.sol";
import {ElPoemsDataStorage} from "./ElPoemsDataStorage.sol";

import {IElPoemsMetadataRenderer} from "./interfaces/IElPoemsMetadataRenderer.sol";
import {IElPoemsTypes} from "./interfaces/IElPoemsTypes.sol";

import {Base64} from "solady/src/utils/Base64.sol";
import {LibString} from "solady/src/utils/LibString.sol";
import {LibPRNG} from "solady/src/utils/LibPRNG.sol";
import {SSTORE2} from "solady/src/utils/SSTORE2.sol";
import {strings} from "./libraries/strings.sol";


// @author El
contract ElPoemsMetadataRenderer is ElPoemsDataStorage, IElPoemsTypes, IElPoemsMetadataRenderer, Ownable {
  using strings for *;


  address private immutable _svgStart;
  address private immutable _svgEnd;

  ElPoemsSourceMaterial public sourceMaterial;

  constructor(address svgStart, address svgEnd) {
    _svgStart = svgStart;
    _svgEnd = svgEnd;

    _initializeOwner(msg.sender);
  }

  function setElPoemsSourceMaterial(ElPoemsSourceMaterial _sourceMaterial) external onlyOwner {
    sourceMaterial = _sourceMaterial;
  }

  function splitTextToArray(string memory text) internal view returns(string[] memory parts) {
    strings.slice memory s = text.toSlice();
    strings.slice memory delim = " ".toSlice();
 
    parts = new string[](s.count(delim) + 1);

    for(uint256 i; i < parts.length;) {
      parts[i] = s.split(delim).toString();
      unchecked{i++;}
    }
  }

  function personalContent(address pointer) internal view returns (string memory) {
    return string(SSTORE2.read(pointer));
  }


  function materialContent(uint256 materialId) internal view returns (string memory content) {
    
    Material memory material = sourceMaterial.materialDetails(materialId);

    if (material.typeIndex == 1) {
      content = materials1[material.elementIndex];
    } else if (material.typeIndex == 2) {
      content = materials2[material.elementIndex];
    } else {
      content = materials3[material.elementIndex];
    }
  }

  
  function writerLoot(
    uint256 materialId1, 
    uint256 materialId2,
    address contentPointer
  ) internal view returns (string memory) {

    string memory allText = string(
      abi.encodePacked(
        materialContent(materialId1),
        " ",
        materialContent(materialId2),
        " ",
        personalContent(contentPointer)
      )
    );

    string[] memory allTextArray = splitTextToArray(allText);


    string memory rewrited;
    uint256 textLength = allTextArray.length;
    //uint256 count;

    for (uint256 i = textLength - 1; i > 0; i--) {
      uint256 j = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), i))) % (i + 1);

      string memory temp = allTextArray[i];
      allTextArray[i] = allTextArray[j];
      allTextArray[j] = temp;
    }

    for (uint256 i; i < textLength; i++) {
      rewrited = string(abi.encodePacked(rewrited, " ", allTextArray[i]));
    }

    return rewrited;
  }


  function tokenURI(uint256 tokenId, IElPoemsTypes.ElPoem memory elPoem) external view returns (string memory) {
    return writerLoot(
      elPoem.finalMaterials[0],
      elPoem.finalMaterials[1],
      elPoem.content
    );
  }

  function tokenURI(uint256 tokenId) external view returns (string memory) {
    string memory materialContent = materialContent(tokenId);
    return materialContent;
  }

}
