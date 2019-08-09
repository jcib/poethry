pragma solidity ^0.4.17;

contract PoethryFactory {
    
    struct Poem {
        string title;
        string body;
        address author;
        uint voteCount;
    }
    
    struct LovePoem {
        string title;
        string lover1;
        string body;
        string lover2;
    }
    
    Poem[] public poems;
    Poem[] public oldPoems;
    Poem private lastWinner;
    LovePoem private lovePoem;
    string[] private poemsTitles;
    address public manager;
    mapping(address => bool) private jury;
    mapping(address => bool) private poets;
    uint private juryCount;
    uint private poetsCount;
    uint private roundCount = 1;
    uint private larger;
    uint private totalVotes;
    uint private lastJackpot;
    uint private lovePoemActualBid;
    uint private totalEtherDistributed;
    uint public value = 4300000000000000;
    
    function() external payable { 
        require(msg.data.length == 0);
    }
    
    function PoethryFactory() public {
        manager = msg.sender;
    }
    
    function becomeJury() public payable {
        require(jury[msg.sender] == false && msg.value == value);
        jury[msg.sender] = true;
        juryCount++;
    }
    
    function becomePoet() public payable {
        require(poets[msg.sender] == false && msg.value == value);
        poets[msg.sender] = true;
        poetsCount++;
    }
    
    function createPoem(string title, string body) public payable {
        require(poets[msg.sender] == true && msg.value == value);
        
        Poem memory newPoem = Poem({
            title: title,
            body: body,
            author: msg.sender,
            voteCount: 0
        });
        
        poems.push(newPoem);
        oldPoems.push(newPoem);
        poemsTitles.push(newPoem.title);
    }
    
    function vote(uint index) public payable {
        require(msg.value == value && jury[msg.sender] == true);
        
        uint i;
        
        if(poems[index].voteCount < 10) {
            poems[index].voteCount++;
            totalVotes++;
            if(poems[index].voteCount == 10){
                transferWinner(index);
            }
        }
        else {
            transferWinner(index);
            totalVotes++;
        }
        
        for(i = 0; i < poems.length; i++) {
            if(poems[i].voteCount > larger) {
                larger = poems[i].voteCount;
            }
        }
    }
    
    function transferWinner(uint _index) private {
        address winner;
        
        winner = poems[_index].author;
        lastWinner = poems[_index];
        delete poems;
        lastJackpot = this.balance;
        totalEtherDistributed += this.balance;
        manager.transfer(value);
        winner.transfer(this.balance);
        larger = 0;
        roundCount++;
    }

    function getPoemsCount() public view returns(uint) {
        return poems.length;
    }
    
    function getAllPoemsCount() public view returns(uint) {
        return oldPoems.length;
    }

    function alreadyPoet(address user) public view returns(bool) {
        bool result;
        if(poets[user] == true) result = true;
        else result = false;
        return result;
    }
    
    function alreadyJury(address user) public view returns(bool) {
        bool result;
        if(jury[user] == true) result = true;
        else result = false;
        return result;
    }
    
    function getCountVotes() public view returns (uint, uint) {
        return (roundCount, larger);
    }

    function getLastWinner() public view returns (string, address, string) {
        return (
            lastWinner.title,
            lastWinner.author,
            lastWinner.body
        );
    }
    
    function getTotals() public view returns (uint, uint) {
        return (juryCount, poetsCount);
    }
    
    function getLastJackpot() public view returns (uint) {
        return lastJackpot;
    }
    
    
    function createLovePoem(string title, string lover1, string body, string lover2) public payable {
        require(poets[msg.sender] == true && msg.value >= lovePoemActualBid + 10000000000000000);
        
        lovePoem.title = title;
        lovePoem.lover1 = lover1;
        lovePoem.body = body;
        lovePoem.lover2 = lover2;
        lovePoemActualBid = msg.value;
        manager.transfer(msg.value);
    }
    
    function getLovePoem() public view returns (string, string, string, string) {
        return (
            lovePoem.title,
            lovePoem.lover1,
            lovePoem.body,
            lovePoem.lover2
        );
    }
    
    function getLovePoemActualBid() public view returns (uint) {
        return lovePoemActualBid;
    }

    function getStatistics() public view returns (uint, uint, uint, uint) {
        return (
            juryCount,
            poetsCount,
            totalVotes,
            totalEtherDistributed
        );
    }
    
    //To keep the conversion 1 vote / poem = 1$
    function setValue(uint newValue) public {
        require(msg.sender == manager);
        
        value = newValue;
    }
}
