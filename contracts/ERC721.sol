// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTforSale is ERC721("blue", "BM") {
    function mint(address spender, uint tokenid) external {
        _safeMint(spender, tokenid);
    }
}
