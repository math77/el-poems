// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";

import {ElPoems} from "../src/ElPoems.sol";
import {ElPoemsSourceMaterial} from "../src/ElPoemsSourceMaterial.sol";
import {ElPoemsDataStorage} from "../src/ElPoemsDataStorage.sol";
import {ElPoemsMetadataRenderer} from "../src/ElPoemsMetadataRenderer.sol";
import {AssetStore} from "../src/AssetStore.sol";


contract Deploy is Script {

  string svgStart = '<svg width="350" height="450" viewBox="0 0 350 450" fill="none" xmlns="http://www.w3.org/2000/svg"><style>#content{-ms-overflow-style:none;scrollbar-width:none;overflow-y:scroll;}#content::-webkit-scrollbar{display:none;}#content{height:360px;padding:15px;padding-top:0;text-transform:lowercase;text-align:justify;}</style><rect width="350" height="450" fill="#3E4D38"/><foreignObject x="0" y="0" width="350" height="450"><div id="content" xmlns="http://www.w3.org/1999/xhtml"><p style="color:#fefefe;font-family:serif;font-style:italic;font-size:1.15em;font-weight:520;text-align:justify;text-justify:inter-word;margin-top:10px auto;">';
  string svgEnd = '</p></div></foreignObject></svg>';


  function run() public {

    console2.log("Setup contracts ---");
      
    uint256 deployer = vm.envUint("DEPLOYER_KEY");

    vm.startBroadcast(deployer);

    /* DEPLOY ASSET STORE AND SAVE SVGS */

    //assetstore on base
    AssetStore assetStore = AssetStore(0xCd31e7AAE7306E1ef720B51ab13848DDe7A3Ed47);

    //assetstore on sepolia
    //AssetStore assetStore = AssetStore(0x1Cf125bC22ADD95fF09993FE882fC1f66Df10BF8);

    bytes memory convertSvgStart = abi.encodePacked(svgStart);
    bytes memory convertSvgEnd = abi.encodePacked(svgEnd);

    assetStore.saveAsset(convertSvgStart);
    assetStore.saveAsset(convertSvgEnd);

    address svgStartAddr = assetStore.assetAddress(keccak256(convertSvgStart));
    address svgEndAddr = assetStore.assetAddress(keccak256(convertSvgEnd));


    ElPoemsMetadataRenderer metadataRenderer = new ElPoemsMetadataRenderer(svgStartAddr, svgEndAddr);
    ElPoemsSourceMaterial sourceMaterial = new ElPoemsSourceMaterial(metadataRenderer);
      
    ElPoems elPoems = new ElPoems(metadataRenderer, sourceMaterial);

    metadataRenderer.setElPoemsSourceMaterial(sourceMaterial);
    sourceMaterial.setElPoems(elPoems);

    elPoems.ownerMint();
    elPoems.transferSourceMaterial(1, 0xe5840064e6cE4923EAc2EE381F5ab660617778e7);
    elPoems.addPersonalContent("Every beat of my heart whispers your name, a love song carried on the wind. Come dance with me tonight. Lost in your eyes, a universe unfolds. Forever entwined, two souls made whole.");
    elPoems.setFriend(0x3789538A99bb94421FF75F1f5BD1966faa8d55A8);

    vm.stopBroadcast();

    console2.log("--------- CONTRACTS ADDRESSES ---------");
    console2.log("ElPoems: ", address(elPoems));
    console2.log("ElPoemsMetadataRenderer: ", address(metadataRenderer));
    console2.log("ElPoemsSourceMaterial: ", address(sourceMaterial));
    console2.log("AssetStore: ", address(assetStore));
  }
}
