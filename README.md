# Walify Contracts and interfaces

This repository contains the code useful for integrating Walify into other contracts

## Some Features include:

1. Walify Registry

2. Template NFT using walify

3. Easy import walify interface


## Integrate walify into your NFT contract:

Import IWalify.sol:
Place iWalify.sol in the directory of your NFT solidity file
Then import the file as follows:
`import  'iWalify.sol';`
This grants you access to all the functions that may be needed. 

## Using the nftWithWalify.sol contract
This NFT contract is a cutting edge, gas efficient, NFT + Minter contract. Inspired by erc721A. 

Walify integration is in checkRequiredProxy function.
``` 
function checkRequiredProxy(address  root, address  proxy) internal{

// verify proxy
IWALIFY walify_contract = IWALIFY(walify);

require(walify_contract.verify(root, proxy), "Walify did not verify. Root and proxy not associated");

// now check for balance off of the proxy

require(requiredContract.balanceOf(root) > 0, "You do not own required NFT");

}
```

**Note this** contract uses [OpenZeppelin](http://openzeppelin.com/) standard libraries 

