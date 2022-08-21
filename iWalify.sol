// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/access/Ownable.sol';

interface iWalify{

    function register( address proxy_address) external;
    
    function registerWithProof( address proxy_address) external;

    function prooveProxy(address root) external;

    function verify(address root, address proxy) external returns(bool);

    function giveRoot(address proxy) external returns(address);

    function giveProxy(address root) external returns(address);


}

