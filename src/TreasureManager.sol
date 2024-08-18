// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/ITreasureManager.sol";

contract  TreasureManager is Initializable, AccessControlUpgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable, ITreasureManager {
    using SafeERC20 for IERC20;
    address public constant ethAddress = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    address public treasureManager;
    address public withdrawManager;

    address[] public tokenWhiteList;

    mapping(address => uint256) public tokenBalances;
    mapping(address => mapping(address => uint256)) public userRewardAmounts;

    error IsZeroAddress();

    event DepositToken(
        address indexed tokenAddress,
        address indexed sender,
        uint256 amount
    );

    event WithdrawToken(
        address indexed tokenAddress,
        address sender,
        address withdrawAddress,
        uint256 amount
    );

    event GrantRewardTokenAmount(
        address indexed tokenAddress,
        address granter,
        uint256 amount
    );

    event WithdrawManagerUpdate(
        address indexed withdrawManager
    );


    modifier onlyTreasureManager() {
        require(msg.sender == address(treasureManager), "TreasureManager.onlyTreasureManager");
        _;
    }

    modifier onlyWithdrawManager() {
        require(msg.sender == address(withdrawManager), "TreasureManager.onlyWithdrawer");
        _;
    }


    constructor (){
        
    }

    function initializ(address _initialOwner, address _treasureManager, address _withdrawManager) public initializer {
        treasureManager = _treasureManager;
        withdrawManager = _withdrawManager;
        _transferOwnership(_initialOwner);
    }

    receive() external payable {
        DepositETH();
    }

    function DepositETH() public payable returns (bool){
        tokenBalances[ethAddress] += msg.value;
        emit DepositToken(
            ethAddress,
            msg.sender,
            msg.value
        );
        return true;
    }

    function DepositERC20(IERC20 tokenAddress, uint256 amount) external returns (bool){
        tokenAddress.safeTransferFrom(msg.sender, address(this), amount);
        tokenBalances[address(tokenAddress)] += amount;
        emit DepositToken(
            address(tokenAddress),
            msg.sender,
            amount
        );
        return true;
    }

    function WithdrawETH(address payable withdrawAddress, uint256 amount) external payable returns (bool){
        require(address(this).balance >= amount, "Insufficient ETH balance in contract");
        (bool success, ) = withdrawAddress.call{value: amount}("");
        if (!success) {
            return false;
        }
        tokenBalances[ethAddress] -= amount;
        emit WithdrawToken(
            ethAddress,
            msg.sender,
            withdrawAddress,
            amount
        );
        return true;
    }

    function WithdrawERC20(IERC20 tokenAddress,address withdrawAddress, uint256 amount) external returns (bool){
        require(tokenBalances[address(tokenAddress)] >= amount, "Insufficient token balance in contract");
        tokenAddress.safeTransfer(withdrawAddress, amount);
        tokenBalances[address(tokenAddress)] -= amount;
        emit WithdrawToken(
            address(tokenAddress),
            msg.sender,
            withdrawAddress,
            amount
        );
        return true;
    }

    // 奖励发放
    function grantReward(IERC20 tokenAddress, address granter, uint256 amount) external{
        require(address(tokenAddress) != address(0) && granter != address(0), "Invalid address");
        userRewardAmounts[granter][address(tokenAddress)] += amount;
        emit GrantRewardTokenAmount(address(tokenAddress), granter, amount);
    }

    // 用户cliam
    function cliamAllToken() external{
        for (uint256 i = 0; i < tokenWhiteList.length; i++) {
            address tokenAddress = tokenWhiteList[i];
            uint256 rewardAmount = userRewardAmounts[msg.sender][tokenAddress];
            if (rewardAmount > 0) {
                if (tokenAddress == ethAddress) {
                    (bool success, ) = msg.sender.call{value: rewardAmount}("");
                    require(success, "ETH transfer failed");
                } else {
                    IERC20(tokenAddress).safeTransfer(msg.sender, rewardAmount);
                }
                userRewardAmounts[msg.sender][tokenAddress] = 0;
                tokenBalances[tokenAddress] -= rewardAmount;
            }
        }
    }

    function cliamOneToken(address tokenAddress) external{
        require(tokenAddress != address(0), "Invalid token address");
        uint256 rewardAmount = userRewardAmounts[msg.sender][tokenAddress];
        require(rewardAmount > 0, "No reward available");
        if (tokenAddress == ethAddress) {
            (bool success, ) = msg.sender.call{value: rewardAmount}("");
            require(success, "ETH transfer failed");
        } else {
            IERC20(tokenAddress).safeTransfer(msg.sender, rewardAmount);
        }
        userRewardAmounts[msg.sender][tokenAddress] = 0;
        tokenBalances[tokenAddress] -= rewardAmount;
    }

    // 白名单的设置
    function setTokenWhiteList(address tokenAddress) external{
        if(tokenAddress == address(0)) {
            revert IsZeroAddress();
        }
        tokenWhiteList.push(tokenAddress);
    }

    function getTokenWhiteList() view external returns(address[] memory){
        return tokenWhiteList;
    }

    function queryReward(address _tokenAddress) external view returns (uint256){
        return userRewardAmounts[msg.sender][_tokenAddress];
    }

    function setWithdrawManager(address _withdrawManager) external{
        withdrawManager = _withdrawManager;
        emit WithdrawManagerUpdate(
            withdrawManager
        );
    }

}