// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {LibString} from "solady/src/utils/LibString.sol";
import {ElPoems} from "../src/ElPoems.sol";
import {ElPoemsSourceMaterial} from "../src/ElPoemsSourceMaterial.sol";
import {ElPoemsDataStorage} from "../src/ElPoemsDataStorage.sol";
import {ElPoemsMetadataRenderer} from "../src/ElPoemsMetadataRenderer.sol";

import {AssetStore} from "../src/AssetStore.sol";

contract ElPoemsTest is Test {

  ElPoems public elPoems;
  ElPoemsSourceMaterial public sourceMaterial;
  ElPoemsDataStorage public dataStorage;
  ElPoemsMetadataRenderer public metadataRenderer;
  AssetStore public assetStore;

  address user1 = address(4312);
  address user2 = address(1409);
  address user3 = address(7712);
  address user4 = address(92893839381939481);
  address user5 = address(23441);
  address user6 = address(13411);


  event PoemCreated();
  event PoemFinished(uint256 indexed tokenId);
  event PersonalContentAdded();
  event FriendAdded(uint256 indexed tokenId, address indexed friend);
  event MaterialTransfered(address indexed to);
  event SourceMaterialMinted(uint256 indexed lastTokenId);

  error PersonalContentAlreadyAdded();
  error TitleAlreadyAdded();
  error SourceMaterialAlreadyTransfered();
  error AddPersonalContentFirst();
  error PoemAlreadyFinished();
  error AddressCannotBeZero();
  error NotPoemFriend();
  error TransferSourceMaterialFirst();
  error NoSupplyLeft();
  error AlreadyHasPoem();
  error CannotTransferUnfinishedPoem();
  error HasNoPoemActive();
  error ContentNotInLenRange();
  error AlreadyHasMaterial();
  error CannotTransferToYourself();
  error CannotMintMaterial();
  error NotTokenOwner();
  error MintNotOpen();

  string svgStart = '<svg width="350" height="450" viewBox="0 0 350 450" fill="none" xmlns="http://www.w3.org/2000/svg"><style>#content{-ms-overflow-style:none;scrollbar-width:none;overflow-y:scroll;}#content::-webkit-scrollbar{display:none;}#content{height:360px;padding:15px;padding-top:0;text-transform:lowercase;text-align:justify;}</style><rect width="350" height="450" fill="#3E4D38"/><foreignObject x="0" y="0" width="350" height="450"><div id="content" xmlns="http://www.w3.org/1999/xhtml"><p style="color:#fefefe;font-family:serif;font-style:italic;font-size:1.15em;font-weight:520;text-align:justify;text-justify:inter-word;margin-top:10px auto;">';
  //string svgPoemStart = '<svg width="350" height="450" viewBox="0 0 350 450" fill="none" xmlns="http://www.w3.org/2000/svg"><style>#content{-ms-overflow-style:none;scrollbar-width:none;overflow-y:scroll;}#content::-webkit-scrollbar{display:none;}#content{height:360px;padding:20px;padding-top:0;text-transform:lowercase;text-align:justify;}</style><path fill="#fff" d="M0 0h350v450H0z"/><path fill="#F6EEE3" d="M0 0h116v194H0zm170 345h180v105H170z"/><path fill="#EEE7D7" d="M0 256h116v194H0z"/><path fill="#D9BDA5" d="M116 97h162v142H116zm168-16h66v194h-66z"/><path fill="#E5DECF" d="M220 194h116v194H220z"/><path fill="#E5DECF" d="M13 147h242v94H13z"/><path fill="#D9BDA5" d="M54 194h116v194H54z"/><path fill="#E5DECF" d="M110 0h240v84H110z"/><path fill="#E5CBBA" d="M89 50h216v68H89z"/><path fill="#F6EEE3" d="M89 338h242v88H89z"/><path fill="#F6EEE3" d="M134 225h116v122H134z"/><path fill="#D9BDA5" d="M1 147h16v108H1z"/><path fill="ivory" d="M278 117h21v108h-21z"/><path fill="#E2DFD2" d="M9 239h53v22H9z"/><path fill="#F5FFFA" d="M110 416h68v34h-68z"/><foreignObject x="0" y="0" width="350" height="450"><div id="content" xmlns="http://www.w3.org/1999/xhtml"><p style="color:#000;font-family:serif;font-size:1em;font-weight:540;text-align:justify;text-justify:inter-word;margin:10px auto;white-space:pre-wrap">';
  string svgEnd = '</p></div></foreignObject></svg>';

  receive() external payable {}
  fallback() external payable {}

  function setUp() public {

    bytes memory convertSvgStart = abi.encodePacked(svgStart);
    //bytes memory convertSvgPoemStart = abi.encodePacked(svgPoemStart);

    bytes memory convertSvgEnd = abi.encodePacked(svgEnd);

    assetStore = new AssetStore();

    assetStore.saveAsset(convertSvgStart);
    //assetStore.saveAsset(convertSvgPoemStart);
    assetStore.saveAsset(convertSvgEnd);

    address svgStartAddr = assetStore.assetAddress(keccak256(convertSvgStart));
    //address svgPoemStartAddr = assetStore.assetAddress(keccak256(convertSvgPoemStart));
    address svgEndAddr = assetStore.assetAddress(keccak256(convertSvgEnd));

    // DEPLOY CONTRACTS

    metadataRenderer = new ElPoemsMetadataRenderer(svgStartAddr, svgEndAddr);
    sourceMaterial = new ElPoemsSourceMaterial(metadataRenderer);
    
    elPoems = new ElPoems(metadataRenderer, sourceMaterial);

    metadataRenderer.setElPoemsSourceMaterial(sourceMaterial);
    sourceMaterial.setElPoems(elPoems);

    vm.deal(user1, 2 ether);
    vm.deal(user2, 2 ether);
    vm.deal(user3, 2 ether);
    vm.deal(user4, 2 ether);
    vm.deal(user5, 2 ether);
    vm.deal(user6, 2 ether);
  }


  //TESTING EVENTS

  //&
  function testMintMaterial() public {
    elPoems.ownerMint();
    elPoems.transferSourceMaterial(3, user1);

    vm.startPrank(user1);
    vm.expectEmit();
    emit SourceMaterialMinted(5);
    elPoems.mintSourceMaterial();
    vm.stopPrank();
  }

  function testTransferSourceMaterial() public {
    elPoems.ownerMint();
    elPoems.transferSourceMaterial(3, user1);

    vm.startPrank(user1);
    elPoems.mintSourceMaterial();
    vm.expectEmit();
    emit MaterialTransfered(user2);
    elPoems.transferSourceMaterial(3, user2);
    vm.stopPrank();
  }

  function testTransferSourceMaterialToZeroAddr() public {
    elPoems.ownerMint();
    elPoems.transferSourceMaterial(3, user1);

    vm.startPrank(user1);
    elPoems.mintSourceMaterial();
    elPoems.transferSourceMaterial(3, user3);
    vm.stopPrank();

    vm.startPrank(user3);
    elPoems.mintSourceMaterial();
    vm.expectEmit();
    emit MaterialTransfered(address(0));
    elPoems.transferSourceMaterial(3, user4);
    vm.stopPrank();
  }

  function testAddPersonalContent() public {
    elPoems.ownerMint();
    elPoems.transferSourceMaterial(3, user1);

    vm.startPrank(user1);
    elPoems.mintSourceMaterial();
    elPoems.transferSourceMaterial(3, user2);
    vm.expectEmit();
    emit PersonalContentAdded();
    elPoems.addPersonalContent("Looking forward to see my BIG PRIZE on this contest.");
    vm.stopPrank();
  }

  function testSetFriend() public {
    elPoems.ownerMint();
    elPoems.transferSourceMaterial(3, user1);

    vm.startPrank(user1);
    elPoems.mintSourceMaterial();
    elPoems.transferSourceMaterial(3, user2);
    elPoems.addPersonalContent("Looking forward to see my BIG PRIZE on this contest.");
    vm.expectEmit();
    emit FriendAdded(2, user3);
    elPoems.setFriend(user3);
    vm.stopPrank();
  }

  function testFinishPoem() public {
    elPoems.ownerMint();
    elPoems.transferSourceMaterial(3, user1);

    vm.startPrank(user1);
    elPoems.mintSourceMaterial();
    elPoems.transferSourceMaterial(3, user2);
    elPoems.addPersonalContent("Looking forward to see my BIG PRIZE on this contest.");
    elPoems.setFriend(user3);
    vm.stopPrank();

    vm.startPrank(user3);
    vm.expectEmit();
    emit PoemFinished(2);
    elPoems.finishPoem(2, "The First Poem");
    vm.stopPrank();
  }


  //TESTING REVERTS

  function testMintMaterialNoSupplyLeft() public {
    elPoems.ownerMint();
    elPoems.transferSourceMaterial(3, user1);

    vm.startPrank(user1);
    elPoems.mintSourceMaterial();
    elPoems.transferSourceMaterial(3, user2);
    vm.stopPrank();

    vm.startPrank(user2);
    elPoems.mintSourceMaterial();
    elPoems.transferSourceMaterial(3, user4);
    vm.stopPrank();

    vm.startPrank(user4);
    vm.expectRevert(abi.encodeWithSelector(NoSupplyLeft.selector));
    elPoems.mintSourceMaterial();
    vm.stopPrank();
  }

  function testCannotMintMaterial() public {
    elPoems.ownerMint();
    elPoems.transferSourceMaterial(3, user1);

    vm.startPrank(user1);
    elPoems.mintSourceMaterial();
    elPoems.transferSourceMaterial(3, user2);
    vm.stopPrank();

    vm.startPrank(user3);
    vm.expectRevert(abi.encodeWithSelector(CannotMintMaterial.selector));
    elPoems.mintSourceMaterial();
    vm.stopPrank();
  }

  function testHasNoPoemActive() public {
    vm.startPrank(user1);
    vm.expectRevert(abi.encodeWithSelector(HasNoPoemActive.selector));
    elPoems.transferSourceMaterial(3, user2);
    vm.stopPrank();
  }

  function testNotTokenOwner() public {
    elPoems.ownerMint();
    elPoems.transferSourceMaterial(3, user1);

    vm.startPrank(user1);
    elPoems.mintSourceMaterial();
    elPoems.transferSourceMaterial(3, user2);
    vm.stopPrank();

    vm.startPrank(user2);
    elPoems.mintSourceMaterial();
    vm.expectRevert(abi.encodeWithSelector(NotTokenOwner.selector));
    elPoems.transferSourceMaterial(1, user3);
    vm.stopPrank();
  }

  function testMaterialAlreadyTransfered() public {
    elPoems.ownerMint();
    elPoems.transferSourceMaterial(3, user1);

    vm.startPrank(user1);
    elPoems.mintSourceMaterial();
    elPoems.transferSourceMaterial(3, user2);
    vm.stopPrank();

    vm.startPrank(user1);
    vm.expectRevert(abi.encodeWithSelector(SourceMaterialAlreadyTransfered.selector));
    elPoems.transferSourceMaterial(4, user3);
    vm.stopPrank();
  }

  function testAlreadyHasMaterial() public {
    elPoems.ownerMint();
    elPoems.transferSourceMaterial(3, user1);

    vm.startPrank(user1);
    elPoems.mintSourceMaterial();
    elPoems.transferSourceMaterial(3, user2);
    vm.stopPrank();

    vm.startPrank(user2);
    elPoems.mintSourceMaterial();
    vm.expectRevert(abi.encodeWithSelector(AlreadyHasMaterial.selector));
    elPoems.transferSourceMaterial(6, user2);
    vm.stopPrank();
  }

  function testAlreadyHasPoem() public {
    elPoems.ownerMint();
    elPoems.transferSourceMaterial(3, user1);

    vm.startPrank(user1);
    elPoems.mintSourceMaterial();
    elPoems.transferSourceMaterial(3, user2);
    elPoems.addPersonalContent("Looking forward to see my BIG PRIZE on this contest.");
    elPoems.setFriend(user3);
    vm.stopPrank();

    vm.startPrank(user3);
    elPoems.finishPoem(2, "The First Poem");
    vm.stopPrank();

    vm.startPrank(user2);
    elPoems.mintSourceMaterial();
    vm.expectRevert(abi.encodeWithSelector(AlreadyHasPoem.selector));
    elPoems.transferSourceMaterial(3, user1);
    vm.stopPrank();
  }

  //&

  function testContentAlreadyAdded() public {
    elPoems.ownerMint();
    elPoems.transferSourceMaterial(3, user1);

    vm.startPrank(user1);
    elPoems.mintSourceMaterial();
    elPoems.transferSourceMaterial(3, user2);
    elPoems.addPersonalContent("Looking forward to see my BIG PRIZE on this contest.");
    vm.expectRevert(abi.encodeWithSelector(PersonalContentAlreadyAdded.selector));
    elPoems.addPersonalContent("Looking forward to see my BIG PRIZE on this contest.");
    vm.stopPrank();
  }

  function testContentNotInLenRange() public {
    elPoems.ownerMint();
    elPoems.transferSourceMaterial(3, user1);

    vm.startPrank(user1);
    elPoems.mintSourceMaterial();
    elPoems.transferSourceMaterial(3, user2);
    vm.expectRevert(abi.encodeWithSelector(ContentNotInLenRange.selector));
    elPoems.addPersonalContent("Looking");
    vm.stopPrank();
  }

  function testPoemAlreadyFinished() public {
    elPoems.ownerMint();
    elPoems.transferSourceMaterial(3, user1);

    vm.startPrank(user1);
    elPoems.mintSourceMaterial();
    elPoems.transferSourceMaterial(3, user2);
    elPoems.addPersonalContent("Looking forward to see my BIG PRIZE on this contest.");
    elPoems.setFriend(user3);
    vm.stopPrank();

    vm.startPrank(user3);
    elPoems.finishPoem(2, "The First Poem");
    vm.expectRevert(abi.encodeWithSelector(PoemAlreadyFinished.selector));
    elPoems.finishPoem(2, "The First Poem");
    vm.stopPrank();
  }

  function testNotPoemFriend() public {
    elPoems.ownerMint();
    elPoems.transferSourceMaterial(3, user1);

    vm.startPrank(user1);
    elPoems.mintSourceMaterial();
    elPoems.transferSourceMaterial(3, user2);
    elPoems.addPersonalContent("Looking forward to see my BIG PRIZE on this contest.");
    elPoems.setFriend(user3);
    vm.stopPrank();

    vm.startPrank(user2);
    vm.expectRevert(abi.encodeWithSelector(NotPoemFriend.selector));
    elPoems.finishPoem(1, "The First Poem");
    vm.stopPrank();
  }

  function testFriendCannotBeZero() public {
    elPoems.ownerMint();
    elPoems.transferSourceMaterial(3, user1);

    vm.startPrank(user1);
    elPoems.mintSourceMaterial();
    elPoems.transferSourceMaterial(3, user2);
    elPoems.addPersonalContent("Looking forward to see my BIG PRIZE on this contest.");
    vm.expectRevert(abi.encodeWithSelector(AddressCannotBeZero.selector));
    elPoems.setFriend(address(0));
    vm.stopPrank();
  }

  function testTransferMaterialFirst() public {
    elPoems.ownerMint();
    elPoems.transferSourceMaterial(3, user1);

    vm.startPrank(user1);
    elPoems.mintSourceMaterial();
    vm.expectRevert(abi.encodeWithSelector(TransferSourceMaterialFirst.selector));
    elPoems.addPersonalContent("Looking forward to see my BIG PRIZE on this contest.");
    vm.stopPrank();
  }

  function testAddContentFirst() public {
    elPoems.ownerMint();
    elPoems.transferSourceMaterial(3, user1);

    vm.startPrank(user1);
    elPoems.mintSourceMaterial();
    vm.expectRevert(abi.encodeWithSelector(AddPersonalContentFirst.selector));
    elPoems.setFriend(user2);
    vm.stopPrank();
  }

  function testAddContentFirst2() public {
    elPoems.ownerMint();
    elPoems.transferSourceMaterial(3, user1);

    vm.startPrank(user1);
    elPoems.mintSourceMaterial();
    elPoems.transferSourceMaterial(3, user2);
    vm.expectRevert(abi.encodeWithSelector(AddPersonalContentFirst.selector));
    elPoems.setFriend(user2);
    vm.stopPrank();
  }

  function testNotPoemFriend2() public {
    elPoems.ownerMint();
    elPoems.transferSourceMaterial(3, user1);

    vm.startPrank(user1);
    elPoems.mintSourceMaterial();
    elPoems.transferSourceMaterial(3, user2);
    elPoems.addPersonalContent("Looking forward to see my BIG PRIZE on this contest.");
    vm.stopPrank();

    vm.startPrank(user3);
    vm.expectRevert(abi.encodeWithSelector(NotPoemFriend.selector));
    elPoems.finishPoem(1, "Title");
    vm.stopPrank();
  }
  //&/

  function testWithdraw() public {
    elPoems.ownerMint();
    elPoems.transferSourceMaterial(3, user1);

    vm.startPrank(user1);
    elPoems.mintSourceMaterial{value: 0.011 ether}();

    elPoems.transferSourceMaterial(3, user2);
    elPoems.addPersonalContent("Two people are sitting side by side, around them a beautiful world exists, green fields, flowing rivers, running animals, solar energy and fast transportation exist in abundance");
    elPoems.setFriend(user3);
    vm.stopPrank();
    vm.startPrank(user3);
    elPoems.finishPoem(2, "The First Poem");
    vm.stopPrank();

    address elPoemOwner = elPoems.owner();

    elPoems.withdraw(elPoemOwner);
  }

  /*
  function testMintMany() public {

    //MINT THE #1 

    vm.startPrank(user1);
    elPoems.mintSourceMaterial{value: 0.011 ether}();

    elPoems.transferSourceMaterial(3, user2);
    elPoems.addPersonalContent("Two people are sitting side by side, around them a beautiful world exists, green fields, flowing rivers, running animals, solar energy and fast transportation exist in abundance");
    elPoems.setFriend(user3);
    vm.stopPrank();
    vm.startPrank(user3);
    elPoems.finishPoem(1, "The First Poem");
    vm.stopPrank();

    string memory tokenUri1 = elPoems.tokenURI(1);
    console2.log("TOKEN URI #1", tokenUri1);


    //MINT THE #2
    
    vm.startPrank(user2);
    elPoems.mintSourceMaterial{value: 0.011 ether}();
    elPoems.transferSourceMaterial(4, user3);
    elPoems.addPersonalContent("She is a model and she is looking good. I would like to take her home that is understood. She plays hard to get, she smiles from time to time");
    elPoems.setFriend(user4);
    vm.stopPrank();
    vm.startPrank(user4);
    elPoems.finishPoem(2, "She is poetry");
    vm.stopPrank();

    string memory tokenUri2 = elPoems.tokenURI(2);
    console2.log("TOKEN URI #2", tokenUri2);


    //MINT THE #3
  
    vm.startPrank(user3);
    elPoems.mintSourceMaterial{value: 0.011 ether}();
    elPoems.transferSourceMaterial(6, user4);
    elPoems.addPersonalContent("I laughed and shook hand, and made my way back home");
    elPoems.setFriend(user5);
    vm.stopPrank();
    vm.startPrank(user5);
    elPoems.finishPoem(3, "The man");
    vm.stopPrank();

    string memory tokenUri3 = elPoems.tokenURI(3);
    console2.log("TOKEN URI #3", tokenUri3);


    //MINT THE #4

    vm.startPrank(user4);
    elPoems.mintSourceMaterial{value: 0.011 ether}();
    elPoems.transferSourceMaterial(8, user5);
    elPoems.addPersonalContent("Every beat of my heart whispers your name, a love song carried on the wind. Come dance with me tonight. Lost in your eyes, a universe unfolds. Forever entwined, two souls made whole.");
    elPoems.setFriend(user5);
    vm.stopPrank();
    vm.startPrank(user5);
    elPoems.finishPoem(4, "The pe");
    vm.stopPrank();

    string memory tokenUri4 = elPoems.tokenURI(4);
    console2.log("TOKEN URI #4", tokenUri4);


    //MINT THE #5

    vm.startPrank(user5);
    elPoems.mintSourceMaterial{value: 0.011 ether}();
    elPoems.transferSourceMaterial(8, user6);
    elPoems.addPersonalContent("A truly original person with a truly original mind will not be able to function in the old form and will simply do something different");
    elPoems.setFriend(user6);
    vm.stopPrank();
    vm.startPrank(user6);
    elPoems.finishPoem(5, "The pepp");
    vm.stopPrank();

    string memory tokenUri5 = elPoems.tokenURI(5);
    console2.log("TOKEN URI #5", tokenUri5);

    uint256 runenumber = LibString.runeCount("it's");
    console2.log("RUNNER COUNT: ", runenumber);

    ///address payable elPoemOwner = payable(elPoems.owner();

    //vm.startPrank(elPoemOwner);
    //assertEq(elPoemOwner.balance, 0);
    //elPoems.withdraw(elPoemOwner);
    //assertEq(elPoemOwner.balance, 0.011 ether * 5);

    assertEq(address(elPoems).balance, 0.011 ether * 5);
  }
  */

  /*
  function testMintSVG() public {
    vm.createDir("generated/image", true);

    elPoems.ownerMint();
    elPoems.transferSourceMaterial(3, user1);
    elPoems.addPersonalContent("Just as when we come into the world, when we die we are afraid of the unknown");
    elPoems.setFriend(user5);
    vm.startPrank(user5);
    elPoems.finishPoem(1, "Poem");
    vm.stopPrank();

    string memory image = elPoems.tokenSVG(1);
    vm.writeFile(string.concat("generated/image/1", ".svg"), image);

    vm.startPrank(user1);
    elPoems.mintSourceMaterial();
    elPoems.transferSourceMaterial(3, user2);
    elPoems.addPersonalContent("Every beat of my heart whispers your name, a love song carried on the wind. Come dance with me tonight. Lost in your eyes, a universe unfolds. Forever entwined, two souls made whole.");
    elPoems.setFriend(user3);
    vm.stopPrank();
    vm.startPrank(user3);
    elPoems.finishPoem(2, "The First Poem");
    vm.stopPrank();

    string memory image1 = elPoems.tokenSVG(2);
    vm.writeFile(string.concat("generated/image/2", ".svg"), image1);


    //MINT THE #2
    
    vm.startPrank(user2);
    elPoems.mintSourceMaterial();
    elPoems.transferSourceMaterial(6, user3);
    elPoems.addPersonalContent("But the fear is something from within us that has nothing to do with reality");
    elPoems.setFriend(user4);
    vm.stopPrank();
    vm.startPrank(user4);
    elPoems.finishPoem(3, "She is poetry");
    vm.stopPrank();

    string memory image2 = elPoems.tokenSVG(3);
    vm.writeFile(string.concat("generated/image/3", ".svg"), image2);


    //MINT THE #3
    
    /*
    vm.startPrank(user3);
    elPoems.mintSourceMaterial();
    elPoems.transferSourceMaterial(8, user4);
    elPoems.addPersonalContent("But the fear is something from within us that has nothing to do with reality");
    elPoems.setFriend(user5);
    vm.stopPrank();
    vm.startPrank(user5);
    elPoems.finishPoem(4, "The man");
    vm.stopPrank();

    string memory image3 = elPoems.tokenSVG(3);
    vm.writeFile(string.concat("generated/image/3", ".svg"), image3);
    */

    //MINT THE #4

    /*
    vm.startPrank(user4);
    elPoems.mintSourceMaterial();
    elPoems.transferSourceMaterial(8, user5);
    elPoems.addPersonalContent("Just as when we come into the world, when we die we are afraid of the unknown");
    elPoems.setFriend(user5);
    vm.stopPrank();
    vm.startPrank(user5);
    elPoems.finishPoem(4, "The pe");
    vm.stopPrank();

    string memory image4 = elPoems.tokenSVG(4);
    vm.writeFile(string.concat("generated/image/4", ".svg"), image4);


    //MINT THE #5

    vm.startPrank(user5);
    elPoems.mintSourceMaterial();
    elPoems.transferSourceMaterial(8, user6);
    elPoems.addPersonalContent("A truly original person with a truly original mind will not be able to function in the old form and will simply do something different");
    elPoems.setFriend(user6);
    vm.stopPrank();
    vm.startPrank(user6);
    elPoems.finishPoem(5, "The pepp");
    vm.stopPrank();

    string memory image5 = elPoems.tokenSVG(5);
    vm.writeFile(string.concat("generated/image/5", ".svg"), image5);
    */
  //}
}
