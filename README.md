# Introduction

This small project creates a wallet which needs multiple signatures for a transaction before it can be performed. The signatures needed are determined by a Board which is dynamic in size.

![](https://forum.ivanontech.com/uploads/default/original/3X/a/e/aeba3413d0fc5793a9c2e5fe26e50e48c5d0e0aa.png)

My requirements:
- A board can have an infinite amount of members
- A board vote count is the minimum needed to achieve majority consensus
- A board can only be edited by the owner (CEO perhaps?)
- A wallet is connected to a board (this way, 2 board can manage multiple wallets).
- A transaction is not automatically sent after final approval because the contract balance might be too small at the time. We do not want the signature for the transfer to be reverted because of this.
- We allow a transaction to be performed with approvals of board members which are no longer on the board at the moment of transfer (we trust their intentions were valid at the time of signing).
multisigwallet

A `Board` contract which keeps track of board members and calculates how mane votes would be needed for a majority. A `MultiSigWallet` which has a `Board` attached to determine approvals
The `Board` contract is `Ownable` to make sure only the owner (CEO?) can hire/fire boardmembers. The `MulltiSigWallet` is `BoardManaged` meaning its access is determined by the board.

This way we abstract the management of access away from the wallet itself and make it dynamic so the wallet does not need any updates when the board changes over time.
