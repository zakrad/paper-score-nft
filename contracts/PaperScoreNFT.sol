// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";

contract PaperScore is Initializable, ERC1155Upgradeable, OwnableUpgradeable, ERC1155SupplyUpgradeable {

    struct Paper {
        uint8 maxSupply;
        uint8 accessGiven;
        mapping(address => bool) valid;
    }

    mapping(uint256 => Paper) papers;

    event SupplyChanged(uint8 maxSupply, uint256 id);
    event AccessGiven(address author, uint256 id);
    event Minted(address author, uint256 id);

    function initialize() initializer public {
        __ERC1155_init("https://paperscore.org/nft/paper-{id}.json");
        __Ownable_init();
        __ERC1155Supply_init();
    }

    function setMaxSupply(uint256 id, uint8 maxSupply) external onlyOwner {
        require(papers[id].maxSupply == 0, "Max supply is Immutable");
        papers[id].maxSupply == maxSupply;
        emit SupplyChanged(maxSupply, id);
    }

    function giveAccess(uint256 id, address author) external onlyOwner {
        require(papers[id].valid[author] == false, "Author already authorized");
        require(papers[id].accessGiven < papers[id].maxSupply, "All Authors authorized");
        papers[id].valid[author] == true;
        papers[id].accessGiven++;
        emit AccessGiven(author, id);
    }

    
    function mint(uint256 id) external {
        require(papers[id].valid[msg.sender] == true, "You are not authorized to Mint an ownership NFT.");
        require(totalSupply(id) < papers[id].maxSupply, "All ownership NFTs minted already.");
        papers[id].valid[msg.sender] == false;
        _mint(msg.sender, id, 1, "");
        emit Minted(msg.sender, id);
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155Upgradeable, ERC1155SupplyUpgradeable)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
