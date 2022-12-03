// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./ContextMixin.sol";

contract PaperScore is Initializable, ERC1155Upgradeable, OwnableUpgradeable, ERC1155SupplyUpgradeable, ContextMixin {

    struct Paper {
        uint8 maxSupply;
        uint8 accessGiven;
        mapping(address => bool) valid;
    }

    uint256 public mintPrice;
    uint256 public feePrice;

    mapping(uint256 => Paper) papers;
    mapping(address => uint256) feeBalance;

    event SupplyChanged(uint8 maxSupply, uint256 id);
    event AccessGiven(address author, uint256 id);
    event AccessChanged(address author, uint256 id);
    event Minted(address author, uint256 id);
    event priceChanged(uint256 newPrice);
    event feeChanged(uint256 newFee);

    function initialize() initializer public {
        __ERC1155_init("https://paperscore.org/nft/paper-{id}.json");
        __Ownable_init();
        __ERC1155Supply_init();
    }

    receive() external payable{
        feeBalance[msg.sender] += msg.value;
    }
    
    function setMaxSupply(uint256 id, uint8 _maxSupply) external onlyOwner {
        require(papers[id].maxSupply == 0, "Max supply is Immutable");
        papers[id].maxSupply = _maxSupply;
        emit SupplyChanged(_maxSupply, id);
    }

    function giveAccess(uint256 id, address author) external onlyOwner {
        require(feePrice <= feeBalance[author], "Author did not pay for tx fee.");
        require(papers[id].valid[author] == false, "Author already authorized");
        require(papers[id].accessGiven < papers[id].maxSupply, "All Authors authorized");
        feeBalance[msg.sender] -= feePrice;
        papers[id].valid[author] = true;
        papers[id].accessGiven++;
        emit AccessGiven(author, id);
    }

    function changeAccess(uint256 id, address author) external {
        require(papers[id].valid[msg.sender] == true, "You are not allowed to edit access.");
        papers[id].valid[msg.sender] = false;
        papers[id].valid[author] = true;
        emit AccessChanged(author, id);
    }
    
    function setMintPrice(uint256 newPrice) external onlyOwner {
        mintPrice = newPrice;
        emit priceChanged(newPrice);
    }

    function setFeePrice(uint256 newFee) external onlyOwner {
        feePrice = newFee;
        emit feeChanged(newFee);
    }

    function withdraw(address receiver) external onlyOwner {
      payable(receiver).transfer(address(this).balance);
    }

    function mint(uint256 id) payable external {
        require(msg.value == mintPrice, "Send exact amount of ETH (mintPrice).");
        require(papers[id].valid[msg.sender] == true, "You are not authorized to Mint an ownership NFT.");
        require(totalSupply(id) < papers[id].maxSupply, "All ownership NFTs minted already.");
        papers[id].valid[msg.sender] = false;
        _mint(msg.sender, id, 1, "");
        emit Minted(msg.sender, id);
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function uri(uint256 _tokenid) override public pure returns (string memory) {
        return string(
            abi.encodePacked(
                "https://ipfs.io/ipfs/QmRR1E3TTtBYvQpCoMvds4JB6yREiZvUTC6HoLoYmYLBep/",
                Strings.toString(_tokenid),".json"
            )
        );
    }

    function contractURI() public view returns (string memory) {
        return "https://gateway.pinata.cloud/ipfs/QmPrj38UDUeRHxGbH4GmhhHVJpJZapcdgcwQariWWnnVon";
    }

    function _msgSender()
        internal
        override
        view
        returns (address sender)
    {
        return ContextMixin.msgSender();
    }

    function isApprovedForAll(
        address _owner,
        address _operator
    ) public override(ERC1155Upgradeable) view returns (bool isOperator) {
        // if OpenSea's ERC1155 Proxy Address is detected, auto-return true
            // for Polygon's Mumbai testnet, use 0x207Fa8Df3a17D96Ca7EA4f2893fcdCb78a304101
       if (_operator == address(0x53d791f18155C211FF8b58671d0f7E9b50E596ad)) {
            return true;
        }
        // otherwise, use the default ERC1155.isApprovedForAll()
        return super.isApprovedForAll(_owner, _operator);
    }
    
    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155Upgradeable, ERC1155SupplyUpgradeable)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

}
