pragma solidity 0.4.19;

// ----------------------------------------------------------------------------
// Ledgit token contract
//
// Symbol : LDG
// Name : Ledgit Token
// Total supply : 1,500,000,000.000000000000000000
// Decimals : 18
//
// ----------------------------------------------------------------------------

import './BaseContracts/LDGMintableToken.sol';
import './BaseContracts/LDGBurnableToken.sol';
import './BaseContracts/LDGMigratableToken.sol';

contract LDGToken is LDGMintableToken, LDGBurnableToken, LDGMigratableToken {
    string public name;
    string public symbol;
    uint8 public decimals;

    function LDGToken() public {
        name = "Ledgit";
        symbol = "LDG";
        decimals = 18;

        totalSupply_ = 1500000000 * 10 ** uint(decimals);

        balances[owner] = totalSupply_;
        Transfer(address(0), owner, totalSupply_);
    }

    function() public payable {
        revert();
    }
}
