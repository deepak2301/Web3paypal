// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Paypal {
   //Define the owner of the smart contract

   address public owner;

   constructor() {
      owner = msg.sender;
   }

   //create struct and mapping for request , transcation & name

   struct request {
      address requestor;
      uint256 amount;
      string message;
      string name;
   }

   struct sendReceive {
      string action;
      uint256 amount;
      string message;
      address otherPartyAddress;
      string otherPartyName;
   }

   struct userName {
      string name;
      bool hasName;
   }

   mapping(address => userName) names;
   mapping(address => request[]) requests;
   mapping(address => sendReceive[]) history;

   //add a name to wallet address

   function addName(string memory _name) public {
      userName storage newUserName = names[msg.sender];
      newUserName.name = _name;
      newUserName.hasName = true;
   }

   //create a request

   function createRequest(
      address user,
      uint256 _amount,
      string memory _message
   ) public {
      request memory newRequest;
      newRequest.requestor = msg.sender;
      newRequest.amount = _amount;
      newRequest.message = _message;
      if (names[msg.sender].hasName) {
         newRequest.name = names[msg.sender].name;
      }
      requests[user].push(newRequest);
   }

   //pay a request

   function payRequest(uint256 _request) public payable {
      require(_request < requests[msg.sender].length, "No such request");

      //Here, a local variable "myRequests" of type "request[]" (an array of "request" structs) is declared.
      // It is assigned the value of the "requests" mapping for the caller's address (msg.sender).
      //This effectively retrieves the array of requests associated with the caller.

      request[] storage myRequests = requests[msg.sender];

      //this line of code is used to retrieve a specific request from a list of requests
      request storage payableRequest = myRequests[_request];

      uint256 toPay = payableRequest.amount * 1000000000000000000;
      require(msg.value == (toPay), "Pay correct amount");

      payable(payableRequest.requestor).transfer(msg.value);

      addHistory(
         msg.sender,
         payableRequest.requestor,
         payableRequest.amount,
         payableRequest.message
      );

      myRequests[_request] = myRequests[myRequests.length - 1];
      myRequests.pop();
   }

   function addHistory(
      address sender,
      address receiver,
      uint256 _amount,
      string memory _message
   ) private {
      sendReceive memory newSend;
      newSend.action = "-";
      newSend.amount = _amount;
      newSend.message = _message;
      newSend.otherPartyAddress = receiver;
      if (names[receiver].hasName) {
         newSend.otherPartyName = names[receiver].name;
      }
      history[sender].push(newSend);

      sendReceive memory newReceive;
      newReceive.action = "+";
      newReceive.amount = _amount;
      newReceive.message = _message;
      newReceive.otherPartyAddress = sender;
      if (names[sender].hasName) {
         newReceive.otherPartyName = names[sender].name;
      }
      history[receiver].push(newReceive);
   }

   //get all the request sent to user
   //get all historic txs user has been a part of
}
