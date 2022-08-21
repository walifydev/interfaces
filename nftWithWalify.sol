// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./erc721S.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IWALIFY {
    function verify(address, address) external returns(bool);
}

contract WalifyNFT is Ownable, ERC721S, ReentrancyGuard {
    using Strings for uint256;

    uint256 thePrice = 1000000000000000;

    mapping (address => uint256) public _whitelist;

    bool public _whitelist_on = false;

    uint256 public current_mint_max = 777;

    uint256 public num_revealed = 0;

    string _ending = ""; 

    IERC721 requiredContract; 

    bool _requirementOn = true;

    address walify;
    
    constructor(
        uint256 maxBatchSize_,
        uint256 collectionSize_
    ) ERC721S("Walify", "WAL", maxBatchSize_, collectionSize_) {
    }

    function setWalify(address target_contract) public onlyOwner{
        walify = target_contract;
    }

    function setRequiredContract(address target_contract) public onlyOwner{
        requiredContract = IERC721(target_contract);
    }

    function setRequirementOn(bool on_or_off) public onlyOwner{
        _requirementOn = on_or_off;
    }

    modifier checkWhitelist() {
        if(_whitelist_on){
            require(_whitelist[_msgSender()] > 0,"Account needs to whitelist"); 
            _whitelist[_msgSender()] -= 1;
            }
        _;
    }

    modifier checkRequiredRoot(address root) {
        require(requiredContract.balanceOf(root) > 0, "You do not own required NFT");
         _;
    }

    function checkRequiredProxy(address root, address proxy) internal{
        // verify proxy
        IWALIFY walify_contract = IWALIFY(walify);
        require(walify_contract.verify(root, proxy), "Walify did not verify. Root and proxy not associated");
        // now check for balance off of the proxy
        require(requiredContract.balanceOf(root) > 0, "You do not own required NFT");
    }


    // set amount whitelisted for user
    function setWhitelistAmount(address account, uint256 amount) public onlyOwner{
        _whitelist[account] = amount;
    }

    // turn on/off whitelist
    function setWhitelistStatus(bool status) public onlyOwner{
        _whitelist_on = status;
    }

    function seedWhitelist(address[] memory addresses, uint256[] memory numSlots)
    external
    onlyOwner
    {
    require(
    addresses.length == numSlots.length,
    "addresses does not match numSlots length"
    );

    for (uint256 i = 0; i < addresses.length; i++) {
    _whitelist[addresses[i]] = numSlots[i];
    }
    }

    // set amount revealed 
    function setNumRevealed(uint256 amount) public onlyOwner{
        num_revealed = amount;
    }

// set amount whitelisted for user
    function setMaxMint(uint256 amount) public onlyOwner{
        current_mint_max = amount;
    }


    function whitelistMint(uint256 quantity) external payable checkWhitelist checkRequiredRoot(msg.sender){

        require(totalSupply() + quantity <= current_mint_max, "reached max current mint");

        require(msg.value >= thePrice * quantity, "Need to send more Value.");

        _safeMint(msg.sender, quantity);
        
    }

    function proxyWhitelistMint(uint256 quantity) external payable checkWhitelist checkRequiredRoot(msg.sender){
        
        require(totalSupply() + quantity <= current_mint_max, "reached max current mint");

        require(msg.value >= thePrice * quantity, "Need to send more Value.");

        _safeMint(msg.sender, quantity);
        
    }

    function publicMint(uint256 quantity) external payable checkRequiredRoot(msg.sender){
        require(!_whitelist_on,"whitelist is on");

        require(totalSupply() + quantity <= current_mint_max, "reached max current mint");

        require(msg.value >= thePrice * quantity, "Need to send more Value.");

        _safeMint(msg.sender, quantity);
        
    }


    function proxyPublicMint(uint256 quantity, address root) external payable {
        require(!_whitelist_on,"whitelist is on");
        
        checkRequiredProxy(root, msg.sender);

        require(totalSupply() + quantity <= current_mint_max, "reached max current mint");

        require(msg.value >= thePrice * quantity, "Need to send more Value.");

        _safeMint(msg.sender, quantity);
        
    }

    function proxyPublicMintToRoot(uint256 quantity, address root) external payable {
        require(!_whitelist_on,"whitelist is on");
        
        checkRequiredProxy(root, msg.sender);

        require(totalSupply() + quantity <= current_mint_max, "reached max current mint");

        require(msg.value >= thePrice * quantity, "Need to send more Value.");

        _safeMint(root, quantity);
        
    }


    function getNativePrice() public view returns(uint){
            return(thePrice);
    }
        
    function getAmmountMinted() public view returns(uint,uint){
            return(totalSupply(),current_mint_max);
    }

    function setPrice(uint256 price) public onlyOwner{
        thePrice = price; 
    }

    // // metadata URI
    string private _baseTokenURI;

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function withdrawMoney() external onlyOwner nonReentrant {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    function setOwnersExplicit(uint256 quantity) external onlyOwner nonReentrant {
        _setOwnersExplicit(quantity);
    }

    function numberMinted(address owner) public view returns (uint256) {
        return _numberMinted(owner);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
            require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
            // if the token is greater than the number revealed show the generic URI
            
            return _baseTokenURI;
    }


}