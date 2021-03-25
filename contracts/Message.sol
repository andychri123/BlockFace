pragma solidity 0.5.0;
import "./AccessRegistry.sol";
import  {Owned} from "./Owned.sol";



//                    ,
//                   dM
//                   MMr
//                  4MMML                  .
//                  MMMMM.                xf
//  .              "M6MMM               .MM-
//   Mh..          +MM5MMM            .MMMM
//   .MMM.         .MMMMML.          MMMMMh          
//    )MMMh.        MM5MMM         MMMMMMM                 ECCLESIASTES 3:8 KJV
//     3MMMMx.     'MMM3MMf      xnMMMMMM" 
//     '*MMMMM      MMMMMM.     nMMMMMMP"
//       *MMMMMx    "MMM5M\    .MMMMMMM=
//        *MMMMMh   "MMMMM"   JMMMMMMP
//          MMMMMM   GMMMM.  dMMMMMM            .
//           MMMMMM  "MMMM  .MMMMM(        .nnMP"
//..          *MMMMx  MMM"  dMMMM"    .nnMMMMM*
// "MMn...     'MMMMr 'MM   MMM"   .nMMMMMMM*"
//  "4MMMMnn..   *MMM  MM  MMP"  .dMMMMMMM""
//    ^MMMMMMMMx.  *ML "M .M*  .MMMMMM**"
//       *PMMMMMMhn. *x > M  .MMMM**""
//          ""**MMMMhx/.h/ .=*"
//                   .3P"%....
//                 nP"     "*MMnx

contract Message {

    struct message {
    	address sender;
        string message;
        uint time;
// ipfs hash
        string image;
    }

    struct GroupChat{
    	message[] messages;
    	mapping(address => bool) members;
    }

    address payable owner;
    uint public incidentsAmount;
    message[] messages;
    message[] pinnedMessages;
    GroupChat[] groupChats;
    uint GCcounter;
    address AndyChris;
    address AccessRegistry;

    constructor () public {
        AndyChris = 0x64eCe92B79b096c2771131870C6b7EBAE8C2bd7E;
        AccessRegistry = 0x64eCe92B79b096c2771131870C6b7EBAE8C2bd7E;
    }

/*
    modifier isInGroupChat(uint cha) {
        require(GroupChat[cha].members[msg.sender] == true);
        _;
    }
*/

    modifier isAndyChris() {
        require(msg.sender == AndyChris);
        _;
    }

    modifier isAccessRegistry() {
        require(msg.sender == AccessRegistry);
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function sendMessage(string memory _msg, address _sender, string memory _hash) public{
        message storage mesg = messages[messages.length];
        mesg.sender = msg.sender;
        mesg.message =  _msg;
        mesg.time = block.timestamp;
        mesg.image = _hash;
        messages.push(mesg);
    }

    function sendPinnedMessage(string memory _msg, address _sender, string memory _hash) public 
                               isAndyChris(){
        message storage mesg = pinnedMessages[pinnedMessages.length];
        mesg.sender = msg.sender;
        mesg.message =  _msg;
        mesg.time = block.timestamp;
        mesg.image = _hash;
        messages.push(mesg);
    }
    function getMessage(uint _index) onlyOwner() public view returns(address, string memory, uint,
                        string memory ){
    	message memory mesg = messages[_index];
        address sender = mesg.sender;
        string memory messag = mesg.message;
        uint time = mesg.time;
        string memory image = mesg.image;
    	return (sender, messag, time, image);
    }

    function startGroupMessage(uint dir, address trustee) public  isAccessRegistry(){
        GCcounter++;
        GroupChat storage gChat = groupChats[GCcounter];
        gChat.members[msg.sender] = true;
    }

    function sendGroupMessage(uint chat, string memory mesg) public {
        require(groupChats[chat].members[msg.sender] == true);
        message storage mes = groupChats[chat].messages[groupChats[chat].messages.length++];
        mes.message = mesg;
        groupChats[chat].messages.push(mes);
    }

    function addMemberToGroupChat(uint chat, address member) public isAccessRegistry(){
        GroupChat storage gChat = groupChats[GCcounter];
        groupChats[chat].members[member] = true;
    }

    function removeMember(uint chat, address member) public isAccessRegistry(){
        GroupChat storage gChat = groupChats[GCcounter];
        groupChats[chat].members[member] = false;
    }

    function getMessageAmount() public view returns (uint256) {
        return incidentsAmount;
    }

}