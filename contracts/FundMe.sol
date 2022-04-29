//SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    using SafeMathChainlink for uint256;

    address public owner;
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    AggregatorV3Interface public priceFeed;

    // In this solidity version, you have to spcecify constructor's visibility.
    constructor(address _priceFeed) public {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function checkOldFunder(address thisFunder) internal view returns (bool) {
        for (uint256 i = 0; i < funders.length; i++) {
            if (funders[i] == thisFunder) {
                return false;
            }
        }
        return true;
    }

    function fund() public payable {
        require(msg.value >= dollarToWei(50), "you need to spend more ETH");
        addressToAmountFunded[msg.sender] += msg.value;
        if (checkOldFunder(msg.sender)) {
            funders.push(msg.sender);
        }
    }

    // check if user funds more than 50 dollars' ETH.
    // get how many dollars is $50.
    // Note that we don't use unit of ETH because it's too big.
    function dollarToWei(uint256 _dollars) public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        uint256 price = uint256(answer);
        uint256 decimals = uint256(priceFeed.decimals());
        uint256 weiPerDollar = (10**18 * 10**decimals) / price;
        return _dollars * weiPerDollar;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    function withdraw() public payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function checkBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function viewContractAddress() public view returns (address) {
        return address(this);
    }

    function viewDecimals() public view returns (uint8) {
        return priceFeed.decimals();
    }
}
