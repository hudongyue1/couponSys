// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <0.7.0;

contract Merchant{
    address account;
   
    address[] unusedCoupons;  //已发放未使用的优惠
    address[] usedCoupons;  //已使用的优惠券

    function Merchant(address merchantAccount){
        account = merchantAccount;
    }

    function makeCoupon(){

    }

    function dispenseCoupon(){

    }

    function deleteCounpon(){

    }
}
