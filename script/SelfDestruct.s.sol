// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

import {Script, console2} from "forge-std/Script.sol";
import {SelfDestruct} from "../src/SelfDestruct.sol";


/**
    forge script  ./script/SelfDestruct.s.sol --rpc-url=$ETH_RPC_URL
    cast call --rpc-url=$ETH_RPC_URL 0x1AF40913c3AeC77b04a19066649c063E4d848D90 "owner()"

    forge clean && forge build
    forge script  ./script/SelfDestruct.s.sol --rpc-url=127.0.0.1:8545  --broadcast -vvv
    cast send --rpc-url=127.0.0.1:8545 0x5FC8d32690cc91D4c39d9d3abcBD16989F875707 "setIsActive()"
 */
contract SelfDestructScript is Script {
    SelfDestruct public selfDestruct;
    ProxyAdmin public proxyAdmin;

    function setUp() public {
    }

    function run() public {
        // 获取环境变量中的参数
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // 将私钥转换为地址
        address deployerAddress = vm.addr(deployerPrivateKey);
        
        vm.startBroadcast(deployerPrivateKey);
        proxyAdmin = ProxyAdmin(deployerAddress);
        console2.log("deployer admin", address(proxyAdmin));

        selfDestruct = new SelfDestruct();

        TransparentUpgradeableProxy proxySelfDestruct = new TransparentUpgradeableProxy(
            address(selfDestruct),
            address(proxyAdmin),
            bytes("")        
        );
        console2.log("deployer at", address(proxySelfDestruct));
        vm.stopBroadcast();
    }
}
 
