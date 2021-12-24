pragma solidity ^0.5.0;

contract Utils {

    function stringToBytes32(string memory source)  internal pure  returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }

    function bytes32ToString(bytes32 x)  internal pure returns (string memory) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return  string(bytesStringTrimmed);
    }
}

contract CouponSys is Utils {


    address owner; //合约的拥有者，银行
    uint issuedScoreAmount; //银行已经发行的积分总数
    uint settledScoreAmount; //银行已经清算的积分总数

    struct Customer {
        address customerAddr; //客户address
        bytes32 password; //客户密码
        uint scoreAmount; //积分余额
        bytes32[] buyCoupons; //购买的优惠券数组
    }

    struct Merchant {
        address merchantAddr; //商户address
        bytes32 password; //商户密码
        uint scoreAmount; //积分余额
        bytes32[] sellCoupons; //发布的优惠券数组
    }

    struct Coupon {
        bytes32 couponId; //优惠券Id;
        uint price; //优惠券需要积分
        // uint discount; //优惠券折扣
        address belong; //优惠券属于哪个商户address；
        bool state; //优惠券是否已经使用
    }


    mapping(address => Customer) customer;
    mapping(address => Merchant) merchant;
    mapping(bytes32 => Coupon) coupon; //根据优惠券Id查找该件优惠券

    address[] customers; //已注册的客户数组
    address[] merchants; //已注册的商户数组
    bytes32[] coupons; //已经上线的优惠券数组

    //增加权限控制，某些方法只能由合约的创建者调用
    modifier onlyOwner(){
        if (msg.sender == owner) _;
    }

    //构造函数
    constructor() public {
        owner = msg.sender;
    }


    //返回合约调用者地址
    function getOwner() view public  returns (address) {
        return owner;
    }

    //注册一个客户
    event NewCustomer(address sender, bool isSuccess, string password);

    function newCustomer(address _customerAddr, string memory _password) public {
        //判断是否已经注册
        if (!isCustomerAlreadyRegister(_customerAddr)) {
            //还未注册
            customer[_customerAddr].customerAddr = _customerAddr;
            customer[_customerAddr].password = stringToBytes32(_password);
            customers.push(_customerAddr);
            emit NewCustomer(msg.sender, true, _password);
            return;
        }
        else {
            emit NewCustomer(msg.sender, false, _password);
            return;
        }
    }

    //注册一个商户
    event NewMerchant(address sender, bool isSuccess, string message);

    function newMerchant(address _merchantAddr,
        string memory _password) public {

        //判断是否已经注册
        if (!isMerchantAlreadyRegister(_merchantAddr)) {
            //还未注册
            merchant[_merchantAddr].merchantAddr = _merchantAddr;
            merchant[_merchantAddr].password = stringToBytes32(_password);
            merchants.push(_merchantAddr);
            emit NewMerchant(msg.sender, true, "注册成功");
            return;
        }
        else {
            emit NewMerchant(msg.sender, false, "该账户已经注册");
            return;
        }
    }

    //判断一个客户是否已经注册
    function isCustomerAlreadyRegister(address _customerAddr) internal view returns (bool)  {
        for (uint i = 0; i < customers.length; i++) {
            if (customers[i] == _customerAddr) {
                return true;
            }
        }
        return false;
    }

    //判断一个商户是否已经注册
    function isMerchantAlreadyRegister(address _merchantAddr) public view returns (bool) {
        for (uint i = 0; i < merchants.length; i++) {
            if (merchants[i] == _merchantAddr) {
                return true;
            }
        }
        return false;
    }

    //查询用户密码
    function getCustomerPassword(address _customerAddr) view public returns (bool, bytes32) {
        //先判断该用户是否注册
        if (isCustomerAlreadyRegister(_customerAddr)) {
            return (true, customer[_customerAddr].password);
        }
        else {
            return (false, "");
        }
    }

    //查询商户密码
    function getMerchantPassword(address _merchantAddr) view public returns (bool, bytes32) {
        //先判断该商户是否注册
        if (isMerchantAlreadyRegister(_merchantAddr)) {
            return (true, merchant[_merchantAddr].password);
        }
        else {
            return (false, "");
        }
    }

    //银行发送积分给客户,只能被银行调用，且只能发送给客户
    event SendScoreToCustomer(address sender, string message);

    function sendScoreToCustomer(address _receiver,
        uint _amount) onlyOwner public {

        if (isCustomerAlreadyRegister(_receiver)) {
            //已经注册
            issuedScoreAmount += _amount;
            customer[_receiver].scoreAmount += _amount;
            emit SendScoreToCustomer(msg.sender, "发行积分成功");
            return;
        }
        else {
            //还没注册
            emit SendScoreToCustomer(msg.sender, "该账户未注册，发行积分失败");
            return;
        }
    }

    //根据客户address查找余额
    function getScoreWithCustomerAddr(address customerAddr) view public returns (uint) {
        return customer[customerAddr].scoreAmount;
    }

    //根据商户address查找余额
    function getScoreWithMerchantAddr(address merchantAddr) view public returns (uint) {
        return merchant[merchantAddr].scoreAmount;
    }

    //两个账户转移积分，任意两个账户之间都可以转移，客户商户都调用该方法
    //_senderType表示调用者类型，0表示客户，1表示商户
    event TransferScoreToAnother(address sender, string message);

    function transferScoreToAnother(uint _senderType,
        address _sender,
        address _receiver,
        uint _amount) public {

        if (!isCustomerAlreadyRegister(_receiver) && !isMerchantAlreadyRegister(_receiver)) {
            //目的账户不存在
            emit TransferScoreToAnother(msg.sender, "目的账户不存在，请确认后再转移！");
            return;
        }
        if (_senderType == 0) {
            //客户转移
            if (customer[_sender].scoreAmount >= _amount) {
                customer[_sender].scoreAmount -= _amount;

                if (isCustomerAlreadyRegister(_receiver)) {
                    //目的地址是客户
                    customer[_receiver].scoreAmount += _amount;
                } else {
                    merchant[_receiver].scoreAmount += _amount;
                }
                emit TransferScoreToAnother(msg.sender, "积分转让成功！");
                return;
            } else {
                emit TransferScoreToAnother(msg.sender, "你的积分余额不足，转让失败！");
                return;
            }
        } else {
            //商户转移
            if (merchant[_sender].scoreAmount >= _amount) {
                merchant[_sender].scoreAmount -= _amount;
                if (isCustomerAlreadyRegister(_receiver)) {
                    //目的地址是客户
                    customer[_receiver].scoreAmount += _amount;
                } else {
                    merchant[_receiver].scoreAmount += _amount;
                }
                emit TransferScoreToAnother(msg.sender, "积分转让成功！");
                return;
            } else {
                emit TransferScoreToAnother(msg.sender, "你的积分余额不足，转让失败！");
                return;
            }
        }
    }

    //银行查找已经发行的积分总数
    function getIssuedScoreAmount() view public returns (uint) {
        return issuedScoreAmount;
    }

    //银行查找已经清算的积分总数
    function getSettledScoreAmount() view public returns (uint) {
        return settledScoreAmount;
    }

    //商户添加一件优惠券
    event AddCoupon(address sender, bool isSuccess, string message);

    function addCoupon(address _merchantAddr, string memory _couponId, uint _price) public {
        bytes32 tempId = stringToBytes32(_couponId);

        //首先判断该优惠券Id是否已经存在
        if (!isCouponAlreadyAdd(tempId)) {
            coupon[tempId].couponId = tempId;
            coupon[tempId].price = _price;
            coupon[tempId].belong = _merchantAddr;
            coupon[tempId].state = false;

            coupons.push(tempId);
            merchant[_merchantAddr].sellCoupons.push(tempId);
            emit AddCoupon(msg.sender, true, "创建优惠券成功");
            return;
        }
        else {
            emit AddCoupon(msg.sender, false, "该优惠券已经添加，请确认后操作");
            return;
        }
    }

    //商户查找自己的优惠券数组
    function getCouponsByMerchant(address _merchantAddr) view public returns (bytes32[] memory) {
        return merchant[_merchantAddr].sellCoupons;
    }

    //用户用积分兑换优惠券
    event BuyCoupon(address sender, bool isSuccess, string message);

    function buyCoupon(address _customerAddr, string memory _couponId) public {
        //首先判断输入的优惠券Id是否存在
        bytes32 tempId = stringToBytes32(_couponId);
        if (isCouponAlreadyAdd(tempId)) {
            //该优惠券已经添加，可以兑换
            if (customer[_customerAddr].scoreAmount < coupon[tempId].price) {
                emit BuyCoupon(msg.sender, false, "积分不足，兑换优惠券失败");
                return;
            }
            else {
                //对这里的方法抽取
                customer[_customerAddr].scoreAmount -= coupon[tempId].price;
                merchant[coupon[tempId].belong].scoreAmount += coupon[tempId].price;
                customer[_customerAddr].buyCoupons.push(tempId);
                emit BuyCoupon(msg.sender, true, "购买优惠券成功");
                return;
            }
        }
        else {
            //没有这个Id的优惠券
            emit BuyCoupon(msg.sender, false, "输入优惠券Id不存在，请确定后购买");
            return;
        }
    }

    //用户使用优惠券
    event UseCoupon(address sender, bool isSuccess, string message);

    function useCoupon(address _customerAddr, string memory _couponId) public {
        //首先判断输入的优惠券Id是否存在
        bytes32 tempId = stringToBytes32(_couponId);
        if (isCouponAlreadyAdd(tempId) && isCustomerHasTheCoupon(_customerAddr, tempId)) {
            //判断该优惠券是否已经使用
            if(coupon[tempId].state) {
                emit UseCoupon(msg.sender, false, "该优惠券已经使用，请勿重复使用");
            }else {
                //该优惠券已经添加，可以使用
                coupon[tempId].state = true;
                emit UseCoupon(msg.sender, true, "使用优惠券成功");
                return;
            }
        }
        else {
            //没有这个Id的优惠券
            emit UseCoupon(msg.sender, false, "该用户没有此优惠券");
            return;
        }
    }

    function isCustomerHasTheCoupon(address _customerAddr, bytes32 _couponId) internal view returns (bool) {
        uint len = customer[_customerAddr].buyCoupons.length;
        for (uint i = 0; i < len; i++) {
            if (customer[_customerAddr].buyCoupons[i] == _couponId) {
                return true;
            }
        }
        return false;
    }

    //客户查找自己的优惠券数组
    function getCouponsByCustomer(address _customerAddr) view public returns (bytes32[] memory) {
        return customer[_customerAddr].buyCoupons;
    }

    //首先判断输入的优惠券Id是否存在
    function isCouponAlreadyAdd(bytes32 _couponId) internal view returns (bool) {
        for (uint i = 0; i < coupons.length; i++) {
            if (coupons[i] == _couponId) {
                return true;
            }
        }
        return false;
    }

    //商户和银行清算积分
    event SettleScoreWithBank(address sender, string message);

    function settleScoreWithBank(address _merchantAddr, uint _amount) public {
        if (merchant[_merchantAddr].scoreAmount >= _amount) {
            merchant[_merchantAddr].scoreAmount -= _amount;
            settledScoreAmount += _amount;
            emit SettleScoreWithBank(msg.sender, "积分清算成功");
            return;
        }
        else {
            emit SettleScoreWithBank(msg.sender, "您的积分余额不足，清算失败");
            return;
        }
    }
}
