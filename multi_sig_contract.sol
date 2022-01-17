pragma solidity ^0.7.5;
pragma experimental ABIEncoderV2;      


contract multisig{
    //Minimum approvals needed for the transaction to be processed 
    uint min_approvals;
    //list of the owners of contract
    address[] owners;
    uint total_balance;

    
     //transaction struct
    struct transaction{
        address payable to;
        uint amount;
        uint count;
        bool is_txn_done;
    }

    constructor(uint approvals , address[] memory a){
        owners=a;
        min_approvals = approvals;
        total_balance = 0;
    }
    
    
    modifier only_owner{
    
    bool flag = false;
    for(uint i=0;i<owners.length;i++)
    {
      if(msg.sender == owners[i])
        {
         flag = true;
         break;
        }
    }
    require(flag == true , "Not authorized to perform this operation");
    _;
    }

    
    //balance deposited by each owner
    mapping(address=>uint) bal_of_owner;
    
    //storage map to store whether owner have voted or not
    mapping(uint=> mapping(address=>bool)) votes;
    
    //list of intiated transaction will be stored in this list
    transaction[] list;

    //events
    event transfer_done(address payable a, uint amount);
    event deposit_done(address a,uint amount);
    event voted(uint txn_id, bool trf);
    event transaction_intiated(address payable to, uint amount);

    //a function to intiate the transaction
    function intiate_transaction(address payable to, uint amount) public only_owner{
       //require((msg.sender == ownerA)||(msg.sender == ownerB)||(msg.sender == ownerC),"Not authorized to perform the operation");
       require(amount <= address(this).balance, "Insufficient balance, deposit the money");
       transaction memory a =  transaction(to,amount,1,false);
       list.push(a);
       votes[(list.length) - 1][msg.sender] = true;
       emit transaction_intiated(to, amount);
       
    }

    //vote for the specific transaction that is intiated by one of the contract owners
    function vote_on_transaction(uint txn_number, bool trf) public only_owner returns(uint){
      //require((msg.sender == ownerA)||(msg.sender == ownerB)||(msg.sender == ownerC),"Not authorized to perform the operation");
      require(votes[txn_number][msg.sender] == false , "Already voted");
          votes[txn_number][msg.sender] = true;
          if(trf == true){
            list[txn_number].count+=1;
          }
          if(list[txn_number].count == min_approvals){
              transfer(list[txn_number].to , list[txn_number].amount);
              list[txn_number].is_txn_done = true;
              return min_approvals;
          }
      emit voted(txn_number,trf);
      return list[txn_number].count;
      
    }

    //this function is triggered automatically when the min_approval count is met
    function transfer(address payable to, uint amount) private only_owner{
        //require((msg.sender == ownerA)||(msg.sender == ownerB)||(msg.sender == ownerC),"Not authorized to perform the operation");
        require(amount < address(this).balance , "Insufficient balance");
        to.transfer(amount);
        total_balance -= amount;
        emit transfer_done(to,amount);
    }

    //this function is used to deposit ether into contract
    function deposit() public payable only_owner returns(uint){
      //require((msg.sender == ownerA)||(msg.sender == ownerB)||(msg.sender == ownerC),"Not authorized to perform the operation");
      bal_of_owner[msg.sender] += msg.value;
      total_balance += msg.value;
      emit deposit_done(msg.sender,msg.value);
      return msg.value;
    }

    //this function returns the list of transactions available
    function get_txn_list() public only_owner returns(transaction[] memory){
        transaction[] memory a = new transaction[](list.length);
        
        for(uint i=0;i<list.length;i++){
            a[i]=list[i];
        }
        return a;

    }
    
    function deposit_by_owner() public only_owner returns(uint){
         
         return bal_of_owner[msg.sender];
    }

}





