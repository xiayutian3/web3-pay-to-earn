// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

// 用户模块

import "hardhat/console.sol";
import "./author.sol";
import "./promoter.sol";
import "./platforn.sol";

contract UserPay is Author,Promoter, Platform {
    //用户
    uint256 public orderID = 1; //订单id
    mapping(uint => payInfo) public userPayInfo; //通过订单编号进行查询用户的付费情况
    mapping(address => uint[]) public userOrders; //用户查询它的订单

    struct payInfo {
        uint payTime; //支付时间
        uint payCash; //支付金额
        uint articleID; //文章id
        bool status; //支付状态
        address user; //支付人地址
    }

    // // 作者
    // mapping(uint => uint) public authorBalance; //作者id =》作者钱包
    // mapping(uint => uint[]) public authorFansPay;  // 作者id =》 订单ID

    // // 推广者
    // mapping(address => uint) public promoterBalance; //推广者的钱包
    // mapping(address => uint[]) public promoterList; //推广者 =》 付费的订单编号

    // // 平台
    // uint8 private fee = 5; //平台手续费(百分比)
    // uint256 public adminBalance; //平台钱包


    // 设置管理员
    constructor(address _admin) Author(_admin) {
         admin = _admin;
    }


    // 支付文章费用
    function payForArticle(uint _arid, address _promoter) external payable {
        //用户的需求： 1.付了费能否阅读  2.记录
        //  1000000000000000000 1000000000000000000
        // 98 999 99999 99969 76357 1000 00000 00000 00000 1 000 00000 00000 00000
        console.log("paycash:", msg.sender.balance, msg.value,articleInfo[_arid].payCash);

        uint remainEther = msg.value;
        require(msg.sender.balance >= msg.value,"you dont have much more ether");
        require(remainEther >= articleInfo[_arid].payCash,"you need pay ether more to read");
        require(articleInfo[_arid].status, "this article have been block");
        require(msg.sender != address(0));
        userPayInfo[orderID] = payInfo(block.timestamp,msg.value,_arid,true,msg.sender);
        userOrders[msg.sender].push(_arid);

        // 推广者： 1.知道谁付了钱 2.付了多少钱 3.我分了多少钱
        if(_promoter != address(0)){
            uint rewardPercent = articleInfo[_arid].rewardPercent;
            uint promoterReward = rewardPercent*msg.value / 100;
            remainEther -= promoterReward;
            promoterBalance[_promoter] += promoterReward;
            promoterList[_promoter].push(orderID);
        }

        // 平台需求： 手续费
        uint rewardAdmin = fee * msg.value / 100;
        adminBalance += rewardAdmin;
        remainEther -= rewardAdmin;


        // 作者需求： 1.谁付了钱 2.我分了多少钱 3.哪篇文章 4.推广者
        uint aid = articleBelongAuthor[_arid];
        authorFansPay[aid].push(orderID);
        authorBalance[aid] += remainEther;


        orderID++;

    }


    //取款（平台方）
    function adminWithdraw() external onlyAdmin {
        payable(admin).transfer(adminBalance);

        emit AdminWithdraw(admin, block.timestamp, adminBalance);
        adminBalance = 0;
    }

    // 设置佣金的变化
    function setFee(uint8 _fee) public onlyAdmin {
        fee = _fee;
    }


}