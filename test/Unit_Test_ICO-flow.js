/**
 * @file ICO flow test case
 */

'use strict'

import { increaseTime, increaseTimeTo, duration } from './helpers/increaseTime';
import EVMRevert from './helpers/EVMRevert';
import EVMInvalidAddress from './helpers/EVMInvalidAddress';
import EVMThrow from './helpers/EVMThrow';

const LDGCrowdsale = artifacts.require("LDGCrowdsale");
const LDGToken = artifacts.require("LDGToken");
const EtherOraclizeService = artifacts.require("EtherOraclizeService");
const BigNumber = web3.BigNumber;

require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(BigNumber))
    .should();

let timeoutDuration = 0;
contract('LDGCrowdsale', function (accounts) {
    let currentTime = web3.eth.getBlock('latest').timestamp;
    let sInst;
    let sAddress;
    let acctOne = accounts[0];
    let acctTwo = accounts[1];
    let acctThree = accounts[2];
    let acctFour = accounts[3];
    let acctFive = accounts[4];
    let acctSix = accounts[5];
    let acctSeven = accounts[6];
    let acctEight = accounts[7];
    let execAcct = accounts[9];
    let sEthGoal = 1000000;
    let saleGoal = new BigNumber(web3.toWei(sEthGoal, 'ether'));
    let sEthCap = 2000000;
    let saleCap = new BigNumber(web3.toWei(sEthCap, 'ether'));
    let sStartTime;
    let sEndTime;
    let tenSec = 10;
    let thirtySec = 30;

    let twoEther = web3.toWei(2, 'ether');

    let oneMinute = 60;
    let oneHour = 60 * oneMinute;
    let oneDay = 24 * oneHour;
    let oneMonth = 30 * oneDay;

    // sendEther set to 20 ether is for fulfill minimum invest requirement
    let sendEther = web3.toWei(20, 'ether');

    let tokenInst;
    let oraclizeInst;

    it('UNIT TESTS - LDGCrowdsale - Test Case 01: LDGCrowdsale is deployed', async function () {
        currentTime = web3.eth.getBlock('latest').timestamp;
        sStartTime = currentTime + oneDay ;
        sEndTime = sStartTime + 2 * oneMonth;

        tokenInst = await LDGToken.new({from: acctFour});
        oraclizeInst = await EtherOraclizeService.new({from: acctFour, value: twoEther });

        sInst = await LDGCrowdsale.new(sStartTime, sEndTime, saleCap, acctEight, tokenInst.address, oraclizeInst.address, {from: acctOne});

        // Should not be null, if success deployed
        assert.isNotNull(sInst,
            '\n     ' +
            'UNIT TESTS - LDGCROWDSALE - TEST CASE 02: Test #1\n      ' +
            'TEST DESCRIPTION: LDGCrowsale not initialized\n      ' +
            'EXPECTED RESULT: not null\n      ' +
            'ACTUAL RESULT: is ' + sInst);
    }).timeout(timeoutDuration);

    it('UNIT TESTS - LDGCrowdsale - Test Case 02: Test buyTokens() before ICO start.', async function(){
        await sInst.setWhiteList(acctTwo, {from: acctOne});
        await sInst.buyTokens(acctTwo, {from: acctTwo, value: sendEther}).should.be.rejectedWith(EVMRevert);
    }).timeout(timeoutDuration);

    it('UNIT TESTS - LDGCrowdsale - Test Case 03: Test buyTokens() after ICO end.', async function(){
        let etherPrice;

        const eventBuyTokenCaseOne = sInst.LogTokenPurchase(function(error, result) {
            if (error) {
                console.error(error);
            }

            if (!error) {
                let logResult = result.args;
                assert.equal(sendEther, logResult._value.toNumber(),
                    '\n     ' +
                    'UNIT TESTS - LDGCROWDSALE - TEST CASE 10: Shoud Log 2 ether after purchase\n      ' +
                    'TEST DESCRIPTION: Buy Token is called\n      ' +
                    'EXPECTED RESULT: ' + sendEther + '\n      ' +
                    'ACTUAL RESULT: is ' + logResult._value.toNumber());
            }
        });

        // Just a trick to halt this test till valid etherPrice was set
        do {
            await sInst.getCurrentEtherPrice({from: acctTwo, value: web3.toWei(0.01, 'ether')});
            etherPrice = await sInst.etherPrice.call();
        } while (etherPrice.toNumber() == 0);

        // fast-forward after ICO started
        await increaseTimeTo(sStartTime + 2 * oneDay);
        await sInst.buyTokens(acctTwo, {from: acctTwo, value: sendEther}); // acctTwo already in whitelist

        eventBuyTokenCaseOne.stopWatching();

        // fast-forward after ICO ended
        await increaseTimeTo(sEndTime + oneDay);
        await sInst.buyTokens(acctTwo, {from: acctTwo, value: sendEther}).should.be.rejectedWith(EVMRevert);
    }).timeout(timeoutDuration);
});
