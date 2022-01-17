# Multi Signature Wallet contract 

We can add multiple owners for same account , So that based on owners agreement the funds are spent.(Basic functional contract v0.0.1)

# Functionalities:-
*intiate_transaction()* - transaction from one of the ownrs will be intiated. <br />
*vote_on_transaction()* - we can vote on intiated transactions, The transfer will be triggered automatically after the transaction gets minimum threshold votes. <br />
*deposit()* - owners can deposit funds to the contract. <br />
*get_transaction_list()* - liast of the intiated transactions will be displayed. <br />
*transfer()* - this is a private function that will be only be triggered by the contract. 
