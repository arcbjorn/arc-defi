// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

interface AggregatorInterface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

contract FundMe {
    using SafeMathChainlink for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address public owner;

    constructor() public {
      owner = msg.sender;
    }

    function fund() public payable {
        // 50$
        uint256 minimumUSD = 50 * 10 * 18;

        require(getConversionRate(msg.value) >= minimumUSD, "More ETH is required!");

        addressToAmountFunded[msg.sender] += msg.value;
        // ETH - USD conversion date
    }

    function getVersion() public view returns (uint256) {
        AggregatorInterface priceFeed = AggregatorInterface(0x8ML534M345L54M52345234234);
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        AggregatorInterface priceFeed = AggregatorInterface(0x8ML534M345L54M52345234234);
        (,int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }

    // 10000000000
    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        uint256 ethAmount = getPrice();
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUSD;
    }

    modifier onlyOwner {
      require(msg.sender == owner);
      _;
    }

    function withdraw() payable onlyOwner public {
      require(msg.sender == owner);
      msg.sender.transfer(address(this).balance);
    }
}