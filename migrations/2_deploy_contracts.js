var CouponSys = artifacts.require("./CouponSys.sol");
module.exports = function(deployer) {
  deployer.deploy(CouponSys);
};
