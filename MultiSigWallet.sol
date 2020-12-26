pragma solidity 0.7.5;
import './BoardManaged.sol';

contract MultiSigWallet is BoardManaged
{
    uint balance;
    Transaction[] transactions;

    struct Transaction {
        uint index;
        address recipient;
        uint amount;
        address[] signedBy;
        bool approved;
    }

    event deposited(uint amount, address indexed sender);
    event transactionPrepared(uint indexed index, address indexed recipient, uint amount, address indexed performedBy);
    event transactionSigned(uint indexed index, address indexed performedBy, uint signCount);
    event transactionPerformed(uint indexed index, address indexed performedBy);

    constructor(address _board) {
        board = BoardInterface(_board);
    }

    /**
     * Allow anyone to deposit eth into the contract
     **/
    function deposit() public payable
    {
        require(msg.value > 0);
        uint oldBalance = balance;
        balance += msg.value;
        assert(balance == oldBalance + msg.value);

        emit deposited(msg.value, msg.sender);
    }

    /**
     * Add new transaction which needs to be multi-signed and add sender as first signee.
     **/
    function prepareTransaction(address _recipient, uint _amount) public onlyBoard returns(uint)
    {
        require(_amount > 0, "Can only send more then 0 wei.");

        Transaction memory transaction;
        transaction.index = transactions.length;
        transaction.recipient = _recipient;
        transaction.amount = _amount;
        transaction.approved = false;
        transactions.push(transaction);
        transactions[transaction.index].signedBy.push(msg.sender);

        emit transactionPrepared(transaction.index, transaction.recipient, transaction.amount, msg.sender);

        return(transaction.index);
    }

    /**
     * Sign a transaction as boardmember
     **/
    function signTransaction(uint _transactionIndex) public onlyBoard
    {
        require(transactions[_transactionIndex].approved == false, "This transaction has already been done.");

        // Make sure this board member has not yet signed.
        for(uint i = 0; i < transactions[_transactionIndex].signedBy.length; i++) {
            require(transactions[_transactionIndex].signedBy[i] != msg.sender, "You have already signed this transaction.");
        }

        uint voteCount = transactions[_transactionIndex].signedBy.length;
        transactions[_transactionIndex].signedBy.push(msg.sender);

        assert(transactions[_transactionIndex].signedBy.length == voteCount + 1);

        emit transactionSigned(_transactionIndex, msg.sender, transactions[_transactionIndex].signedBy.length);
    }

    /**
     * Perform the actual transaction
     **/
    function performTransaction(uint _transactionIndex) public onlyBoard
    {
        uint minimumApprovals = board.getMajorityVoteCount();
        uint currentApprovals = transactions[_transactionIndex].signedBy.length;

        require(balance >= transactions[_transactionIndex].amount, "There is not enough balance in the contract.");
        require(currentApprovals >= minimumApprovals, "There not enough approvals.");
        require(transactions[_transactionIndex].approved == false, "This transaction has already been done.");

        address payable recipient = payable(transactions[_transactionIndex].recipient);
        uint oldBalance = balance;
        balance -= transactions[_transactionIndex].amount;
        transactions[_transactionIndex].approved = true;
        recipient.transfer(transactions[_transactionIndex].amount);

        assert(transactions[_transactionIndex].approved == true);
        assert(balance == oldBalance - transactions[_transactionIndex].amount);

        emit transactionPerformed(_transactionIndex, msg.sender);
    }
}
