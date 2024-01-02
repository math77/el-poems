// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {ElPoems} from "../src/ElPoems.sol";
import {ElPoemsSourceMaterial} from "../src/ElPoemsSourceMaterial.sol";
import {ElPoemsDataStorage} from "../src/ElPoemsDataStorage.sol";
import {ElPoemsMetadataRenderer} from "../src/ElPoemsMetadataRenderer.sol";


contract ElPoemsTest is Test {

  ElPoems public elPoems;
  ElPoemsSourceMaterial public sourceMaterial;
  ElPoemsDataStorage public dataStorage;
  ElPoemsMetadataRenderer public metadataRenderer;

  address user1 = address(4312);
  address user2 = address(1409);
  address user3 = address(7712);


  function setUp() public {

    //dataStorage = new ElPoemsDataStorage();
    metadataRenderer = new ElPoemsMetadataRenderer(address(121), address(211));
    sourceMaterial = new ElPoemsSourceMaterial(metadataRenderer);
    
    elPoems = new ElPoems(metadataRenderer, sourceMaterial);

    metadataRenderer.setElPoemsSourceMaterial(sourceMaterial);
    sourceMaterial.setElPoems(elPoems);

    vm.deal(user1, 2 ether);
    vm.deal(user2, 2 ether);
    vm.deal(user3, 2 ether);
  }

  function testUri() public {
    vm.startPrank(user1);
    elPoems.mintSourceMaterial();

    uint256 bala = sourceMaterial.balanceOf(user1);
    console2.log("BALALNCE: ", bala);

    elPoems.transferSourceMaterial(3, user2);

    elPoems.addPersonalContent("Looking forward to see my BIG PRIZE on this contest.");

    elPoems.setFriend(user3);

    vm.stopPrank();

    vm.startPrank(user3);

    elPoems.finishPoem(1, "The First Poem");

    string memory tokenUri = elPoems.tokenURI(1);

    console2.log(tokenUri);
  }

}
