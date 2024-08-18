// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITreasureManager {
    function DepositETH() external payable returns (bool);
    function DepositERC20(IERC20 tokenAddress, uint256 amount) external returns (bool);

    function WithdrawETH(address payable withdrawAddress, uint256 amount) external payable returns (bool);
    function WithdrawERC20(IERC20 tokenAddress,address withdrawAddress, uint256 amount) external returns (bool);

    // 奖励发放
    function grantReward(IERC20 tokenAddress, address granter, uint256 amount) external;
    // 用户cliam
    function cliamAllToken() external;
    function cliamOneToken(address tokenAddress) external;
    // 白名单的设置
    function setTokenWhiteList(address tokenAddress) external;
    function getTokenWhiteList() view external returns(address[] memory);
    function queryReward(address _tokenAddress) external view returns (uint256);

    function setWithdrawManager(address _withdrawManager) external;
}