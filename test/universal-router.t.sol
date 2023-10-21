// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {IUniversalRouter} from "src/IUniversalRouter.sol";
import {Commands} from "src/Commands.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CounterTest is Test {
    IUniversalRouter public universalRouter;
    IERC20 public WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 public USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    function setUp() public {
        universalRouter = IUniversalRouter(
            0xEf1c6E67703c7BD7107eed8303Fbe6EC2554BF6B
        );
    }

    function test_Execute() public {
        uint256 depositAmount = 1 ether;
        bytes memory _commands = abi.encodePacked(
            bytes1(uint8(Commands.WRAP_ETH)),
            bytes1(uint8(Commands.V3_SWAP_EXACT_IN))
        );
        bytes[] memory _inputs = new bytes[](2);
        _inputs[0] = abi.encode(address(universalRouter), depositAmount);
        _inputs[1] = abi.encode(
            address(this),
            depositAmount,
            0,
            abi.encodePacked(address(WETH), uint24(500), address(USDC)), // WETH -> USDC at 0.05% fee tier
            false
        );
        uint256 _deadline = block.timestamp + 300;
        vm.deal(address(this), depositAmount);
        universalRouter.execute{value: depositAmount}(
            _commands,
            _inputs,
            _deadline
        );
        assertEq(address(this).balance, 0);
        assertEq(WETH.balanceOf(address(this)), 0);
        console2.log(USDC.balanceOf(address(this)));
        assertGt(USDC.balanceOf(address(this)), 1000000000);
    }
}
