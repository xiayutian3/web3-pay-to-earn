// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

// 由于继承关系，将以下代码迁移至 userPay。sol中

// 平台模块

contract Platform {
    // 平台
    uint8 public fee = 5; //平台手续费(百分比)
    uint256 public adminBalance; //平台钱包

    event AdminWithdraw( address indexed to, uint time, uint amount );

    // //取款
    // function adminWithdraw() external onlyAdmin {
    //     payable(admin).transfer(adminBalance);

    //     emit AdminWithdraw(admin, block.timestamp, adminBalance);
    //     adminBalance = 0;
    // }
}