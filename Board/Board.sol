pragma solidity 0.7.5;

import './Ownable.sol';

contract Board is Ownable
{
    address[] members;

    event memberHired(address indexed newMember);
    event memberFired(address indexed firedMember);

    constructor() Ownable()
    {
        members.push(msg.sender);
    }

    /**
     * Hire a new board member to allow signing of transactions
     **/
    function hireMember(address _member) public onlyOwner
    {
        for(uint i = 0; i < members.length; i++) {
            require(members[i] != _member, "This member is already on the board.");
        }

        uint oldMemberCount = members.length;
        members.push(_member);

        assert(members.length == oldMemberCount + 1);

        emit memberHired(_member);
    }

    /**
     * Fire a board member so it can no longer sign transactions
     **/
    function fireMember(address _member) public onlyOwner
    {
        // Make sure the member is actually on the board, and get the index for it
        uint memberIndex = 0;
        bool memberExists = false;
        for(uint i = 0; i < members.length; i++) {
            if (members[i] == _member) {
                memberIndex = i;
                memberExists = true;
            }
        }
        require(memberExists, "Member is not on the board so it can not be fired.");

        uint oldMemberCount = members.length;
        // Clean up the member from the board list.
        for (uint i = memberIndex; i < members.length-1; i++){
            members[i] = members[i+1];
        }
        members.pop();

        assert(members.length == oldMemberCount - 1);

        emit memberFired(_member);
    }

    /**
     * Check if a member is on the board
     **/
    function isOnBoard(address _member) external view returns(bool)
    {
        for(uint i = 0; i < members.length; i++) {
            if (members[i] == _member) {
                return true;
            }
        }

        return false;
    }

    /**
     * Calculate the minimum amount of board members to approve a vote
     **/
    function getMajorityVoteCount() external view returns(uint)
    {
        // Initialize
        uint memberCount = members.length;
        uint multiplier = 10;

        // Find smallest multiplier needed
        while(memberCount > multiplier) {
            multiplier *= 10;
        }

        // Calculate half the votes
        uint calculated = memberCount * multiplier / 2;
        uint voteCount = multiplier;

        // Find first multiplier larger then half the votes for majority
        // Notice the '=' because for even number of members, an extra swingvote is needed
        for(uint i = 1; voteCount <= calculated; i++){
            voteCount = i * multiplier;
        }

        // Back to normal without multiplier
        voteCount /= multiplier;

        // Calculate majority
        return (voteCount);
    }
}
