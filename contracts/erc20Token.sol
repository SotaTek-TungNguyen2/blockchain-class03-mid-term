pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT
import "./erc20Interface.sol";

library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an account access to this role
   */
  function add(Role storage role, address account) internal {
    require(account != address(0));
    role.bearer[account] = true;
  }

  /**
   * @dev remove an account's access to this role
   */
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    role.bearer[account] = false;
  }

  /**
   * @dev check if an account has this role
   * @return bool
   */
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}

contract ERC20Token is IERC20 {
    using Roles for Roles.Role;

    mapping(address => uint256) private _balances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    address private admin;
    Roles.Role private minters;
    Roles.Role private burners;
    bool private _isPausing = false;

    /**
     * @dev Sets the values for {name} and {symbol}.
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _totalSupply = 0;
        _name = name_;
        _symbol = symbol_;
        admin = msg.sender;
        minters.add(msg.sender);
        burners.add(msg.sender);
    }

    /**Modifiers*/
    modifier isAdmin() {
        require(msg.sender == admin, "Only admin can execute this");
        _;
    }

    modifier isMinter() {
        require(minters.has(msg.sender), "Only minter can execute this");
        _;
    }

    modifier notPause() {
        require(!_isPausing, "Admin has pause all transfer activities from contract");
        _;
    }

    modifier isBurner() {
        require(burners.has(msg.sender), "Only burner can execute this");
        _;
    }
    
    /**Functions */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function isPausing() public view virtual returns (bool) {
        return _isPausing;
    }

    function changePausing() public virtual isAdmin returns (bool) {
        _isPausing = !_isPausing;
        return _isPausing;
    }

    function addMinter(address account) public virtual isAdmin returns (bool) {
        minters.add(account);
        return true;
    }

    function addBurner(address account) public virtual isAdmin returns (bool) {
        burners.add(account);
        return true;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override notPause returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function mint(uint256 amount) public virtual isMinter notPause returns (bool) {
         _mint(msg.sender, amount);
        return true;
    }

    function burn(uint256 amount) public virtual isBurner notPause returns (bool) {
         _burn(msg.sender, amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        require(_totalSupply + amount < 1000000000, "Tokens can not mint access capped at 1 billion supplies");
        _totalSupply += amount;
        _balances[account] += amount;
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;
    }
}