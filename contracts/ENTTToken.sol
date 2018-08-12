pragma solidity 0.4.19;

// ----------------------------------------------------------------------------
// Ledgit token contract
//
// Symbol : ENTT
// Name : Ledgit Token
// Total supply : 1,500,000,000.000000000000000000
// Decimals : 18
//
// ----------------------------------------------------------------------------

import './BaseContracts/ENTTMintableToken.sol';
import './BaseContracts/ENTTBurnableToken.sol';
import './BaseContracts/ENTTMigratableToken.sol';

contract ENTTToken is ENTTMintableToken, ENTTBurnableToken, ENTTMigratableToken {
    string public name;
    string public symbol;
    uint8 public decimals;

    function ENTTToken() public {
        name = "ENTT";
        symbol = "ENTT";
        decimals = 18;

        totalSupply_ = 3000000000 * 10 ** uint(decimals);

        balances[owner] = totalSupply_;
        Transfer(address(0), owner, totalSupply_);
    }

    function() public payable {
        revert();
    }
}
