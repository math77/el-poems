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


// @author El
contract ElPoemsMetadataRenderer is ElPoemsDataStorage, IElPoemsTypes, IElPoemsMetadataRenderer, Ownable {
  using LibPRNG for LibPRNG.PRNG;

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

  function _personalContent(address pointer) internal view returns (string memory) {
    return string(SSTORE2.read(pointer));
  }

  function _materialContent(uint256 materialId) internal view returns (string memory content) {
    
    Material memory material = sourceMaterial.materialDetails(materialId);

    if (material.typeIndex == 0) {
      content = materials1[material.elementIndex];
    } else if (material.typeIndex == 1) {
      content = materials2[material.elementIndex];
    } else {
      content = materials3[material.elementIndex];
    }
  }

  function _remixThree(
    string memory text
  ) public view returns (string[] memory) {
    string[] memory inputArray = LibString.split(text, " ");

    uint256 inputLength = inputArray.length;
    uint256 resultLength = inputLength / 3;
    uint256 count;

    if (inputLength % 3 != 0) {
      resultLength++;
    }

    string[] memory newArray = new string[](resultLength);
    for(uint256 i; i < inputLength; i += 3) {
      string memory cutup;

      if (i < inputLength) {
        cutup = inputArray[i];
      }

      if (i + 1 < inputLength) {
        cutup = string(abi.encodePacked(cutup, " ", inputArray[i + 1]));
      }

      if (i + 2 < inputLength) {
        cutup = string(abi.encodePacked(cutup, " ", inputArray[i + 2]));
      }

      newArray[count] = cutup;
      count++;
    }

    return newArray;
  }


  function _writerLoot2(
    uint256 materialId1,
    uint256 materialId2,
    address contentPointer
  ) internal view returns (string memory rewrited) {

    string[] memory mt1Array = _remixThree(_materialContent(materialId1));
    string[] memory mt2Array = _remixThree(_materialContent(materialId2));
    string[] memory conArray = _remixThree(_personalContent(contentPointer));

    
    for (uint256 i; i < 9; i++) {
      LibPRNG.PRNG memory prng = LibPRNG.PRNG(uint160(contentPointer) + i);
      uint256 up = prng.uniform(3);

      if (up == 0) {
        rewrited = string(abi.encodePacked(rewrited, " ", mt1Array[prng.uniform(mt1Array.length)]));
      } else if (up == 1) {
        rewrited = string(abi.encodePacked(rewrited, " ", mt2Array[prng.uniform(mt2Array.length)]));
      } else {
        rewrited = string(abi.encodePacked(rewrited, " ", conArray[prng.uniform(conArray.length)]));
      }
    }

  }


  function _replacementOfFriend(
    string memory currentPoem,
    address friend
  ) internal view returns (string memory finalPoem) {
    uint256 amountOfWords = uint160(friend) % 10;

    string[] memory poemSplit = LibString.split(currentPoem, " ");
    uint256 poemLength = poemSplit.length;

    for (uint256 i; i < amountOfWords; i++) {
      LibPRNG.PRNG memory prng = LibPRNG.PRNG(uint160(friend) + i);

      //get the new word
      string memory newWord = zeitgeistWords[prng.uniform(zeitgeistWords.length)];

      //replace old random choose word for new word
      poemSplit[prng.uniform(poemLength)] = newWord;
    }

    for (uint256 i; i < poemLength; i++) {
      finalPoem = string(abi.encodePacked(finalPoem, " ", poemSplit[i]));
    }
  }

  function _finishPoem(string memory prefinalPoem) internal view returns (string memory finalPoem) {
    string[] memory sentencesOfThree = _remixThree(prefinalPoem);

    for (uint256 i; i < sentencesOfThree.length; i++) {
      finalPoem = string(abi.encodePacked(finalPoem, sentencesOfThree[i], "<br/>"));
    }
  }

  function tokenURI(uint256 tokenId, ElPoem memory elPoem) external view returns (string memory) {
    
    string memory finalPoem;
    if (elPoem.stage != Stage.Finished) {
      
      finalPoem = "POEM UNDER CONSTRUCTION.";
    
    } else {
      
      string memory rewritedPoem = _writerLoot2(
        elPoem.finalMaterials[0],
        elPoem.finalMaterials[1],
        elPoem.content
      );

      finalPoem = _finishPoem(_replacementOfFriend(
        rewritedPoem,
        elPoem.friend
      ));
    }
    

    (
      string memory title,
      string memory description
    ) = _generateTitleAndDescription(elPoem);


    string memory attrs = _generateAttributes(elPoem);

    return 
      string(
        abi.encodePacked(
          'data:application/json;base64,',
          Base64.encode(
            bytes(
              abi.encodePacked(
                '{"name": "',
                title,
                '", "description": "', description, '", "image": "data:image/svg+xml;base64,',
                Base64.encode(abi.encodePacked(SSTORE2.read(_svgStart), finalPoem, SSTORE2.read(_svgEnd))),
                '", "attributes": ',
                attrs,
                '}'
              )
            )
          )
        )
      );
  }

  function tokenURI(uint256 tokenId) external view returns (string memory) {
    string memory materialContent = _materialContent(tokenId);

    (
      string memory title,
      string memory description
    ) = _generateTitleAndDescription(tokenId);

    return 
      string(
        abi.encodePacked(
          'data:application/json;base64,',
          Base64.encode(
            bytes(
              abi.encodePacked(
                '{"name": "',
                title,
                '", "description": "', description, '", "image": "data:image/svg+xml;base64,',
                Base64.encode(abi.encodePacked(SSTORE2.read(_svgStart), materialContent, SSTORE2.read(_svgEnd))),
                '"}'
              )
            )
          )
        )
      );
  }

  function _generateTitleAndDescription(
    uint256 tokenId
  ) internal pure returns(string memory title, string memory description) {
    title = string(abi.encodePacked('Material #', LibString.toString(tokenId)));
    description = "A material for a (probably weird) poem.";
  }

  function _generateTitleAndDescription(
    ElPoem memory elPoem
  ) internal pure returns(string memory title, string memory description) {

    if (elPoem.stage != Stage.Finished) {
      title = "POEM WITH NO TITLE YET #";
      description = "A (probably weird) poem in construction.";
    } else {
      title = elPoem.title;
      description = "A (probably weird) poem.";
    }
  }

  function _generateAttributes(
    ElPoem memory elPoem
  ) internal pure returns (string memory) {

    return string(abi.encodePacked(
      '[{"trait_type":"Friend invited", "value":"',
      LibString.toHexString(elPoem.friend),
      '"}]'
    ));
  }

}
