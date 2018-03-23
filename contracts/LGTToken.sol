pragma solidity 0.4.19;

// ----------------------------------------------------------------------------
// Ledgit token contract
//
// Symbol : LGT
// Name : Ledgit Token
// Total supply : 1,500,000,000.000000000000000000
// Decimals : 18
//
// ----------------------------------------------------------------------------

import './BaseContracts/LGTMintableToken.sol';
import './BaseContracts/LGTBurnableToken.sol';
import './BaseContracts/LGTMigratableToken.sol';

contract SDAToken is SDAMintableToken, SDABurnableToken, SDAMigratableToken {
    string public name;
    string public symbol;
    uint8 public decimals;

    function SDAToken() public {
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
