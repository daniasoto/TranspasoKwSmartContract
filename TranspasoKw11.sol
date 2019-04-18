pragma solidity ^0.4.20;


contract TranspasoKw11 
{
    enum StateType { PendienteDeCompra, PrecioFijado, EnergiaDisponible, EnergiaEnUso, Terminado }
    
    StateType public State;
    uint public SaldoComprador;
    uint public SaldoVendedor;
    uint public PrecioKw;
    
    address public Vendedor;
    address public Comprador;
    uint public KwDisponibles; 
    uint public KwVendedor;
    uint public KwBici;
    uint public KwCoche;
    uint public KwMonopatin;
    uint public KwCarga;
    
    enum GastoType { CargarBicicletaElectrica, CargarCocheElectrico, CargarMonopatinElectrico}
    GastoType public Gasto;


    constructor(uint256 saldoComprador, address vendedor) public {   
        if(saldoComprador == 0 || saldoComprador < 0){
            revert();
        }
       
        if(vendedor == 0x0 ){
            revert();
        }
        Comprador = msg.sender; 

        Vendedor = vendedor;
        SaldoComprador = saldoComprador;
        SaldoVendedor = 0;
        KwDisponibles = 0;
        KwVendedor= 0;
        KwBici = 3;
        KwMonopatin = 2;
        KwCoche = 7;

        State = StateType.PendienteDeCompra;
     
    }

    function AnadirSaldo(uint256 saldo) public {
        if(Comprador != msg.sender || saldo == 0 || saldo < 0){
            revert();
        }
        if (State != StateType.PendienteDeCompra && State != StateType.Terminado && State != StateType.PrecioFijado ){ 
            revert();
        }
    
        if(State == StateType.PendienteDeCompra){
            State = StateType.PendienteDeCompra;
        }else if(State == StateType.PrecioFijado){
            State = StateType.PrecioFijado;
        }else if(State == StateType.Terminado){
            State = StateType.PendienteDeCompra;
        }

        SaldoComprador += saldo;
        
    }

    function AnadirKw(uint256 kw) public {
        if(kw == 0 || kw < 0){
            revert();
        }
        if (State != StateType.EnergiaEnUso && State != StateType.EnergiaDisponible && State != StateType.Terminado && State != StateType.PrecioFijado ){ 
            revert();
        }
        if (Vendedor != msg.sender){
            revert();
        }
        
        if(State == StateType.EnergiaEnUso){
            State = StateType.EnergiaEnUso;
        }else if(State == StateType.PrecioFijado){
            State = StateType.PrecioFijado;
        }else if(State == StateType.Terminado){
            State = StateType.Terminado;
        }else if(State == StateType.EnergiaDisponible){
            State = StateType.EnergiaDisponible;
        }

        KwVendedor += kw;
       
    }
    function Terminar() public{
        if(State != StateType.EnergiaEnUso){
            revert();
        }
        if(msg.sender != Comprador){
            revert();
        }
        State = StateType.Terminado;
     
    }

    function FijarPrecio(uint256 precio, uint kw) public {
        
        if(precio == 0 || precio < 0 || kw < 0){
            revert();
        }
        if(msg.sender != Vendedor){ 
            revert();
        }
        if(State != StateType.PendienteDeCompra){
            revert();
        }

        PrecioKw = precio;
        KwVendedor += kw;

        State = StateType.PrecioFijado;
     
    }


    function RealizarCompra(uint256 kwsolicitados ) public {
        if( kwsolicitados == 0 || kwsolicitados < 0 || kwsolicitados > KwVendedor){ // da error si solicito kw negativos o ninguno
            revert();
        }
        if(State != StateType.PrecioFijado && State != StateType.EnergiaDisponible && State != StateType.EnergiaEnUso ){
            revert();
        }
        if(SaldoComprador < PrecioKw*kwsolicitados ){ 
            revert();  
        }else{
            SaldoVendedor += kwsolicitados*PrecioKw;
            KwDisponibles += kwsolicitados;
            KwVendedor -= kwsolicitados;
            SaldoComprador = SaldoComprador - kwsolicitados*PrecioKw;
        } 


        if(State == StateType.PrecioFijado){
            State = StateType.EnergiaDisponible;
        }else if (State == StateType.EnergiaDisponible){
            State = StateType.EnergiaDisponible;
        }else if (State == StateType.EnergiaEnUso){
            State = StateType.EnergiaDisponible;
        }else{
            revert();
        }

      
    }

    function GastarKw(uint256 cantidad) public {
        if(msg.sender != Comprador || cantidad == 0 || cantidad < 0){
            revert();
        }
        if(cantidad > KwDisponibles){
            revert();
        }
        if(State != StateType.EnergiaDisponible && State != StateType.EnergiaEnUso ){
            revert();
        }

        KwDisponibles = KwDisponibles - cantidad;
        State = StateType.EnergiaEnUso;
           
    }

    function GastarEnCargar(GastoType carga) public {
        if(msg.sender != Comprador){
            revert();
        }
         if(State != StateType.EnergiaDisponible && State != StateType.EnergiaEnUso ){
            revert();
        }
        Gasto = carga;

        if(Gasto == GastoType.CargarBicicletaElectrica){
            KwCarga = KwBici;
        }else if(Gasto == GastoType.CargarCocheElectrico){
            KwCarga = KwCoche;
        }else if(Gasto == GastoType.CargarMonopatinElectrico){
            KwCarga = KwMonopatin;
        }

        if(KwCarga > KwDisponibles){
            revert();
        }

        KwDisponibles = KwDisponibles - KwCarga;
        State = StateType.EnergiaEnUso;

         
    }
}