// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <0.7.0;

contract Coupon{
    address counponCode;  //优惠券主键，唯一标识优惠券
    address owner;  //优惠券拥有者的和合约地址，刚发放优惠券时，对应为商户合约地址
    address granter;  //发行商户的和合约地址
    uint state;  //优惠券的状态（1为未使用，2已使用）
}
