// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {Script, console2} from "forge-std/Script.sol";
import {TreasureManager} from "../src/TreasureManager.sol";

// forge script  ./script/TreasureManager.s.sol:TreasureManagerScript --rpc-url=$ETH_RPC_URL --private-key=$PRIVATE_KEY --broadcast -vvv

// forge script  ./script/TreasureManager.s.sol:TreasureManagerScript --rpc-url=http://127.0.0.1:8545 --private-key=$LOCAL_PRIVATE_KEY --broadcast -vvv

// 向合约中转账
// cast send --rpc-url=$ETH_RPC_URL --private-key=$PRIVATE_KEY 0x1AF40913c3AeC77b04a19066649c063E4d848D90 "DepositETH()" --value 0.001ether
// 调用合约的一个函数
// cast call --rpc-url=$ETH_RPC_URL --private-key=$PRIVATE_KEY 0x1AF40913c3AeC77b04a19066649c063E4d848D90 "tokenBalances(address)(uint256)" 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
// cast call --rpc-url=$ETH_RPC_URL --private-key=$PRIVATE_KEY 0x1AF40913c3AeC77b04a19066649c063E4d848D90 "getTokenWhiteList()"
// 调用一个合约函数，并写数据
// cast call --rpc-url=$ETH_RPC_URL --private-key=$PRIVATE_KEY 0x1AF40913c3AeC77b04a19066649c063E4d848D90 "setTokenWhiteList(address)" 0xea3eed8616877F5d3c4aEbf5A799F2e8D6DE9A5E

// cast call --rpc-url=$ETH_RPC_URL --private-key=$PRIVATE_KEY 0x1AF40913c3AeC77b04a19066649c063E4d848D90 "grantReward()"
contract TreasureManagerScript is Script {
    TreasureManager public treasureManager;
    ProxyAdmin public proxyAdmin;

    function setUp() public {}

    function run() public {
        // 获取环境变量中的参数
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // 将私钥转换为地址
        address deployerAddress = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);
        proxyAdmin = ProxyAdmin(deployerAddress);
        console2.log("proxyAdmin at:", address(proxyAdmin));

        treasureManager = new TreasureManager();

        TransparentUpgradeableProxy proxyTreasureManager = new TransparentUpgradeableProxy(
            address(treasureManager),
            address(proxyAdmin),
            abi.encodeWithSelector(TreasureManager.initializ.selector, deployerAddress, deployerAddress, deployerAddress)
        );

        console2.log("TransparentUpgradeableProxy at:", address(proxyTreasureManager));

        vm.stopBroadcast();
    }
}
