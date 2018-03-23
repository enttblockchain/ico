/// @file LDG Finalizable Crowdsale Contract
/// @notice LDG Finalizable Crowdsale Contract is based on Open Zeppelin
//// and extend LDG Base Crowdsale
pragma solidity 0.4.19;

import '../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import '../../node_modules/zeppelin-solidity/contracts/ownership/Claimable.sol';
import './LDGBaseCrowdsale.sol';

contract LDGFinalizableCrowdsale is LDGBaseCrowdsale, Claimable {
    using SafeMath for uint256;

    bool public isFinalized = false;

    event Closed();
    event Finalized();

    function LDGFinalizableCrowdsale() {
    }

    function finalize() onlyOwner public {
        require(!isFinalized);
        require(hasEnded());

        finalization();
        Finalized();

        isFinalized = true;
    }

    function close() onlyOwner internal {
        Closed();
        wallet.transfer(this.balance);
    }

    function finalization() internal {
        close();
    }
}
