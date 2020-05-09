pragma solidity ^0.6.0;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./Address.sol";

contract MyToken is IERC20{
    using SafeMath for uint256;
    using Address for  address;
    
    mapping (address => uint)balances;
    mapping (address => mapping(address => uint)) allowances;
    
    string public name;
    string public symbol;
    uint8 public decimals;
    address public owner;
    uint256 private _totalSupply;
    uint256 pricePerTokenInWei;
    
    constructor(uint256 _pricePerTokenInWei) public{
        name = "My Token";
        symbol  = "MTC";
        decimals = 18;
        owner = msg.sender;
        _totalSupply = 1000 * 10**uint256(decimals);
        balances[owner] = _totalSupply;
        pricePerTokenInWei  = _pricePerTokenInWei;
        emit Transfer(address(this),owner, _totalSupply);
        
    }
    
    modifier OnlyOwner(){
        require(msg.sender == owner);
        _;
    }
    
    function totalSupply() external override view returns (uint256){
        return _totalSupply;
    }
    
    function balanceOf(address account) external override view returns (uint256){
        return balances[account];
    }
    
    function transfer(address recipient, uint256 amount) external  override returns (bool){
        address sender = msg.sender;
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(balances[sender] > amount, "Transfer amount exceeds balance");
        balances[sender] = balances[sender].sub(amount);
        balances[recipient] = balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function allowance(address owner, address spender) external override view returns (uint256){
        return allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) external  override returns (bool){
        address sender = msg.sender;
        require(sender != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero adddress");
        require(balances[sender] >= amount, "Not enough balance");
        allowances[sender][spender] = allowances[sender][spender].add(amount);
        emit Approval(sender, spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) external  override returns (bool){
        address _sender = msg.sender;
        require(allowances[sender][_sender] >= amount, "Not enough allowed");
        require(balances[sender] >= amount, "Not enough balance");
        require(recipient != address(0), "Transfer to zero address");
        balances[sender] = balances[sender].sub(amount);
        allowances[sender][_sender] = allowances[sender][_sender].sub(amount);
        balances[recipient] = balances[recipient].add(amount);
        emit Transfer(sender,recipient, amount);
        return true;
    }
    
    function buyTokens()public payable returns(bool){
       address sender = msg.sender;
     // require(isContract(sender) == false);
        require(msg.value > 0, "Value is not provided");
        uint256 unitsPerWei = (1*10**18)/pricePerTokenInWei; 
        uint256 tokensUnits = msg.value * unitsPerWei;
        balances[sender] += tokensUnits;
        balances[owner] -= tokensUnits;
        emit Transfer(owner,sender,tokensUnits);
        return true;
    }
   
    
    fallback()external payable{
        address sender = msg.sender;
     // require(isContract(sender) == false);
        require(msg.value > 0, "Value is not provided");
        uint256 unitsPerWei = (1*10**18)/pricePerTokenInWei; 
        uint256 tokensUnits = msg.value * unitsPerWei;
        balances[sender] += tokensUnits;
        balances[owner] -= tokensUnits;
        emit Transfer(owner,sender,tokensUnits);
    }
    
    
    function adjustPrice(uint256 newPricePerTokenInWei)public OnlyOwner returns(bool){
        pricePerTokenInWei = newPricePerTokenInWei;
        return true;
    }
}