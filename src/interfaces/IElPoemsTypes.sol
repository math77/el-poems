//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.20;


interface IElPoemsTypes {

  enum Stage {
    Started,
    TransferedMaterial,
    PersonalAdded,
    FriendInvited,
    Finished
  }

  struct Material {
    uint256 typeIndex;
    uint256 elementIndex;
  }

  struct ElPoem {
    string title;
    address content;
    address createdBy;
    address friend;
    uint256 finishedAt;
    Stage stage;
    uint256[2] finalMaterials;
    uint256 transferedMaterial;
  }
}
