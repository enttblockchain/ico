// const LDGCrowdsale = artifacts.require('LDGCrowdsale');
// const EtherOraclizeService = artifacts.require('EtherOraclizeService');
const ENTTToken = artifacts.require('ENTTToken');

var web3 = require('web3');

// let oneEther = web3.utils.toWei("1", 'ether');

// let startTime = Math.round(new Date().getTime()/1000.0) + 2400;

module.exports = function(deployer, network, accounts) {
    const owner = accounts[0];

    // let startTime = web3.eth.getBlock('latest').timestamp + 1200;

    // let startTime = "1524855464";

    // const endTime = startTime + (86400 * 10);
    // const endTime = "1525719464"
    // const wallet = accounts[2];
    // const goal = web3.utils.toWei("300000000", 'ether');

    // if (startTime !== undefined) {
        deployer.deploy([
            // [EtherOraclizeService, {from: owner, value: oneEther}],
            [ENTTToken, {from: owner}]
        ]).then(function() {
          // console.log('Deployed EtherOraclizeService with address', EtherOraclizeService.address);
          console.log('Deployed ENTTToken with address', ENTTToken.address);
            // return deployer.deploy(SDACrowdsale, startTime, endTime, goal, wallet, SDAToken.address, EtherOraclizeService.address, {from: owner});
        });
        // .then(() => {
        //     console.log('Deployed EtherOraclizeService with address', EtherOraclizeService.address);
        //     console.log('Deployed SDAToken with address', SDAToken.address);
        //     console.log('Deployed SDACrowdsale with address', SDACrowdsale.address);
        // });
    // } else {
    //     console.log('startTime is ' + startTime);
    // }
};
