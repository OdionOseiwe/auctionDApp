// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC721 {
    function transferFrom(
        address from,
        address to,
        uint256 nftid
    ) external;
}

contract Auction {
    IERC721 nft;
    uint nftID;
    address seller;
    uint PeriodOfAuction;
    bool start;
    bool end;
    address public highestBider;
    uint public highestBid;

    mapping(address => uint) public bids;

    /// @dev error messages

    /// not seller
    error OnlySeller();

    /// in section
    error Insection();

    /// finished auction
    error FinishedAuction();

    /// seller cant bid
    error sellerNtallowed();

    /// you are currently the highest bidder
    error CurrentHighestbidder();

    /// @dev events
    event started(address seller, uint timePeriod);
    event bidded(address indexed bidder, uint amount);
    event winner(address winner);
    event withdrawed(address bidder, uint amount);

    constructor(address nftAddress, uint _nftid) {
        seller = payable(msg.sender);
        nft = IERC721(nftAddress);
        nftID = _nftid;
    }

    function startAuction() external payable {
        if (msg.sender != seller) {
            revert OnlySeller();
        }
        PeriodOfAuction = block.timestamp + 1 minutes;
        if (start == true) {
            revert Insection();
        }
        if (end == true) {
            revert FinishedAuction();
        }
        start = true;
        highestBid = msg.value;
        nft.transferFrom(msg.sender, address(this), nftID);
        emit started(msg.sender, PeriodOfAuction);
    }

    function bid() external payable {
        if (msg.sender == seller) {
            revert sellerNtallowed();
        }
        require(block.timestamp <= PeriodOfAuction, "not in section");
        require(msg.value > highestBid, "bid higher");
        highestBid = msg.value;
        highestBider = msg.sender;
        bids[msg.sender] += msg.value;

        emit bidded(msg.sender, msg.value);
    }

    function withdraw() external {
        uint bidderBal = bids[msg.sender];
        if (msg.sender == highestBider) {
            revert CurrentHighestbidder();
        }
        bids[msg.sender] = 0;
        (bool sent, ) = msg.sender.call{value: bidderBal}("");
        require(sent, "failed");

        emit withdrawed(msg.sender, bidderBal);
    }

    function returnWinner() external {
        require(block.timestamp >= PeriodOfAuction, "not in section");
        if (msg.sender != seller) {
            revert OnlySeller();
        }
        if (end == true) {
            revert FinishedAuction();
        }
        if (highestBider != address(0)) {
            nft.transferFrom(address(this), highestBider, nftID);
        } else {
            nft.transferFrom(address(this), seller, nftID);
        }
        end = true;
        (bool sent, ) = seller.call{value: highestBid}("");
        require(sent, "failed");

        emit winner(highestBider);
    }

    function ContractBal() external view returns (uint) {
        return address(this).balance;
    }

    receive() external payable {}
}
