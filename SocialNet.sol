pragma solidity 0.5.0;

//           ___                                                                  _
//          /__/|__                                                            __//|
//          |__|/_/|__                                                       _/_|_||
//          |_|___|/_/|__ ---              John 3:16               ---    __/_|___||
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
        address[] likesList;
        address[] dislikesList;
        mapping(address => bool) likes;
        mapping(address => bool) dislikes;
        bool status;
// ipfs hash
        string image;
        uint flags;
    }

    struct Profile {
        uint _yearsOld;
        string name;
        string description;
        uint followers;
        uint following;
        uint likesCounter;
        uint dislikesCounter;
        bool status;
        uint postsCounter;
        Post[] posts;
        mapping(address => bool) friends;
        mapping(address => bool) blocked;
        mapping(address => Message) messages;
// ipfs hash
        string avatar;
        bool mod;
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

    mapping(address => Profile) public profiles;
    mapping(address => ModApp) public modApps;
// address -- post index -- reason for removal -- true == resolved
    mapping(address => mapping(uint => (uint, bool))) flagged;
    mapping(address => mapping(address => bool)) private pendingRequests;
    mapping(address => mapping(address => bool)) private likes;
    mapping(address => mapping(address => bool)) private dislikes;

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

    modifier mutualFriends (address _friendsAccount) {
        require(profiles[msg.sender].friends[_friendsAccount] && profiles[_friendsAccount].friends[msg.sender]);
        _;
    }

    modifier notLikedYet (address _friendsAccount, uint numberPost) {
        require(profiles[_friendsAccount].posts[numberPost].likes[msg.sender] == false);
        _;
    }

    modifier notDislikedYet (address _friendsAccount, uint numberPost) {
        require(profiles[_friendsAccount].posts[numberPost].dislikes[msg.sender] == false);
        _;
    }

    modifier postIsActive (address _friendsAccount, uint numberPost) {
        require(profiles[_friendsAccount].posts[numberPost].status);
        _;
    }


    function createAccount (uint _yearsOld, string memory _name, string memory  _description) 
                            public payable {
        bool status = profiles[msg.sender].status;
        if (status) // if profile exists...
            revert();
        profiles[msg.sender].status = true;
        profiles[msg.sender].name = _name;
        profiles[msg.sender]._yearsOld = _yearsOld;
        profiles[msg.sender].description = _description;
        profiles[msg.sender].true = false;

    }
    
    function applyForModerator (string memory _description)  payable onlyRegistered{
        modApps[msg.sender].description = _description;
        modApps[msg.sender].addre = msg.sender;
    }

// First vote to 20 wins
    function voteForModerator (address user, bool vote) payable onlyRegistered{
        ModApp memory app;
        if (app.upVotes.length >= 20 || app.downVotes.length >= 20){
            if (vote == true){
                app.upVotes++;
            } else if(vote == false){
                apps.downVotes++;
            }
        }
    }

    function flag (address profile, uint index, uint reason) payable onlyRegistered{
        profiles[profile].posts.flags++;
        if (profiles[profile].posts.flags.length >= 5){
            flagged[profile][index][profiles[profile].posts.flags.length] = ();
        }
    }

// A post with 5 flags must be resolved
// True verdict deletes post
// Reasons to remove -- 1 = porn, 2 = gore
    function resolveFlagged (address _profile, uint _index, bool verdict, uint reason)
                            public payable onlyModerator{
        if (flagged[profile][index[1]] == false){
            flagged[profile][index[0] = reason]
            if (verdict == true){
                flagged[profile][index[0] = reason];
                delete profiles[_profile][_index][];
            }else{
                flagged[profile][index[0] = reason];
            }
        }
    }

//    function disputePostRemoval (uint _yearsOld, string _name, string _description) 
//                                payable onlyRegistered{
//    }

//    function voteOnDispute (uint _yearsOld, string _name, string _description) payable onlyRegistered{
//    }

    function addFriend (address _friendsAccount) public onlyRegistered {
        require(!profiles[msg.sender].friends[_friendsAccount]); // require not friends currently
        profiles[msg.sender].friends[_friendsAccount] = false;
        profiles[_friendsAccount].friends[msg.sender] = false;
        pendingRequests[_friendsAccount][msg.sender] = true;
    }

    function approveRequest (address _friendsAccount) public onlyRegistered {
        require(!profiles[msg.sender].friends[_friendsAccount] && pendingRequests[msg.sender]
                [_friendsAccount] == true); 
        profiles[msg.sender].friends[_friendsAccount] = true;
        profiles[_friendsAccount].friends[msg.sender] = true;
        delete pendingRequests[_friendsAccount][msg.sender];
    }

    function block (address _friendsAccount) public onlyRegistered {
        require(!profiles[msg.sender].friends[_friendsAccount]); // require not friends currently
        profiles[msg.sender].friends[_friendsAccount] = false;
        profiles[_friendsAccount].friends[msg.sender] = false;
        pendingRequests[_friendsAccount][msg.sender] = true;
    }

    function postInFriendsWall (address _friendsAccount, string _message) public payable onlyRegistered
                               mutualFriends (_friendsAccount) {
        Post memory _post;
        _post.message = _message;
        _post.date = now;
        _post.publisher = msg.sender;
        _post.status = true;
        profiles[_friendsAccount].posts.push(_post);
        profiles[_friendsAccount].postsCounter++;
    }

    function removeFriendWallPost (address _friendsAccount, string _message, uint index)
                                  public payable onlyRegistered mutualFriends (_friendsAccount){
        if (profiles[_friendsAccount].posts[index].publisher == msg.sender){
            delete profiles[_friendsAccount].posts[index];
            profiles[_friendsAccount].postsCounter--;
        }
    }

    function post (string _message) public payable  onlyRegistered{
        Post memory _post;
        _post.message = _message;
        _post.date = now;
        _post.publisher = msg.sender;
        _post.status = true;
        profiles[_friendsAccount].posts.push(_post);
        profiles[_friendsAccount].postsCounter++;
    }

    function removePost (uint index)public payable onlyRegistered{
        delete profiles[_friendsAccount].posts[index];
        profiles[_friendsAccount].postsCounter--;
    }

    function likeFriendsPost (address _friendsAccount, uint numberPost) public 
                             mutualFriends (_friendsAccount) postIsActive (_friendsAccount, numberPost)
                             notLikedYet (_friendsAccount, numberPost){
        profiles[_friendsAccount].posts[numberPost].likes[msg.sender] = true;
    }

    function dislikeFriendsPost (address _friendsAccount, uint numberPost) public 
                                mutualFriends (_friendsAccount) postIsActive (_friendsAccount, 
                                numberPost) notDislikedYet (_friendsAccount, numberPost){
        profiles[_friendsAccount].posts[numberPost].dislikes[msg.sender] = true;
    }

    function message (address _friendsAccount, string _message) public payable 
                     onlyRegistered(_friendsAccount){
        Post memory _post;
        _post.message = _message;
        _post.date = now;
        _post.publisher = msg.sender;
        _post.status = true;
        profiles[_friendsAccount].posts.push(_post);
        profiles[_friendsAccount].postsCounter++;
    }


///////////////////////////////////////////////////////////////////////////////////////////////////
//                                        INTERNALS
///////////////////////////////////////////////////////////////////////////////////////////////////

    function createMod (uint _yearsOld, string _name, string _description) internal payable {
        bool status = profiles[msg.sender].status;
    }

    function RemoveMod (uint _yearsOld, string _name, string _description) internal payable {
        bool status = profiles[msg.sender].status;
    }

}