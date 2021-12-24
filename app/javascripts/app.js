// Import the page's CSS. Webpack will know what to do with it.
import '../stylesheets/app.css'

const customer = require('./customer')
const bank = require('./bank')
const merchant = require('./merchant')
// Import libraries we need.
import { default as Web3 } from 'web3'
import { default as contract } from 'truffle-contract'

// Import our contract artifacts and turn them into usable abstractions.
import ScoreArtifacts from '../../build/contracts/CouponSys'

// MetaCoin is our usable abstraction, which we'll use through the code below.
let ScoreContract = contract(ScoreArtifacts)
let ScoreInstance
// The following code is simple to show off interacting with your contracts.
// As your needs grow you will likely need to change its form and structure.
// For application bootstrapping, check out window.addEventListener below.
let accounts
let account

window.App = {
  // 获得合约实例
  init: function () {
    // 设置web3连接
    ScoreContract.setProvider(window.web3.currentProvider)
    // Get the initial account balance so it can be displayed.
    window.web3.eth.getAccounts(function (err, accs) {
      if (err != null) {
        window.App.setStatus('There was an error fetching your accounts.')
        return
      }

      if (accs.length === 0) {
        window.App.setStatus('Couldn\'t get any accounts! Make sure your Ethereum client is configured correctly.')
        return
      }
      accounts = accs
      account = accounts[0]
    })

    ScoreContract.deployed().then(function (instance) {
      ScoreInstance = instance
    }).catch(function (e) {
      console.log(e, null)
    })
  },
  // 创建用户
  newCustomer: function () {
    customer.newCustomer(ScoreInstance, account)
  },
  // 用户登录
  customerLogin: function () {
    customer.customerLogin(ScoreInstance, account)
  },
  // 当前用户信息
  getCurrentCustomer: function (currentAccount) {
    customer.showCurrentAccount(currentAccount)
  },
  // 当前用户积分余额
  getScoreWithCustomerAddr: function (currentAccount) {
    customer.getScoreWithCustomerAddr(currentAccount, ScoreInstance, account)
  },
  // 用户购买优惠券
  buyCoupon: function (currentAccount) {
    customer.buyCoupon(currentAccount, ScoreInstance, account)
  },
  // // 用户使用优惠券
  useCoupon: function (currentAccount) {
    customer.useCoupon(currentAccount, ScoreInstance, account)
  },
  // 查看已经兑换的优惠券
  getCouponsByCustomer: function (currentAccount) {
    customer.getCouponsByCustomer(currentAccount, ScoreInstance, account)
  },
  // 用户转让积分
  transferScoreToAnotherFromCustomer: function (currentAccount) {
    customer.transferScoreToAnotherFromCustomer(currentAccount, ScoreInstance, account)
  },
  // 商家注册
  newMerchant: function () {
    merchant.newMerchant(ScoreInstance, account)
  },
  // 商家登录
  merchantLogin: function () {
    merchant.merchantLogin(ScoreInstance, account)
  },
  // 当前商家账户
  getCurrentMerchant: function (currentAccount) {
    merchant.getCurrentMerchant(currentAccount)
  },
  // 当前商家余额
  getScoreWithMerchantAddr: function (currentAccount) {
    merchant.getScoreWithMerchantAddr(currentAccount, ScoreInstance, account)
  },
  // 商家积分转让
  transferScoreToAnotherFromMerchant: function (currentAccount) {
    merchant.transferScoreToAnotherFromMerchant(currentAccount, ScoreInstance, account)
  },
  // 商家添加优惠券
  addCoupon: function (currentAccount) {
    merchant.addCoupon(currentAccount, ScoreInstance, account)
  },
  // 显示商家的所有优惠券
  getCouponsByMerchant: function (currentAccount) {
    merchant.getCouponsByMerchant(currentAccount, ScoreInstance, account)
  },
  // 商家清算积分
  settleScoreWithBank: function (currentAccount) {
    merchant.settleScoreWithBank(currentAccount, ScoreInstance, account)
  },
  // 发行积分
  sendScoreToCustomer: function () {
    bank.sendScoreToCustomer(ScoreInstance, account)
  },
  // 银行登录
  bankLogin: function () {
    bank.bankLogin(ScoreInstance, account)
  },
  // 查看已经发行的积分
  getIssuedScoreAmount: function () {
    bank.getIssuedScoreAmount(ScoreInstance, account)
  },
  // 已经清算积分总数目
  getSettledScoreAmount: function () {
    bank.getSettledScoreAmount(ScoreInstance, account)
  },
  // 查询所有的区块链账户
  allAccounts: function () {
    let allAccount = ''
    window.web3.eth.accounts.forEach(e => {
      allAccount += e + '\n'
    })
    window.App.setConsole(allAccount)
  },
  // 状态栏显示
  setStatus: function (message) {
    const status = document.getElementById('status')
    status.innerHTML = message
  },
  // 显示console
  setConsole: function (message) {
    const status = document.getElementById('console')
    status.innerHTML = message
  }
}

window.addEventListener('load', function () {
  // 设置web3连接 http://127.0.0.1:8545
  window.web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:8545'))
  window.App.init()
})
