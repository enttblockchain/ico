const ENTTCrowdsale = artifacts.require('ENTTCrowdsale');

var web3 = require('web3');

// let tokenAddress = '0x6b4d0e23a8b11db711be36ff5ecfe68af288f84f';
let tokenAddress = '0x614348d080835adcbbdee121af077024e27eccc6';

let wallet = '0xB4b1f433a796d82b3d5e1b10c94262e1a30f1BCb';
let etherPrice = 770; // usd

module.exports = async function(deployer, network, accounts) {
    const owner = accounts[0];
    let startTime = 1525492800;
    // let startTime = 1525455935 + 500;

    // const endTime = startTime + (86400 * 10);
    const endTime = 1533657599;

    const goal = web3.utils.toWei("350000000", 'ether');

    return deployer.deploy(ENTTCrowdsale, startTime, endTime, goal, etherPrice, wallet, tokenAddress, {from: owner});
    console.log('Deployed ENTTCrowdsale with address', ENTTCrowdsale.address);

    // await web3.eth.getBlock('latest', async function(err, result) {
    //     if (!err) {
    //         startTime = result.timestamp + 1200;
    //
    //         console.log("Starting Time: " + startTime);
    //
    //
    //     }
    // });
};
