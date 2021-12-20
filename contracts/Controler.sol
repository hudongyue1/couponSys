// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <0.7.0;

contract Controler{
    address account; //存储管理中心的公钥
    address[] consumers; //记录所有的用户
    address[] merchants; //记录所有的商户

    function Controler(){
        account = 0x0fC833DEAebdC46191D655c3aaE8F7A3b49ADdb3;// 默认count0
    }

    function createConsumer(address consumerAccount) public {
        consumers.push(new Consumer(consumerAccount)); //传入用户公钥，创建并部署用户
    }

    function createMerchant(address merchantAccount) public {
	    merchants.push(new Merchant(merchantAccount));  //传入商户公钥，创建并部署商户合约
    }
    
}