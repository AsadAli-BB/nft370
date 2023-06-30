// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


// use case defining 
// Admin can Mint NFT Against Price 
// Admin can Place NFT on Fixed Price Sale
// Admin can change price of NFT
// Admin can Mint NFT for Fixed Price Sale 
// There should be cateegory of NFT's as like food, Education, Health, and etc
// withdraw tokens from contract
// 


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CharityToken is ERC721, Pausable, Ownable, ERC721Burnable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    mapping (uint => NFT) NftDetails; 

    enum status { NotOnSale , OnfixedPrice }
    enum charityCat {Education, Food, Health , Other}

    struct NFT {
        uint NftPrice; 
        status Nftstatus; 
        charityCat CharityCategory; 
    }

 
    constructor() ERC721("CharityToken", "CHTKN") {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function placeNftForFixedPrice(uint nftId, uint priceOfNFT, ) public onlyOwner {
        
        require(_exists(nftId) , "NFT Does't Exist");
        require(NftDetails[nftId].Nftstatus == status.NotOnSale, "NFT is Already on Fixed Price");
        NftDetails[nftId].NftPrice = priceOfNFT * 10 ** 18; 
        NftDetails[nftId].Nftstatus = status.OnfixedPrice;
        NftDetails[nftId].CharityCategory = 
        emit listedForFixedPrice (nftId , "NFT Listed For Fixed Price");

    }


    function updateNFTPrice(uint nftId, uint price) public onlyOwner {
        
        require(_exists(nftId) , "NFT Does't Exist");
        require(NftDetails[nftId].Nftstatus == status.NotOnSale, "NFT is Already on Fixed Price");
        NftDetails[nftId].NftPrice = price * 10 ** 18; 
        emit nftPriceUpdated (nftId, price, "NFT Price Updated"); 

    }

    function getNftPrice(uint nftId) public view returns (uint) {
        return NftDetails[nftId].NftPrice;
    }

    event nftPriceUpdated (uint , uint , string); 
    event listedForFixedPrice(uint, string ); 

}