// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "../../src/BlockFunding.sol";

library ClonesHelper {
    address public constant owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    string public constant name = "MockedContract";
    string public constant subtitle = "This is a mocked contract for testing purposes";
    string public constant description = "This is the description of the contract created for testing purposes";
    address public constant targetWallet = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint public constant campaignStartingDateTimestamp = 1707005560;
    uint public constant campaignEndingDateTimestamp = 1709507562;
    uint public constant estimatedProjectReleaseDateTimestamp = 1727993562;
    BlockFunding.ProjectCategory public constant projectCategory = BlockFunding.ProjectCategory.art;
    uint public constant fundingRequested = 1000000000000000000;


    function createMockContract(address blockFundingContractAddress) public {
        BlockFunding(blockFundingContractAddress).createNewContract(
            owner,
            name,
            subtitle,
            description,
            new string[](3),
            targetWallet,
            campaignStartingDateTimestamp,
            campaignEndingDateTimestamp,
            estimatedProjectReleaseDateTimestamp,
            projectCategory,
            fundingRequested
        );


        //TODO set medias URI
        //"https://www.youtube.com/watch?v=dQw4w9WgXcQ",
        //"https://farm4.staticflickr.com/3731/11808916273_e2f1728616.jpg",
        //"https://static.hitek.fr/img/actualite/ill_m/382925734/TrollFace.jpg"
    }
}