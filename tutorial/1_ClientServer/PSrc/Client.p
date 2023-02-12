/* User Defined Types */

// payload type associated with the eWithDrawReq, where `source`: client sending the withdraw request,
// `accountId`: account to withdraw from, `amount`: amount to withdraw, and `rId`: unique
// request Id associated with each request.
type tWithDrawReq = (source: Client, accountId: int, amount: int, rId:int);

// payload type associated with the eWithDrawResp, where `status`: response status (below),
// `accountId`: account withdrawn from, `balance`: bank balance after withdrawal, and
// `rId`: request id for which this is the response.
type tWithDrawResp = (status: tWithDrawStatus, accountId: int, balance: int, rId: int);

type tDepositReq = (source: Client, accountId: int, amount: int, rId:int);

type tDepositResp = (accountId: int, balance: int, rId: int);

// enum representing the response status for the withdraw request
enum tWithDrawStatus {
  WITHDRAW_SUCCESS,
  WITHDRAW_ERROR
}

// event: withdraw request (from client to bank server)
event eWithDrawReq : tWithDrawReq;
// event: withdraw response (from bank server to client)
event eWithDrawResp: tWithDrawResp;

// event: deposit request (from client to bank server)
event eDepositReq : tDepositReq;
// event: deposit response (from bank server to client)
event eDepositResp: tDepositResp;


machine Client
{
  var server : BankServer;
  var accountId: int;
  var nextReqId : int;
  var currentBalance: int;

  start state Init {

    entry (input : (serv : BankServer, accountId: int, balance : int))
    {
      server = input.serv;
      currentBalance =  input.balance;
      accountId = input.accountId;
      // hacky: we would like request id's to be unique across all requests from clients
      nextReqId = accountId*100 + 1; // each client has a unique account id
      goto WithdrawMoney;
    }
  }

  state WithdrawMoney {
    entry {
      // If current balance is <= 10 then we need more deposits before any more withdrawal
      if(currentBalance <= 10)
        goto NoMoneyToWithDraw;

      // send withdraw request to the bank for a random amount between (1 to current balance + 1)
      send server, eWithDrawReq, (source = this, accountId = accountId, amount = WithdrawAmount(), rId = nextReqId);
      nextReqId = nextReqId + 1;
    }

    on eWithDrawResp do (resp: tWithDrawResp) {
      // bank always ensures that a client has atleast 10 dollars in the account
      assert resp.balance >= 10, "Bank balance must be greater than 10!!";
      if(resp.status == WITHDRAW_SUCCESS) // withdraw succeeded
      {
        print format ("Withdrawal with rId = {0} succeeded, new account balance = {1}", resp.rId, resp.balance);
        currentBalance = resp.balance;
      }
      else // withdraw failed
      {
        // if withdraw failed then the account balance must remain the same
        assert currentBalance == resp.balance,
          format ("Withdraw failed BUT the account balance changed! client thinks: {0}, bank balance: {1}", currentBalance, resp.balance);
        print format ("Withdrawal with rId = {0} failed, account balance = {1}", resp.rId, resp.balance);
      }

      if(currentBalance > 10)
      {
        print format ("Still have account balance = {0}, lets try and withdraw more", currentBalance);
        goto WithdrawMoney;
      }
    }
  }

  // function that returns a random integer between (1 to current balance + 1)
  fun WithdrawAmount() : int {
    return choose(currentBalance) + 1;
  }

  // function that returns a random integer between (1 to current balance + 1)
  fun DepositAmount() : int {
    return choose(30) + 1;
  }

  state NoMoneyToWithDraw {
    entry {
      // if I am here then the amount of money in my account should be exactly 10
      assert currentBalance == 10, "Hmm, I still have money that I can withdraw but I have reached NoMoneyToWithDraw state!";
      print format ("No Money to withdraw, depositing some!");

      send server, eDepositReq, (source = this, accountId = accountId, amount = DepositAmount(), rId = nextReqId);
      nextReqId = nextReqId + 1;
    }

    on eDepositResp do (resp: tDepositResp) {
      // We just deposited a non-zero amount and the account should have been exactly 10
      assert resp.balance > 10, "Bank balance must be greater than 10!!";
      print format ("Deposit with rId = {0} succeeded, new account balance = {1}", resp.rId, resp.balance);
      currentBalance = resp.balance;
      goto WithdrawMoney;
    }
  }
}
