pragma solidity ^0.4.22;

// REGRAS DO CONTRATO

// As tarefas a serem feitas para que o determinado contrato seja dado como encerrado são as seguintes:
// 1. Retirar o pó de toda a casa, incluindo enfeites, livros, etc;
// 2. Varrer ou aspirar a casa;
// 3. Lavar e secar a louça;
// 4. Limpeza do banheiro;
// 5. Lavar e estender as roupas;
// 6. Limpar todos os vidros e janelas da casa;
// 7. Retirar o lixo.


contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MyContract {
    uint256 public price;
    uint8 public limiteDias;

    bool private garantiaContratantePaga = false;
    bool private garantiaContratadoPaga = false;
    
    address public contratante;
    address public contratado;
    address contrato = 0xB7901D68C4bc97d5c2558C97b9BD4Adf5ce702E6;
    
    enum State { Criado, Contratado, Prestado, Encerrado, Cancelado }
    State public state;
    
    ERC20 token;
    
    constructor(
            uint256 _price,
            uint8 _limiteDias,
            address _contratado
    ) public {
        
         
         price = _price * 1000000000000000000;
         limiteDias = _limiteDias;
         contratante = msg.sender;
         contratado = _contratado;
         state = State.Criado;
    }
    
    modifier apenasContratante {
        require(msg.sender == contratante, "Voce não é o dono deste contrato");
        _;
    }
    
    modifier apenasContratado {
        require(msg.sender == contratado, "Voce não é o prestador deste contrato");
        _;
    }
    
    
  function deposit() public payable {
    require(msg.value == price + price/5);
    require(msg.sender == contrato);
    require(state == State.Encerrado);
    contratado.transfer(price + price/5);
  }
  
  function abort() public payable {
      require(msg.sender == contrato);
      require(state == State.Cancelado);
      contratante.transfer(price);
  }
  
  function servicoPrestado(uint8 dias) public apenasContratado {
     require(state == State.Contratado, "Contrato não válido");
      if(dias <= limiteDias) {
        state = State.Prestado;
      } else {
        state = State.Cancelado;
      }
  }
  
  function servicoRecebido(uint8 dias) public apenasContratante {
    require(state == State.Prestado, "Serviço ainda não prestado");
      if(dias <= limiteDias) {
        state = State.Encerrado;
      } else {
        state = State.Cancelado;
      }
  }
  
  function garantiaContratante() public apenasContratante payable {
      require(msg.value == price,  "Preco errado");
      contrato.transfer(msg.value);
      garantiaContratantePaga = true;
  }
  
  function garantiaContratado() public apenasContratado payable {
      require(msg.value == price/5,  "Preco errado");
      contrato.transfer(msg.value/5);
      garantiaContratadoPaga = true;
  }
  
  function contratoEstabelecido() public {
      require(garantiaContratadoPaga == true && garantiaContratantePaga == true, "Garantias não feitas");
      state = State.Contratado;
  }
  
  function estornarGarantias() public payable  {
      require(msg.value == price + price/5);
      require(state == State.Criado, "Estorno inválido");
      require(msg.sender == contrato);
      if(garantiaContratadoPaga == true) {
          contratado.transfer(price/5);
          garantiaContratadoPaga = false;
      } else {
          contrato.transfer(price/5);
      }
      if(garantiaContratantePaga == true) {
          contratante.transfer(price);
          garantiaContratantePaga = false;
      } else {
          contrato.transfer(price);
      }
      state = State.Cancelado;
  }
}
