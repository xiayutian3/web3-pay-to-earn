// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

//推广者模块

contract Promoter {
    //取款事件
    event Withdraw( address indexed to, uint time, uint amount );

    // 推广者
    mapping(address => uint) public promoterBalance; //推广者的钱包
    mapping(address => uint[]) public promoterList; //推广者 =》 付费的订单编号


    // 取款函数
    function promoterWithdraw() external {
        require(promoterBalance[msg.sender] > 0);
        require(msg.sender != address(0));
        uint amount = promoterBalance[msg.sender];
        payable(msg.sender).transfer(amount);

        emit Withdraw(msg.sender,block.timestamp,amount);
        promoterBalance[msg.sender] = 0;

    }

}