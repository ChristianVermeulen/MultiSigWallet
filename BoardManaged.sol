pragma solidity 0.7.5;
import './Board/BoardInterface.sol';

contract BoardManaged
{
    BoardInterface internal board;

    modifier onlyBoard()
    {
        require(board.isOnBoard(msg.sender), "Address is not a board member");
        _;
    }
}
