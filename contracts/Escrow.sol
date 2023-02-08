// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

pragma experimental ABIEncoderV2;
import "./DateTime.sol";

contract Escrow {

    struct Transaction {
        uint id;
        address depositor;
        address arbiter;
        address beneficiary;
        uint amount;
        uint timestamp;
        bool isApproved;
    }

    Transaction[] public transactions;
    
    Transaction none = Transaction(uint(0), address(0), address(0), address(0), uint(0), uint(0), bool(false));

    event EscrowApproved(uint id);

    function newEscrow(address _arbiter, address _beneficiary) public payable {
        require(msg.value > 0);
        Transaction memory transaction = Transaction ({
            id: transactions.length + 1,
            depositor: msg.sender,
            arbiter: _arbiter,
            beneficiary: _beneficiary,
            amount: msg.value,
            timestamp: block.timestamp,
            isApproved: false
        });
        transactions.push(transaction);
    }

    function getFullListEscrows() public view returns (Transaction[] memory) {
        return transactions;
    }

    function getMyListEscrows1() public view returns (Transaction[] memory) {
        uint index = 0;
        for (uint i=0; i <transactions.length; i++) {
            if(transactions[i].depositor == msg.sender) {
                index++;
            }
        }
        Transaction[] memory transaction = new Transaction[](index);
        uint filled = 0;
        for (uint i=0; i<transactions.length; i++) {
            if(transactions[i].depositor == msg.sender) {
                transaction[filled] = transactions[i];
                filled++;
            }
        }
        return transaction;
    }


    function getEscrowById1(uint _id) public view returns (uint id, address depositor, address arbiter, address beneficiary, uint amount, bool isApproved) { 
        for (uint i =0; i<transactions.length; i++) {
              if(transactions[i].id == _id) {
                  id = transactions[_id - 1].id;
                  depositor = transactions[_id - 1].depositor;
                  arbiter = transactions[_id - 1].arbiter;
                  beneficiary = transactions[_id - 1].beneficiary;
                  amount = transactions[_id - 1].amount;
                  isApproved = transactions[_id -1].isApproved;
              }
        }
        return (id, depositor, arbiter, beneficiary, amount, isApproved);
    }

    function getEscrowById2(uint _id) public view returns (uint id, address depositor, address arbiter, address beneficiary, uint amount, bool isApproved) {
        return (transactions[_id - 1].id, transactions[_id - 1].depositor, transactions[_id - 1].arbiter, transactions[_id -1].beneficiary, transactions[_id-1].amount, transactions[_id -1].isApproved);
    }

    function getEscrowById3(uint _id) public view returns (Transaction memory) {
        for (uint i =0; i<transactions.length; i++) {
            if(transactions[i].id == _id) {
                return transactions[i];
            }
        }
        return none;
    }

    function getEscrowById4(uint _id) public view returns (Transaction memory transaction) {
        for (uint i=0; i<transactions.length; i++) {
            if(transactions[i].id == _id) {
                transaction = transactions[i];
            }
        }

    }

    function getListEscrowToApprove() public view returns (Transaction[] memory) {
        uint index = 0;
        for(uint i =0; i<transactions.length; i++) {
            if(transactions[i].isApproved == false && transactions[i].arbiter == msg.sender) {
                index++;
            }
        }
        Transaction[] memory transaction = new Transaction[](index);
        uint filled = 0;
        for (uint i =0; i<transactions.length; i++) {
            if(transactions[i].isApproved == false && transactions[i].arbiter == msg.sender) {
                transaction[filled] = transactions[i];
            }
        }
        return transaction;
    }

    function approveEscrow(uint _id) external payable {
        Transaction memory transaction;
        for (uint i =0; i <transactions.length; i++) {
            if(transactions[i].id == _id) {
                transaction = transactions[i];
            }
        }
        require(transaction.amount > 0, "Escrow does not contain any funds");
        require(transaction.arbiter == msg.sender, "You can not approve this");
        require(transaction.id > 0, "Transaction does not exist");
        (bool success, ) = payable(transaction.beneficiary).call{value: transaction.amount}("");
        require (success, "Transactions failed");
        transactions[_id - 1].isApproved = true;
        emit EscrowApproved(_id);
    }

    function getMyEscrowBalance() public view returns (uint balance) {
        for (uint i=0; i<transactions.length; i++) {
            if(transactions[i].depositor == msg.sender) {
                return address(this).balance;
            }
        }
    }
    function getTotalBalanceOfAllEscrows() public view returns (uint) {
        uint totalBalance = 0;
        for (uint i = 0; i<transactions.length; i++) {
            if(transactions[i].amount > 0) {
                totalBalance += transactions[i].amount;
            }
        }
        return totalBalance;
    }

    function getTimeStampsOfAllEscrows1() public view returns (uint[] memory) {
        uint index = 0;
        for (uint i=0; i<transactions.length; i++) {
            if(transactions[i].amount > 0 && transactions[i].timestamp > 0) {
                index++;
            }
        }
        uint[] memory timestamps = new uint[](index);
        uint temp = 0;
        for (uint i=0; i<transactions.length; i++) {
            if(transactions[i].amount > 0 && transactions[i].timestamp > 0) {
                timestamps[temp] = transactions[i].timestamp;
                temp = temp + 1;
            }
        }
        return timestamps;
    }
      function convertTimestampUTC(uint timestamp) public pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {
        return DateTime.timestampToDateTime(timestamp);
    }
}