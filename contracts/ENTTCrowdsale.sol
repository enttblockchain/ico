/// @file ENTT Crowdsale Contract
pragma solidity 0.4.19;

import '../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';

import './BaseContracts/ENTTCappedCrowdsale.sol';
import './BaseContracts/ENTTFinalizableCrowdsale.sol';
import './ENTTToken.sol';

contract ENTTCrowdsale is ENTTCappedCrowdsale, ENTTFinalizableCrowdsale {
    using SafeMath for uint256;

    ENTTToken public tokens;
    uint8 public constant SERVICE_FEE = 2;
    uint8 public constant DECIMAL = 18;
    uint256 public etherPrice;
    uint256 public minUSD = 100 * 10 ** 18;
    uint256 public maxUSD = 100000000000 * 10 ** 18;
    uint256 public distributeTokenCountComplete;

    struct Phase {
        uint256 firstDay;
        uint256 endDay;
        uint256 tokenPrice;
        uint256 tokenCap;
    }

    struct InvestorStruct {
        bool approve;
        uint256 enttToken;
    }

    mapping(address => InvestorStruct) private Investor; // Manages the mapping between address
    mapping(uint => Phase) public Tier; // Manages the mapping between address
    address[] whitelists; // Manages the list of addresses

    event LogEtherToToken(uint tokenAmount);
    event LogWhiteList(address whitelisted);
    event LogAddressMigration(address oldAddress, address newAddress, uint256 newLdgToken);

    /**
     * Only allowed whitelisted investor
     */
    modifier onlyWhiteList(address _user) {
        require(Investor[_user].approve);
        _;
    }

    function ENTTCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _cap, uint256 _etherPrice, address _wallet, address _token) public payable
    ENTTBaseCrowdsale(_startTime, _endTime, _wallet)
    ENTTFinalizableCrowdsale()
    ENTTCappedCrowdsale(_cap)
    {
        require(_token != address(0x0));

        tokens = ENTTToken(_token);

        etherPrice = _etherPrice * 100;

        Tier[1].firstDay = _startTime; // may 5
        /* Tier[1].firstDay = 1525492800; // may 5 */
        Tier[1].endDay = 1528214399; // until june 6
        //Tier[1].endDay = _startTime + 10 minutes;
        Tier[1].tokenPrice = 5;
        Tier[1].tokenCap = 50000000 * 10 ** 18;

        Tier[2].firstDay = 1528214400;
        Tier[2].endDay = 1530892799; // july 7
        //Tier[2].endDay = Tier[1].endDay + 5 minutes;
        Tier[2].tokenPrice = 7;
        Tier[2].tokenCap = 100000000 * 10 ** 18;

        Tier[3].firstDay = 1530892800;
        Tier[3].endDay = 1533657599; // August 8
        //Tier[3].endDay = Tier[2].endDay + 5 minutes;
        Tier[3].tokenPrice = 9;
        Tier[3].tokenCap = 200000000 * 10 ** 18;

    }

    function buyTokens(address _investor) public payable onlyWhiteList(_investor) {
        require(!isFinalized);
        require(_investor != address(0x0));

        uint tier;
        uint256 investorENTTtoken;
        uint256 investorUSD;
        uint256 withinFirstDay;

        tier = getCurrentTier();

        require(tier > 0);
        require(etherPrice > 0);

        investorENTTtoken = calculatePrice(msg.value, etherPrice, SERVICE_FEE, Tier[tier].tokenPrice, DECIMAL);
        investorUSD = etherToUSD(msg.value, etherPrice, DECIMAL);

        require(investorENTTtoken > 0);
        require(investorUSD > 0);


        require(investorUSD > minUSD);

        require(validPurchase(investorENTTtoken, Tier[tier].tokenCap));

        // update token raised state
        tokenRaised = tokenRaised.add(investorENTTtoken);

        // Get "Total Supply" token investedEther, and minus the remainning token value
        Investor[_investor].enttToken += investorENTTtoken;

        LogTokenPurchase(txCount, 0x0, _investor, msg.value, investorENTTtoken, Tier[tier].tokenPrice);

        forwardFunds();

        txCount++;
    }

    function getWhiteListCount() public view returns(uint) {
        return whitelists.length;
    }

    function  getwhiteListByIndex(uint _index) public view returns (address, bool, uint256) {
        require(_index < whitelists.length);

        address addr = whitelists[_index];
        LogWhiteList(addr);
        return (addr, Investor[addr].approve, Investor[addr].enttToken);
    }

    function setWhiteList(address _investor) public onlyOwner returns (bool) {
        require(_investor != address(0x0));

        if (!Investor[_investor].approve) {
            Investor[_investor].approve = true;
            whitelists.push(_investor);
            return true;
        }
        return false;
    }

    function setEtherPrice(uint256 _etherPrice) public onlyOwner {
      etherPrice = _etherPrice * 100;
    }

    /**
     * ENTTPricing#calculatePrice
     *
     * When somebody tries to buy tokens for X eth, calculate how many tokens they get.
     *
     * @param _value - What is the value of the transaction send in as wei
     * @param _curEtherPriceInUSD - current Ether price in USD
     * @param _serviceFee - service fee to charge
     * @param _tokenSalePrice - token price in USD
     * @param _decimals - how many decimal units the token has
     * @return Amount of tokens the investor receives
     */
    function calculatePrice(uint _value, uint _curEtherPriceInUSD, uint _serviceFee, uint _tokenSalePrice, uint _decimals)
      returns (uint)
    {
        require(_value > 0);
        require(_curEtherPriceInUSD > 0);
        require(_serviceFee > 0);
        require(_tokenSalePrice > 0);
        require(_decimals > 0);

        uint multipliers = 10 ** _decimals;
        uint serviceFee = (1 * multipliers) - ((_serviceFee * multipliers) / 100);
        uint tokenSalePrice = (_tokenSalePrice * multipliers) / 100;
        uint curEtherPriceInUSD = (_curEtherPriceInUSD * multipliers) / 100;
        uint token = (_value * (curEtherPriceInUSD) * (serviceFee) / (tokenSalePrice)).div(1 ether);

        LogEtherToToken(token);
        return token;
    }

    /**
     *
     * Calculate how many USD investor have invest.
     *
     * @param _value - What is the value of the transaction send in as wei
     * @param _curEtherPriceInUSD - current Ether price in USD
     * @return Total of USD the investor invest
     */
    function etherToUSD(uint _value, uint _curEtherPriceInUSD, uint _decimals) returns(uint) {
        require(_value > 0);
        require(_curEtherPriceInUSD > 0);

        uint multipliers = 10 ** _decimals;
        uint curEtherPriceInUSD = (_curEtherPriceInUSD * multipliers) / 100;
        uint totalUSD = (_value * curEtherPriceInUSD).div(1 ether);

        return totalUSD;
    }

    /**
     * @notice Get current tier's ending time
     *
     * @return Tier's ending time
     */
    function getTierEndtime() public view returns(uint, uint, uint) {
        return (Tier[1].endDay, Tier[2].endDay, Tier[3].endDay);
    }

    /**
     * @notice To change the Crowdsale's ending timestamp
     */
    function setEndTime(uint256 _endTime) public onlyOwner {
        require(_endTime > startTime && _endTime > now);

        endTime = _endTime;
    }

    /**
     * @notice Get current tier
     *
     * @return Current Tier
     */
    function getCurrentTier() internal view returns(uint) {
        if (Tier[1].endDay > now) {
            return 1;
        } else if (Tier[2].endDay > now) {
            return 2;
        } else if (Tier[3].endDay > now) {
            return 3;
        } else {
            return 0;
        }
    }

    function isWhitelisted(address _sender) public view returns(string, uint256) {
        if (Investor[_sender].approve) {
          return ("Yes", Investor[_sender].enttToken);
        } else {
          return ("No", 0);
        }
    }

    /**
     * @notice Migrate wallet address of whitelist
     */
    function addressMigrations(address _oldWallet, address _newWallet)
        public
        onlyOwner
        onlyWhiteList(_oldWallet)
    {
        require(_newWallet != address(0));
        require(Investor[_newWallet].enttToken == 0);

        Investor[_newWallet].approve = Investor[_oldWallet].approve;
        Investor[_newWallet].enttToken = Investor[_oldWallet].enttToken;

        whitelists.push(_newWallet);

        delete Investor[_oldWallet];
        LogAddressMigration(_oldWallet, _newWallet, Investor[_newWallet].enttToken);
    }

    /**
     * @notice Release token to investor after ICO was finalized.
     */
    function distributesToken(uint256 count)
        public
        onlyOwner
        onlyWhiteList(_to)
    {
        require(isFinalized);
        require(count > 0);

        count = distributeTokenCountComplete + count;

        if (count > whitelists.length) {
            count = whitelists.length;
        }

        address _to;
        for (uint256 index = distributeTokenCountComplete; index < count; index++) {
            _to = whitelists[index];
            if (Investor[_to].approve == true) {
                tokens.transferFrom(owner, _to, Investor[_to].enttToken);
                Investor[_to].enttToken = 0;
            }
        }

        distributeTokenCountComplete = count;
    }

    function () external payable {
        require(msg.data.length == 0);

        if (msg.sender != owner) {
          buyTokens(msg.sender);
        }
    }
}
