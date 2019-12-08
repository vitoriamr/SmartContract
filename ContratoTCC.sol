pragma solidity ^0.5.11;

// REGRAS DO CONTRATO

// As tarefas a serem feitas para que o determinado contrato seja dado como encerrado são as seguintes:
// 1. Retirar o pó de toda a casa, incluindo enfeites, livros, etc;
// 2. Varrer ou aspirar a casa;
// 3. Lavar e secar a louça;
// 4. Limpeza do banheiro;
// 5. Lavar e estender as roupas;
// 6. Limpar todos os vidros e janelas da casa;
// 7. Retirar o lixo.


contract MyContract {
    uint256 public price;
    uint8 public limiteDias;
    uint256 deadline;

    bool private garantiaContratantePaga = false;
    bool private garantiaContratadoPaga = false;
    
    mapping(address=>uint) balances;
    
    address public contratante;
    address public contratado;
    address private contrato;

    address payable payableContratante;
    address payable payableContratado;
    address payable payableContrato;

    enum State { Criado, Contratado, Prestado, Encerrado, Cancelado }
    State private state;

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
        contrato = address(this);
        payableContratante = address(uint160(contratante));
        payableContratado = address(uint160(contratado));
        payableContrato = address(uint160(contrato));
    }
    
    modifier apenasContratante {
        require(msg.sender == contratante, "Voce não é o dono deste contrato");
        _;
    }
    
    modifier apenasContratado {
        require(msg.sender == contratado, "Voce não é o prestador deste contrato");
        _;
    }
    
    function deposit() private {
        require(state == State.Encerrado);
        payableContratado.transfer(price + price/5);
    }

    function abort() private {
        require(state == State.Cancelado);
        payableContratante.transfer(price);
    }

    function servicoPrestado() public apenasContratado {
        require(state == State.Contratado, "Contrato não válido");
        if(now <= deadline) {
            state = State.Prestado;
        } else {
            state = State.Cancelado;
        }
    }

    function servicoRecebido() public apenasContratante {
        require(state == State.Prestado, "Serviço ainda não prestado");
        if(now <= deadline) {
            state = State.Encerrado;
            deposit();
        } else {
            state = State.Cancelado;
        }
    }

    function garantiaContratante() public apenasContratante payable {
        require(msg.value == price,  "Preco errado");
        balances[msg.sender] += msg.value;
        
        garantiaContratantePaga = true;
        if(garantiaContratadoPaga == true){
            contratoEstabelecido();
        }
}

    function garantiaContratado() public apenasContratado payable {
        require(msg.value == price/5,  "Preco errado");
        balances[msg.sender] += msg.value;
        
        garantiaContratadoPaga = true;
        if(garantiaContratantePaga == true){
            contratoEstabelecido();
        }
    }

    function contratoEstabelecido() private {
        require(garantiaContratadoPaga == true && garantiaContratantePaga == true, "Garantias não feitas");
        state = State.Contratado;
        deadline = now + (limiteDias * 1 days);
    }

    function estornarGarantias() public payable  {
        require(state == State.Criado, "Estorno inválido");
        if(garantiaContratadoPaga == true) {
            payableContratado.transfer(price/5);
            garantiaContratadoPaga = false;
        } 
        if(garantiaContratantePaga == true) {
            payableContratante.transfer(price);
            garantiaContratantePaga = false;
        }
        state = State.Cancelado;
    }

    function numContrato() public view returns(address contratoAddr){
        return address(this);
    }

    function saldoDoContrato() public view returns(uint){
        return address(this).balance;
    }
    
    function diasRestantes() public view returns(uint){
        if(state != State.Criado) {
            return (deadline - now)/ 60 / 60 / 24;
        }
        else {
            return 0;
        }
    }

    function regrasContrato() public pure returns(string memory tarefas){
        return ("As tarefas a serem feitas para que o determinado contrato seja dado como encerrado são as seguintes: 1. Retirar o pó de toda a casa, incluindo enfeites, livros, etc; 2. Varrer ou aspirar a casa; 3. Lavar e secar a louça; 4. Limpeza do banheiro; 5. Lavar e estender as roupas; 6. Limpar todos os vidros e janelas da casa; 7. Retirar o lixo.");
    }

    function estadoAtualHumanizado() public view returns (string memory estado){
        if(state == State.Criado){
            return ("Criado");
        } 
        if(state == State.Contratado){
            return ("Contratado");
        }
        if(state == State.Prestado){
            return ("Prestado");
        }
        if(state == State.Encerrado){
            return ("Encerrado");
        }
        if(state == State.Cancelado){
            return ("Cancelado");
        }
    }

}



