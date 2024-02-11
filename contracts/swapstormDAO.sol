// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * Interface for the FakeNFTMarketplace
 */
interface IVARtoken {
    /// @dev getPrice() returns the price of an NFT from the FakeNFTMarketplace
    /// @return Returns the price in Wei for an NFT
    function getPrice() external view returns (uint256);

    /// @dev available() returns whether or not the given _tokenId has already been purchased
    /// @return Returns a boolean value - true if available, false if not
    function totalSupply() external view returns (uint256);

    function balanceOfVAR(address) external view returns (uint256);


}

/**
 * Minimal interface for CryptoDevsNFT containing only two functions
 * that we are interested in
 */
// interface ICryptoDevsNFT {
//     //// @dev balanceOf returns the number of NFTs owned by the given address
//     //// @param owner - address to fetch number of NFTs for
//     //// @return Returns the number of NFTs owned
//     function balanceOf(address owner) external view returns (uint256);

//     //// @dev tokenOfOwnerByIndex returns a tokenID at given index for owner
//     //// @param owner - address to fetch the NFT TokenID for
//     //// @param index - index of NFT in owned tokens array to fetch
//     //// @return Returns the TokenID of the NFT
//     function tokenOfOwnerByIndex(
//         address owner,
//         uint256 index
//     ) external view returns (uint256);
// }

contract swapstormDAO is Ownable {
    // Create a struct named Proposal containing all relevant information
    struct Proposal {
        // nftTokenId - the tokenID of the NFT to purchase from FakeNFTMarketplace if the proposal passes
        mapping(address => uint256) add_to_portfolio;
        // deadline - the UNIX timestamp until which this proposal is active. Proposal can be executed after the deadline has been exceeded.
        uint256 deadline;
        // yayVotes - number of yay votes for this proposal
        uint256 yayVotes;
        // nayVotes - number of nay votes for this proposal
        uint256 nayVotes;
        // executed - whether or not this proposal has been executed yet. Cannot be executed before the deadline has been exceeded.
        bool executed;
        // voters - a mapping of CryptoDevsNFT tokenIDs to booleans indicating whether that NFT has already been used to cast a vote or not
        mapping(uint256 => bool) voters;
    }

    // Create a mapping of ID to Proposal
    mapping(uint256 => Proposal) public proposals;
    // Number of proposals that have been created
    uint256 public numProposals;

    IVARtoken VARtoken;
    // ICryptoDevsNFT cryptoDevsNFT;

    // Create a payable constructor which initializes the contract
    // instances for FakeNFTMarketplace and CryptoDevsNFT
    // The payable allows this constructor to accept an ETH deposit when it is being deployed
    constructor(address _nftMarketplace, address _cryptoDevsNFT) payable {
        VARtoken = IVARtoken(_nftMarketplace);
        // cryptoDevsNFT = ICryptoDevsNFT(_cryptoDevsNFT);
    }

    // Create a modifier which only allows a function to be
    // called by someone who owns at least 1 CryptoDevsNFT

    // function balanceOfVAR(address voter) external view returns (uint256){
    //     return ERC20(0x779877A7B0D9E8603169DdbD7836e478b4624789).balanceOf(voter);
    //     //put in the tokenaddress of VAR here
    // }

    modifier ownerofVAROnly() {
        require(ERC20(0x779877A7B0D9E8603169DdbD7836e478b4624789).balanceOf(msg.sender) > 0, "NOT_A_DAO_MEMBER");
        _;
    }



    // / @dev createProposal allows a CryptoDevsNFT holder to create a new proposal in the DAO
    // / @param _nftTokenId - the tokenID of the NFT to be purchased from FakeNFTMarketplace if this proposal passes
    // / @return Returns the proposal index for the newly created proposal
    function createProposalToBuyExisingTokens(
        uint256[] amt
    ) external ownerofVAROnly returns (uint256) {
        // require(nftMarketplace.available(_nftTokenId), "NFT_NOT_FOR_SALE");
        Proposal storage proposal = proposals[numProposals];
        proposal.add_to_portfolio[/* hardcode addresses of tokens here */] = amt[0];
        proposal.add_to_portfolio[/* hardcode addresses of tokens here */] = amt[1];
        proposal.add_to_portfolio[/* hardcode addresses of tokens here */] = amt[2];
        proposal.add_to_portfolio[/* hardcode addresses of tokens here */] = amt[3];
        proposal.add_to_portfolio[/* hardcode addresses of tokens here */] = amt[4];
        proposal.add_to_portfolio[/* hardcode addresses of tokens here */] = amt[5];
        // Set the proposal's voting deadline to be (current time + 5 minutes)
        proposal.deadline = block.timestamp + 5 minutes;

        numProposals++;

        return numProposals - 1;
    }
  
        function createProposalToBuyNewTokens(
        address tokunAddress, uint256 amt1
    ) external ownerofVAROnly returns (uint256) {
        // require(nftMarketplace.available(_nftTokenId), "NFT_NOT_FOR_SALE");
        Proposal storage proposal = proposals[numProposals];
        proposal.add_to_portfolio[tokunAddress] = amt1;

        // Set the proposal's voting deadline to be (current time + 5 minutes)
        proposal.deadline = block.timestamp + 5 minutes;

        numProposals++;

        return numProposals - 1;
    }


    // Create a modifier which only allows a function to be
    // called if the given proposal's deadline has not been exceeded yet
    modifier activeProposalOnly(uint256 proposalIndex) {
        require(
            proposals[proposalIndex].deadline > block.timestamp,
            "DEADLINE_EXCEEDED"
        );
        _;
    }

    // Create an enum named Vote containing possible options for a vote
    enum Vote {
        YAY, // YAY = 0
        NAY // NAY = 1
    }

    /// @dev voteOnProposal allows a CryptoDevsNFT holder to cast their vote on an active proposal
    /// @param proposalIndex - the index of the proposal to vote on in the proposals array
    /// @param vote - the type of vote they want to cast
    function voteOnProposal(
        uint256 proposalIndex,
        Vote vote
    ) external ownerofVAROnly activeProposalOnly(proposalIndex) {
        Proposal storage proposal = proposals[proposalIndex];

        uint256 voterVARBalance = VARtoken.balanceOfVAR(msg.sender);
        uint256 numVotes = voterVARBalance;

        // Calculate how many NFTs are owned by the voter
        // that haven't already been used for voting on this proposal
 

        
        require(numVotes > 0, "Insufficient_balance_CANNOT_VOTE");

        if (vote == Vote.YAY) {
            proposal.yayVotes += numVotes;
        } else {
            proposal.nayVotes += numVotes;
        }
    }

    // Create a modifier which only allows a function to be
    // called if the given proposals' deadline HAS been exceeded
    // and if the proposal has not yet been executed
    modifier inactiveProposalOnly(uint256 proposalIndex) {
        require(
            proposals[proposalIndex].deadline <= block.timestamp,
            "DEADLINE_NOT_EXCEEDED"
        );
        require(
            proposals[proposalIndex].executed == false,
            "PROPOSAL_ALREADY_EXECUTED"
        );
        _;
    }

    /// @dev executeProposal allows any CryptoDevsNFT holder to execute a proposal after it's deadline has been exceeded
    /// @param proposalIndex - the index of the proposal to execute in the proposals array
    function executeProposal(
        uint256 proposalIndex
    ) external ownerofVAROnly inactiveProposalOnly(proposalIndex) {
        Proposal storage proposal = proposals[proposalIndex];

        // If the proposal has more YAY votes than NAY votes
        // purchase the NFT from the FakeNFTMarketplace
        if (proposal.yayVotes > proposal.nayVotes) {

            require(address(this).balance >= nftPrice, "NOT_ENOUGH_FUNDS");//change variable name to something
            ////add function to change ETF structure,parameters proposal.add_to_portfolio
        }
        proposal.executed = true;
    }

    /// @dev withdrawEther allows the contract owner (deployer) to withdraw the ETH from the contract
    function withdrawEther() external onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "Nothing to withdraw, contract balance empty");
        (bool sent, ) = payable(owner()).call{value: amount}("");
        require(sent, "FAILED_TO_WITHDRAW_ETHER");
    }

    // The following two functions allow the contract to accept ETH deposits
    // directly from a wallet without calling a function
    receive() external payable {}

    fallback() external payable {}
}