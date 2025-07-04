// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.13;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract TokenProyecto is ERC20, ERC20Burnable, ERC20Pausable, AccessControl, ERC20Permit {
    uint256 public constant CAP = 1_000_000 * 10**18;
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    error ERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestDecrease);

    constructor(address pauser, address minter)
        ERC20("TokenProyecto", "TKP")
        ERC20Permit("TokenProyecto")
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, pauser);
        _grantRole(MINTER_ROLE, minter);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        require(totalSupply() + amount <= CAP, "CAP exceeded");
        _mint(to, amount);
    }

    function increaseAllowance(address spender, uint256 addValue) public returns(bool) {
        uint256 currentAllowance = allowance(msg.sender, spender);
        return approve(spender, currentAllowance + addValue);
    }

    function decreaseAllowance(address spender, uint256 subtractValue) public returns(bool) {
        uint256 currentAllowance = allowance(msg.sender, spender);
        if (currentAllowance < subtractValue) {
            revert ERC20FailedDecreaseAllowance(spender, currentAllowance, subtractValue);
        }
        unchecked {
            return approve(spender, currentAllowance - subtractValue);
        }
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
    }
}
