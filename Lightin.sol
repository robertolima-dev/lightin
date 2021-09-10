// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

library SafeMath {

    // Funções pure não consultam e nem alteram, só tratam parametros
    function add(uint a, uint b) internal pure returns(uint) {
        uint c = a + b; 
        require(c >= a, "Sum Overflow!");

        return c;
    }

    function sub(uint a, uint b) internal pure returns(uint) {
        require(b <= a, "Sub Underflow!");
        uint c = a - b; 

        return c;
    }

    function mult(uint a, uint b) internal pure returns(uint) {
        if(a == 0) {
            return 0;
        }

        uint c = a * b; 
        require(c / a == b, "Mult Overflow!");

        return c;
    }

    function div(uint a, uint b) internal pure returns(uint) {
        uint c = a / b;

        return c;
    }
}

contract Ownable {
    address payable public owner;

    event OwnershipTransferred(address newOwner);

    constructor() {
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner!");
        _;
    }

    function transferOwnership(address payable newOwner) onlyOwner public {
        owner = newOwner;

        emit OwnershipTransferred(owner);
    }

}

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract BasicToken is Ownable {
    using SafeMath for uint;

    uint internal _totalSupply;
    mapping(address => uint) internal _balances;
    mapping(address => mapping(address => uint)) internal _allowed;

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed owner, address indexed spender, uint value);

    function totalSupply() external view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint) {
        return _balances[account];
    }

    function allowance(address tokenOwner, address spender) external view returns (uint) {
        return _allowed[tokenOwner][spender];
    }

    function transfer(address recipient, uint amount) external returns (bool) {
        require(_balances[msg.sender] >= amount);
        require(recipient != address(0));

        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(msg.sender, recipient, amount);

        return true;
    }

    function approve(address spender, uint amount) external returns (bool) {
        _allowed[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) external returns (bool) {
        require(_allowed[sender][msg.sender] >= amount);
        require(_balances[sender] >= amount);
        require(recipient != address(0));

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        _allowed[sender][msg.sender] = _allowed[sender][msg.sender].sub(amount);

        emit Transfer(sender, recipient, amount);

        return true;
    }
}

contract MintableToken is BasicToken {
    using SafeMath for uint;

    event Mint(address indexed to, uint tokens);

    function mint(address to, uint tokens) onlyOwner public {
        _balances[to] = _balances[to].add(tokens);
        _totalSupply = _totalSupply.add(tokens);

        emit Mint(to, tokens);
    }
}

contract LightinCoin is MintableToken {
    string public constant name = "Lightin Coin";
    string public constant symbol = "LGN";
    uint8 public constant decimals = 18;
}
