pragma solidity ^0.4.0;

// My first toy EVM Dapp -- Mike Burr <mburr@unintuitive.org>
//
// Users "vote" on their favorite IMDB ID by sending money to the contract,
// where each "vote" is weighted by the amount sent. If you really, really
// like The A Team, then send 3000 ETH to the contract by calling `castVote`
// with argument "tt0084967".
//
// The total for any IMDB ID can be retrieved with `getIdTotal()`. And as an
// added reward for participating a random voter will be chosen once a month
// (approximately) to recieve the current contract's balance. Winners are not
// removed from the list, so it is possible to win multiple times. The chances
// of your address being chosen are  proportianl to the count of unique
// addresses that have ever voted. Simple.

contract ImdbVote {
    address public owner;
    uint public last_payout;
    uint public create_time;
    uint constant one_month = 60*60*24*30;
    mapping (string => uint) votes;
    address[] public voters;

    function ImdbVote() {
        owner = msg.sender;
        create_time = block.timestamp;
        last_payout = create_time;
    }

    function getIdTotal(string ID) constant returns (uint) {
        return votes[ID];
    }

    function tipAuthor() payable {
        owner.transfer(msg.value);
    }

    function isPayoutTime() returns (bool) {
        return (block.timestamp-last_payout > one_month);
    }

    function payRandomVoter() {
        // FIXME -- this is probably not prandom enough. Can probably be
        // gamed, etc.
        uint prandom_index = uint(sha3(block.timestamp)) % voters.length;
        voters[prandom_index].transfer(this.balance);
        last_payout = block.timestamp;
    }

    // A crude way to maintain a uniuqe "set". A sorted list of addresses could
    // make things quicker, but at the cost of complexitiy. Plenty of room for
    // improvment.
    function addToVoters(address voter) {
        uint i = 0;
        while (voters.length > 0 && i++ < voters.length) {
            if (voter == voters[i-1]) {
                return;
            }
        }
        voters.push(voter);
    }

    function castVote(string ID) payable {
        votes[ID] += msg.value;
        addToVoters(msg.sender);
        if (isPayoutTime()) {
            payRandomVoter();
        }
    }
}
