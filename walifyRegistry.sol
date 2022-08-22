// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/access/Ownable.sol';

contract rootProxyRegistryAdvanced is Ownable{

mapping (address => address) public proxy_to_root;

mapping (address => address) public root_to_proxy;

mapping (address => address) public root_to_proxy_proofs;

uint256 public registration_fee = 100;

event Register(address root, address proxy);

event Proved(address root,address proxy);

    function register(address proxy_address) public payable{

        require(registration_fee <= msg.value, "not enough value");

        require(proxy_to_root[proxy_address] == 0x0000000000000000000000000000000000000000, "proxy already registered");

        proxy_to_root[proxy_address] = msg.sender;
        // todo clear previous proxy_to_root
        root_to_proxy[msg.sender] = proxy_address; 

        emit Register(msg.sender, proxy_address);

    }

    function registerWithProof( address proxy_address) public payable{

        require(registration_fee <= msg.value, "not enough value");

        require(root_to_proxy_proofs[msg.sender] == proxy_address, "proof invalid");

        proxy_to_root[proxy_address] = msg.sender;

        root_to_proxy[msg.sender] = proxy_address; 

         emit Register(msg.sender, proxy_address);

    }

    function prooveProxy(address root) public{
        root_to_proxy_proofs[root] = msg.sender;

        emit Proved(root, msg.sender);
    }


    function verify(address root, address proxy) public view returns(bool) {

        return proxy_to_root[proxy] == root;

    }

    function giveRoot(address proxy) public view returns(address) {

        return proxy_to_root[proxy];

    }

    function giveProxy(address root) public view returns(address) {

        return root_to_proxy[root];

    }

    function setFee(uint256 fee) public onlyOwner(){

        registration_fee = fee;

    }




}

