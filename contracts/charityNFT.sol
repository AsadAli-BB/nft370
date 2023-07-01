// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


// use case defining 
// Admin can Mint NFT Against Price 
// Admin can Place NFT on Fixed Price Sale
// Admin can change price of NFT
// Admin can Mint NFT for Fixed Price Sale 
// There should be cateegory of NFT's as like food, Education, Health, and etc
// withdraw tokens from contract

// Function for User

// functon to purrchase NFT against fixed price
// remove nft from sale 
// check NFT Category

// 0 ----> Not On Sale               1 ------> OnFixedPriceSale

// 0 ---> EDUCATION     1 ------> FOOD      2 -------> HEALTH      3 ---------> Other 


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CharityNFT is ERC721, Pausable, Ownable, ERC721Burnable {
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

    function safeMint(address to, uint Nftcat) public whenNotPaused onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        NftDetails[tokenId].CharityCategory = charityCat(Nftcat); 

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

    function placeNftForFixedPrice(uint nftId, uint priceOfNFT ) public whenNotPaused onlyOwner {
        
        require(_exists(nftId) , "NFT Does't Exist");
        require(NftDetails[nftId].Nftstatus == status.NotOnSale, "NFT is Already on Fixed Price");
        NftDetails[nftId].NftPrice = priceOfNFT * 10 ** 18; 
        NftDetails[nftId].Nftstatus = status.OnfixedPrice;
        emit listedForFixedPrice (nftId , "NFT Listed For Fixed Price");

    }


    function updateNFTPrice(uint nftId, uint price) public whenNotPaused onlyOwner {
        
        require(_exists(nftId) , "NFT Does't Exist");
        require(NftDetails[nftId].Nftstatus == status.OnfixedPrice, "NFT is Already on Fixed Price");
        NftDetails[nftId].NftPrice = price * 10 ** 18; 
        emit nftPriceUpdated (nftId, price, "NFT Price Updated"); 

    }

    function getNftPrice(uint nftId) public view returns (uint) {
        require(_exists(nftId) , "NFT Does't Exist");
        require(NftDetails[nftId].Nftstatus == status.OnfixedPrice, "NFT is Not on Sale");
        return NftDetails[nftId].NftPrice;

    }

    function purchaseNFT (uint nftId, address payable to) whenNotPaused public payable  {
        
        require(_exists(nftId) , "NFT Does't Exist");
        require(NftDetails[nftId].Nftstatus == status.OnfixedPrice, "NFT is Not on Sale");
        require(msg.value == NftDetails[nftId].NftPrice, "Insufficient Funds");
        _safeTransfer(ownerOf(nftId), to, nftId, "0x00");
        _removeNFTFromSale(nftId); 

    }

    function checkNftCategory(uint nftId ) public view returns (charityCat) {
        require(_exists(nftId) , "NFT Does't Exist");
        return NftDetails[nftId].CharityCategory;  
    }

    function _removeNFTFromSale(uint nftId) internal  {
        require(_exists(nftId) , "NFT Does't Exist");
        require(NftDetails[nftId].Nftstatus == status.OnfixedPrice, "NFT is Not on Sale");
        NftDetails[nftId].Nftstatus = status.NotOnSale; 
        emit removedFromSale (nftId, "NFT Removed From Sale"); 
    }

    function removeNFTFromSale(uint nftId) onlyOwner public whenNotPaused {
        require(_exists(nftId) , "NFT Does't Exist");
        require(NftDetails[nftId].Nftstatus == status.OnfixedPrice, "NFT is Not on Sale");
        NftDetails[nftId].Nftstatus = status.NotOnSale; 
        emit removedFromSale (nftId, "NFT Removed From Sale"); 
    }

    function getContractBalance()  public view onlyOwner returns (uint) {
        return address(this).balance; 
    }

    function withdrawBalance(address to, uint amount) onlyOwner whenNotPaused public {
        
        require(address(this).balance >= amount , "Invalid Amount to withdraw");
        payable(to).transfer(amount);
        emit balanceWithdrawn (amount, to , "Amount withdrawnn from Contract");

    }


    event nftPriceUpdated (uint , uint , string); 
    event listedForFixedPrice(uint, string ); 
    event removedFromSale(uint , string) ; 
    event balanceWithdrawn(uint , address,  string );



}