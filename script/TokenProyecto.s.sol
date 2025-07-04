// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {TokenProyecto} from "../src/TokenProyecto.sol";

contract TokenProyectoScript is Script {
    TokenProyecto public token;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        token = new TokenProyecto(0x08eDd01f987bEAF8E3F40EFe7b9851d123872B45, 0x08eDd01f987bEAF8E3F40EFe7b9851d123872B45);

        vm.stopBroadcast();
    }
}
