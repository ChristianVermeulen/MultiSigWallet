pragma solidity 0.7.5;

interface BoardInterface
{
    function getMajorityVoteCount() external view returns(uint);
    function isOnBoard(address _member) external view returns(bool);
}
