pragma solidity ^0.4.22;

// REGRAS DO CONTRATO

// As tarefas a serem feitas para que o determinado contrato seja dado como encerrado são as seguintes:
// 1. Retirar o pó dos livros;
// 2. Varrer a casa;
// 3. Lavar a louça;
// 4. Retirar o lixo

interface Token {

    /// @return total amount of tokens
    function totalSupply() external view returns (uint256 supply);

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) external view returns (uint256 balance);

    /// @notice send `_value` tokenfrom `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) external returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) external returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // Optionally implemented function to show the number of decimals for the token
    function decimals() external view returns (uint8 decimals);
}

// contract Token {
//     bytes32 public name;
//     string public symbol;
//     bytes32 public decimals;
//     uint256 private _totalSupply;
//     bool private _allowTransactions;
//     mapping (address => uint256) private _balanceOf;
//     mapping (address => mapping (address => uint256)) private _allowance;
//     event Approval(address indexed _owner, address indexed _spender, uint256 _value);
//     constructor() public {
//         _balanceOf[msg.sender] = _totalSupply;
//     }
//     function totalSupply() view public returns (uint256 totalSupply) {
//         totalSupply = _totalSupply;
//     }
//     function balanceOf(address _address) view public returns (uint balance) {
//         return _balanceOf[_address];
//     }
//     function transfer(address _to, uint256 _value) public returns (bool success) {
//         if(_value <= balanceOf(msg.sender)) {
//             _balanceOf[msg.sender] = _balanceOf[msg.sender] - _value;
//             _balanceOf[_to] = _balanceOf[_to] + _value;
//             return true;
//         }
//         return false;
//     }
//     // Allows another contract to spend tokens on behalf og the '_from' address and sem them to the '_to' address.
//     // _from => the address wich approved you to spend tokens on their behalf.
//     function transferFrom(address _from, address _to, uint256 tokens) public returns (bool success) {
//         if(_allowance[_from][msg.sender] > 0 && _allowance[_from][msg.sender] >= tokens) {
//             _balanceOf[_from] = _balanceOf[_from] - tokens;
//             _balanceOf[_to] = _balanceOf[_to] + tokens;
//             return true;
//         }
//         return false;
//     }
//     function approve(address spender, uint256 tokens) public returns (bool success) {
//         _allowance[msg.sender][spender] = tokens;
//         emit Approval(msg.sender, spender, tokens);
//         return true;
//     }
//      // Checks the amount of tokens that an ower allowed to a spender.
//      // tokenOwner => the address wich owns the funds allowed for spending by a third-party.
//      // spender => the third-party address that is allowed to spend the tokens
//      // Returns the number os tokens available to 'spender' to be spent.
//     function allowance(address tokenOwner, address spender) view public returns (uint remainging) {
//         return _allowance[tokenOwner][spender];
//     }
    
// }

contract GenericContract {
     address public owner;
     address public newOwner;
    
    mapping (address => uint256) public invalidOrder;
    
    event SetOwner(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransfered(address indexed previousOwner, address indexed newOwner);
    
     constructor() public {
        owner = msg.sender;
    }
    
    
    modifier onlyOwner {
        assert(msg.sender == owner);
        _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        emit SetOwner(owner, newOwner);
        owner = newOwner;
    }
    
    function acceptOwnership() public {
        // Only the new owner can accept the ownership
        require(msg.sender == newOwner);
        emit OwnershipTransfered(owner, newOwner);
    }
    
    function getOwner() view public returns (address out) {
        return owner;
    }
}

contract FirstDeposit {
    address public withdrawer;

    uint256 public value = 0;
    uint256 public garanty = 0;
    
    event GarantySent(address _from, address _to, uint256 garanty);
    event ValueSent(address _from, address _to, uint256 value);
    event ValueRestored(address _to, uint256 value);

    event Oi(uint256 teste);
    Token public token;

    
    constructor(address _owner, address _withdrawer) public {
        token = Token(_owner);
        withdrawer = _withdrawer;
    }
    
    function getProviderGaranty(address provider, uint256 price) public payable {
        require(msg.sender == provider);
        garanty = garanty + (price / 5);
        
        require(token.transferFrom(msg.sender, withdrawer, garanty), "Token transfer for garanty failed");

        emit GarantySent(msg.sender, withdrawer, garanty);
    }
    
    function getReceiverGaranty(address receiver, uint256 price) public payable {
        require(msg.sender == receiver);
        value = value + price;
        
        require(token.transferFrom(msg.sender, withdrawer, value), "Token transfer for value failed");
        
        emit ValueSent(msg.sender, withdrawer, value);
    }
    
    function payProvider() public returns (uint256 total) {
        return value + garanty;
    }
    
    function returnReceiverValue(address receiver) public payable {
        require(msg.sender == receiver);
       require(token.transferFrom(withdrawer, msg.sender, value));
       
       emit ValueRestored(msg.sender, value);
      
    }
    
    function teste() public payable returns (uint256) {
        uint256 balance = token.balanceOf(address(this));
        emit Oi(balance);
        
    } 
} 

contract MyContract {
    Token token;
    GenericContract contractCreator;
    FirstDeposit firstDeposit;
    
    uint256 price;
    uint256 serviceDuration;
    
    address public provider;
    address public receiver;
    
    event Withdraw(address token, address user, uint256 amount, uint256 balance);
    event ServiceProvided(address provider);
    event ServiceReceived(address receiver);
    
    constructor(
            address _tokenForRegistration,
            address _provider,
            address _receiver,
            uint256 _price,
            uint256 _serviceDuration
    ) public {
            require(_tokenForRegistration != address(0x0), "token at address zero");
            token = Token(_tokenForRegistration);
            
            // Check if the contract is indeed a token contract
           // require(token.totalSupply() > 0);
            
            contractCreator = GenericContract(msg.sender);
            serviceDuration = _serviceDuration;
            price = _price;
            provider = _provider;
            receiver = _receiver;
        }
        
    // function startContract(address _provider, address _receiver,  uint256 _price) public {    
    //     firstDeposit.getProviderGaranty(_provider, _price);
    //     firstDeposit.getReceiverGaranty(_receiver, _price);
    // }
    
    function serviceProvided(uint256 _days) public returns (bool success) {
        if (msg.sender == provider && _days <= serviceDuration) {
            emit ServiceProvided(provider);
            return true;
        }
        return false;
        
    }
        
    function serviceReceived() public returns (bool success) {
        if(msg.sender == receiver) {
            emit ServiceReceived(receiver);
            return true;
        }
        return false;
        
    }
    
    function withdraw(address _to, uint256 amount, uint256 _days) public payable {
        uint256 balance = token.balanceOf(msg.sender);
        require(serviceProvided(_days) == true);
        require(serviceReceived() == true);
        require(msg.sender == _to);
        require(balance > 0);
        require(token.transfer(_to, firstDeposit.payProvider()));
        selfdestruct(_to);
        emit Withdraw(_to, msg.sender, amount, balance);
    }
    
    function serviceNotProvided(address _receiver, uint256 _days) public {
        if(serviceProvided(_days) == false) {
            firstDeposit.returnReceiverValue(_receiver);
        }
    }
}


