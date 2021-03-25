pragma solidity 0.5.0;
import "./SafeMath.sol";
import "./Message.sol";

//           ___                                                                  _
//          /__/|__                                                            __//|
//          |__|/_/|__                                                       _/_|_||
//          |_|___|/_/|__ ---              John 3:16 KJV           ---    __/_|___||
//          |___|____|/_/|__                                           __/_|____|_||
//          |_|___|_____|/_/|_________________________________________/_|_____|___||
//          |___|___|__|___|/__/___/___/___/___/___/___/___/___/___/_|_____|____|_||
//          |_|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___||
//          |___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|_||
//          |_|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|/       

// Original concept made for the ethereum Blockchain
// Future implementations will be deployed to another blockchain
// All functions commented out are designed to run on a blockchain that supports private transactions   

contract SocialNet {
    address public owner;

    struct Post {
        address publisher;
        string message;
        uint date;
        mapping(address => bool) likes;
        mapping(address => bool) dislikes;
// ipfs hash
        string image;
        uint flags;
        uint postNo;
        uint[] posts;
        uint score;
    }

    struct Profile {
        string location;
        string name;
        string description;
//        uint likesCounter;
//        uint dislikesCounter;
        bool status;
        uint postsCounter;
        uint[] posts;
        address[] friends;
        mapping(address => bool) pendingRequests;
        mapping(address => bool) friendss;
        mapping(address => bool) blocked;
        mapping(address => Message) messages;
        mapping(address => bytes32) pinned;
// ipfs hash
        string avatar;
        bool mod;
// address of identity registry contract
        address accessRegistry;
        address messageContract;
    }

    struct Message {
        string message;
        uint time;
// ipfs hash
        string image;
    }

    struct ModApp {
// application description
        string description;
        address profile;
        uint upVotes;
        uint downVotes;
    }

    uint postCount;
// ImageRegistryOracle is a IPFS address -- pass in a hash of
// a image the oracle decodes hash and runs it through binwalk using Pyodide
// -- if it passes.. add to the users ipfs node and add to the merkle tree in the smart contract
    address IPFSRegistryOracle;
    string TORhiddenServiceOracleAddress;
    address[] ipfsPins;
    mapping(uint => Post) posts;
    mapping(address => Profile) public profiles;
    mapping(address => ModApp) public modApps;
// address -- post index -- reason for removal -- true == resolved
    mapping(address => mapping(uint => uint)) flagged;
    mapping(address => mapping(address => bool)) private likes;
    mapping(address => mapping(address => bool)) private dislikes;

    event PostCreated(uint id, string content, uint tipAmount, address payable author);
    event PostTipped(uint id, string content, uint tipAmount, address payable author);

    constructor () public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyRegistered {
        require(profiles[msg.sender].status);
        _;
    }

    modifier onlyModerator {
        require(profiles[msg.sender].status);
        _;
    }

    modifier friends (address _friendsAccount) {
        require(profiles[msg.sender].friendss[_friendsAccount] == true);
        _;
    }


    modifier notLikedYet (address _friendsAccount, uint numberPost) {
        require(posts[numberPost].likes[msg.sender] == false);
        _;
    }

    modifier notDislikedYet (address _friendsAccount, uint numberPost) {
        require(posts[numberPost].dislikes[msg.sender] == false);
        _;
    }

    function getPostsAmount() public view returns (uint256) {
        return postCount;
    }

    function getPost(uint256 id) public view returns ( address publisher, uint postNo, uint date, 
                                                       string memory message, string memory image){
        address publisher = posts[id].publisher;
        uint postNo = posts[id].postNo;
        uint date = posts[id].date;
        string memory message = posts[id].message;
        string memory image = posts[id].image;
        return (publisher, postNo, date, message, image);
    }


    function createAccount (string memory _location, string memory _name, string memory  _description) 
                            public payable {
        bool status = profiles[msg.sender].status;
        if (status) // if profile exists...
            revert();
        profiles[msg.sender].status = true;
        profiles[msg.sender].name = _name;
        profiles[msg.sender].location = _location;
        profiles[msg.sender].description = _description;
        }

    function getAccountCard (address member) public view returns(string memory , uint , uint,
                             string memory){
        string memory name = profiles[msg.sender].name;
        string memory avatar = profiles[msg.sender].avatar;
        uint followers = profiles[msg.sender].friends.length;
        uint pCount = profiles[msg.sender].postsCounter;
        return (name, followers, pCount, avatar);
        }
    
    function applyForModerator (string memory _description) public onlyRegistered{
        modApps[msg.sender].description = _description;
        modApps[msg.sender].profile = msg.sender;
    }

// First vote to 20 wins
    function voteForModerator (address user, bool vote) public onlyRegistered{
        ModApp storage app = modApps[user];
        if (app.upVotes >= 20 || app.downVotes >= 20){
            if (vote == true){
                app.upVotes++;
            } else if(vote == false){
                app.downVotes++;
            }
        }
    }

    function flag (address profile, uint index, uint reason)public  onlyRegistered{
        posts[index].flags++;
 //       if (profiles[profile].posts[index].flags.length >= 5){
 //           flagged[profile][index][profiles[profile].posts.flags.length] = ();
 //       }
    }
/*
// A post with 5 flags must be resolved
// True verdict deletes post
// Reasons to remove -- 1 = porn, 2 = gore
    function resolveFlagged (address _profile, uint _index, bool verdict, uint reason)
                            public payable onlyModerator{
        if (flagged[_profile][_index[1]] == false){
            flagged[_profile][_index[0] = reason];
            if (verdict == true){
                flagged[_profile][_index[0] = reason];
                delete profiles[_profile][_index][];
            }else{
                flagged[_profile][_index[0] = reason];
            }
        }
    }
*/
//    function disputePostRemoval (uint _yearsOld, string _name, string _description) 
//                                payable onlyRegistered{
//    }

//    function voteOnDispute (uint _yearsOld, string _name, string _description) payable onlyRegistered{
//    }

    function addFriend (address _friendsAccount) public onlyRegistered {
        require(!profiles[msg.sender].friendss[_friendsAccount]); // require not friends currently
        profiles[_friendsAccount].pendingRequests[msg.sender] = true;
    }

    function approveRequest (address _friendsAccount) public onlyRegistered {
        require(profiles[msg.sender].pendingRequests[_friendsAccount]); 
        profiles[msg.sender].friendss[_friendsAccount] = true;
//       delete profiles[msg.sender].pendingRequests[_friendsAccount][msg.sender];
    }

    function blockGuy (address _friendsAccount) public onlyRegistered {
        profiles[msg.sender].blocked[_friendsAccount] = true;
    }

    function postInFriendsWall (address _friendsAccount, string memory _message) public payable onlyRegistered
                               friends (_friendsAccount) {
        uint num = postCount++;
        posts[num].message = _message;
        posts[num].date = now;
        posts[num].publisher = msg.sender;
        profiles[msg.sender].postsCounter++;
        postCount++;
        profiles[_friendsAccount].posts.push(num);
        profiles[_friendsAccount].postsCounter++;
    }

    function removeFriendWallPost (address _friendsAccount, string memory _message, uint index)
                                  public onlyRegistered friends (_friendsAccount){
        if (posts[index].publisher == msg.sender){
            delete profiles[_friendsAccount].posts[index];
            profiles[_friendsAccount].postsCounter--;
        }
    }

    function post (string memory _message, string memory image) public onlyRegistered{
        uint num = postCount++;
        posts[num].message = _message;
        posts[num].date = now;
        posts[num].publisher = msg.sender;
        posts[num].image = image;
        profiles[msg.sender].postsCounter++;
        postCount++;
    }

    function removePost (uint index)public onlyRegistered{
        delete profiles[msg.sender].posts[index];
        profiles[msg.sender].postsCounter--;
    }

    function likePost (address _friendsAccount, uint numberPost) public 
                       notLikedYet (_friendsAccount, numberPost){
        posts[numberPost].likes[msg.sender] = true;
        posts[numberPost].score ++;
    }

    function dislikePost (address _friendsAccount, uint numberPost) public 
                          notDislikedYet (_friendsAccount, numberPost){
        posts[numberPost].dislikes[msg.sender] = true;
        posts[numberPost].score --;
    }

///////////////////////////////////////////////////////////////////////////////////////////////////
//                                        INTERNALS
///////////////////////////////////////////////////////////////////////////////////////////////////

    function createMod (uint _yearsOld, string memory _name, string memory _description) internal {
        bool status = profiles[msg.sender].status;
    }

    function RemoveMod (uint _yearsOld, string memory _name, string memory _description) internal {
        bool status = profiles[msg.sender].status;
    }

// creates accessReqistry contract and writes the address to users profile - can only be created once
    function createAccessReqistry(string memory name, string memory symbol, address payable creator)
                                  internal returns(address newCon){
                                  }
}