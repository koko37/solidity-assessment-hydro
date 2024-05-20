abstract contract RateLimited {
    address private owner;
    uint256 private period;
    mapping (address => uint256) private lastCalled;

    constructor(address _owner, uint256 _period) {
        require(_owner != address(0), "invalid owner");
        require(_period > 0, "invalid period");
        owner = _owner;
        period = _period;
    }

    modifier rateLimited() {
        require(block.timestamp - lastCalled[msg.sender] >= period, "rate limited");
        updateLastCalled();
        _;
    }

    function updateLastCalled() private{
        lastCalled[msg.sender] = block.timestamp;
    }

    // admin functions
    function updatePeriod(uint256 _period) external {
        require(msg.sender == owner, "invalid owner");
        require(_period > 0, "invalid period");

        period = _period;
    }

    function updateOwner(address _owner) external {
        require(msg.sender == owner, "invalid owner");
        require(_owner != address(0), "invalid new owner");

        owner = _owner;
    }
}

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceFeed is RateLimited {
    AggregatorV3Interface internal priceFeed;
    uint256 public price;

    constructor(address _owner, uint256 _period, address _priceFeed) RateLimited(_owner, _period) {
        require(_priceFeed != address(0), "invalid asset");
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function updatePrice() rateLimited() {
        (
            /* uint80 roundID */,
            price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
    }
}
