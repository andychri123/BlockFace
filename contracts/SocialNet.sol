pragma solidity 0.5.0;
pragma experimental ABIEncoderV2;

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
        uint likeCount;
        uint dislikeCount;
        string[] replies;
        mapping(address => bool) likes;
        mapping(address => bool) dislikes;
// ipfs hash
        string image;
        uint flags;
        uint postNo;
        uint[] posts;
    }

    struct Profile {
        address add;
        uint ID;
        string location;
        string name;
        string description;
        bool status;
        uint postsCounter;
        uint[] posts;
        address[] friends;
        address[] friendRequests;
//        mapping(address => bool) pendingRequests;
        mapping(address => bool) friendss;
        mapping(address => bool) blocked;
// ipfs hash
        string avatar;
        bool mod;

        string sessionID;
        string sessionQR;
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

    struct Page{
        uint ID;
        string name;
        string description;
        address creator;
        uint[] posts;
        mapping(address => bool) moderators;
    }

    uint postCount;
    uint pageCount;
    uint profilesCount;
// ImageRegistryOracle is a IPFS address -- pass in a hash of
// a image the oracle decodes hash and runs it through binwalk using Pyodide
// -- if it passes.. add to the users ipfs node and add to the merkle tree in the smart contract
    address IPFSRegistryOracle;
    address AndyChris;
    string TORhiddenServiceOracleAddress;
    string xmrAddress;
    string btcAddress;
    string ipfsAddress;
    mapping(uint => address) profiless;
    mapping(address => bool) moderators;
    mapping(uint => Post) posts;
    mapping(uint => Page) pages;
    mapping(address => Profile) public profiles;
    mapping(address => ModApp) public modApps;
// address -- post index -- reason for removal -- true == resolved
    mapping(address => mapping(uint => uint)) flagged;
    mapping(address => mapping(address => bool)) private likes;
    mapping(address => mapping(address => bool)) private dislikes;

    event PostCreated(uint id, string content, uint tipAmount, address payable author);
    event PostTipped(uint id, string content, uint tipAmount, address payable author);

    constructor () public {
        AndyChris = msg.sender;
        xmrAddress = '0xBE52e6782318A5068C8b33e4d93406D3f6cd16DA';
        btcAddress = '0xBE52e6782318A5068C8b33e4d93406D3f6cd16DA';
        ipfsAddress = '0xBE52e6782318A5068C8b33e4d93406D3f6cd16DA';
    }

    modifier isAndyChris() {
        require(msg.sender == AndyChris);
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


    modifier notLikedYet (uint numberPost) {
        require(posts[numberPost].likes[msg.sender] == false);
        _;
    }

    modifier notDislikedYet (uint numberPost) {
        require(posts[numberPost].dislikes[msg.sender] == false);
        _;
    }

    function getPostsAmount() public view returns (uint256) {
        return postCount;
    }

    function getProfilesAmount() public view returns (uint256) {
        return profilesCount;
    }

    function getMyPosts() public view returns (uint[] memory pos){
        uint[] memory pos = profiles[msg.sender].posts;
        return (pos);
    }

    function getUsersPosts(address user) public view returns (uint[] memory pos){
        uint[] memory pos = profiles[user].posts;
        return (pos);
    }

    function getMyPostno() public view returns (uint posNo){
        uint posNo = profiles[msg.sender].postsCounter;
        return (posNo);
    }
    
    function setXmrAddress(string memory xmr) public isAndyChris(){
        xmrAddress = xmr;
    }

    function setbtcAddress(string memory btc) public isAndyChris(){
        btcAddress = btc;
    }

   function setIPFSAddress(string memory ipfs) public isAndyChris(){
        ipfsAddress = ipfs;
    }


    function getHomeData() public view returns (string memory xmr, string memory btc, 
                                                          string memory ipfs){
        string memory xmr = xmrAddress;
        string memory btc = btcAddress;
        string memory ipfs = ipfsAddress;
        return (xmr, btc, ipfs);
    }

    function getPost(uint256 id) public view returns ( address publisher, uint postsCounter, 
                                                       string memory message, string memory image, 
                                                       string[] memory replies, uint likes){
        address publisher = posts[id].publisher;
        uint postsCounter = posts[id].postNo;
        string memory message = posts[id].message;
        string memory image = posts[id].image;
        string[] memory replies = posts[id].replies;
        uint likes = posts[id].likeCount;
        return (publisher, postsCounter, message, image, replies, likes);
    }

    function reply(uint256 id, string memory reply) public payable{
       // posts[id].replies.push(reply);
        string memory _reply = string(abi.encodePacked('-->', profiles[msg.sender].name, ": ", reply));
        posts[id].replies.push(_reply);
    }


    function createAccount (string memory _location, string memory _name, string memory  _description,
                            string memory _avatar) 
                            public payable {
        bool status = profiles[msg.sender].status;
        if (status) // if profile exists...
            revert();
        uint ID = profilesCount++;
        profiles[msg.sender].ID = ID;
        profiles[msg.sender].add = msg.sender;
        profiles[msg.sender].status = true;
        profiles[msg.sender].name = _name;
        profiles[msg.sender].location = _location;
        profiles[msg.sender].description = _description;
        profiless[ID] = msg.sender;
        }

    function createPage (string memory _name, string memory _description) public payable {
        uint pCount = pageCount++;
        pages[pCount].ID = pCount;
        pages[pCount].name = _name;
        pages[pCount].creator = msg.sender;
        pages[pCount].description = _description;
        pages[pCount].moderators[msg.sender] = true;
        profiless[profilesCount++] = msg.sender;
        }

    function getPage (uint id) public view returns(string memory name, string memory description,
                                                   address creator, uint[] memory pos){
        string memory name = pages[id].name;
        address creator = pages[id].creator;
        string memory description = pages[id].description;
        uint[] memory pos = pages[id].posts;
        return(name, description, creator, pos);
        }


    function getAccountCard (uint member) public view returns(string memory name, uint followers,
                             uint pCount, address add){
        string memory name = profiles[profiless[member]].name;
//        string memory avatar = profiles[profiless[member]].avatar;
        uint followers = profiles[profiless[member]].friends.length;
        uint pCount = profiles[profiless[member]].postsCounter;
        address add = profiles[profiless[member]].add;
        return (name, followers, pCount, add);
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
    }

    function getMyFriends() public view returns (address[] memory friends){
        address[] memory friends = profiles[msg.sender].friends;
        return (friends);
    }

    function getMyFriendRequests() public view returns (address[] memory friendsR){
        address[] memory friendsR = profiles[msg.sender].friendRequests;
        return (friendsR);
    }

    function addFriend (address _friendsAccount) public onlyRegistered {
        require(!profiles[msg.sender].friendss[_friendsAccount]); // require not friends currently
    //    profiles[_friendsAccount].pendingRequests[msg.sender] = true;
        Profile storage p = profiles[_friendsAccount];
        uint m = profiles[msg.sender].ID;
        p.friendRequests.push(msg.sender);
    }

    function approveRequest (address addr) public onlyRegistered {
        require(!profiles[msg.sender].friendss[addr]); 
        Profile storage p = profiles[msg.sender];
        Profile storage f = profiles[addr];
        p.friends.push(addr);
        f.friends.push(msg.sender);
        profiles[addr].friendss[msg.sender] = true;
        profiles[msg.sender].friendss[addr] = true;
        //      delete profiles[msg.sender].friendRequests[addr];
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
        posts[num].postNo = num;
        profiles[msg.sender].postsCounter++;
        Profile storage p = profiles[msg.sender];
        p.posts.push(num);
    }

    function postInPage (string memory _message, string memory image, uint ID) public onlyRegistered{
        post(_message, image);
        posts[ID].message = _message;
        Page storage p = pages[ID];
        p.posts.push(postCount);
    }

    function removePost (uint index)public onlyRegistered{
        delete profiles[msg.sender].posts[index];
        profiles[msg.sender].postsCounter--;
    }

    function removePostInPage (uint ID, uint index)public onlyRegistered{
        require(pages[ID].moderators[msg.sender] == true);
        delete profiles[msg.sender].posts[index];
        profiles[msg.sender].postsCounter--;
    }

    function removePostMod (uint index)public onlyRegistered{
        require(moderators[msg.sender] == true);
        delete profiles[msg.sender].posts[index];
        profiles[msg.sender].postsCounter--;
    }

    function likePost (uint numberPost) public 
                       notLikedYet (numberPost){
        posts[numberPost].likes[msg.sender] = true;
        posts[numberPost].likeCount ++;
    }

    function dislikePost (uint numberPost) public 
                          notDislikedYet (numberPost){
        posts[numberPost].dislikes[msg.sender] = true;
        posts[numberPost].dislikeCount ++;
    }

    function createMod (address mod)public isAndyChris{
        moderators[mod] == true;
    }

    function createPageMod (uint ID, address mod)public onlyRegistered{
        require(pages[ID].creator == msg.sender);
        pages[ID].moderators[mod] = true;
    }

    function removeMod (address mod)public isAndyChris{
        moderators[mod] = false;
    }

    function removePageMod (uint ID, address mod)public onlyRegistered{
        require(pages[ID].creator == msg.sender);
        pages[ID].moderators[mod] = false;
    }

    function getSession(address add) public view returns(string memory ID, string memory QR){
        string memory ID = profiles[add].sessionID;
        string memory QR = profiles[add].sessionQR;
        return(ID, QR);
    }

    function getMySession() public view returns(string memory ID, string memory QR){
        string memory ID = profiles[msg.sender].sessionID;
        string memory QR = profiles[msg.sender].sessionQR;
        return(ID, QR);
    }

    function setSession (string memory ID, string memory QR)public onlyRegistered{
        profiles[msg.sender].sessionID = ID;
        profiles[msg.sender].sessionQR = QR;
    }


///////////////////////////////////////////////////////////////////////////////////////////////////
//                                        INTERNALS
///////////////////////////////////////////////////////////////////////////////////////////////////

// creates accessReqistry contract and writes the address to users profile - can only be created once
    function createAccessReqistry(string memory name, string memory symbol, address payable creator)
                                  internal returns(address newCon){
                                  }
}