pragma solidity 0.5.0;
//import "./SafeMath.sol";
import {Message} from "./Message.sol";
//import "./MerkleTrie.sol";
//import "./Owned.sol";


//             /\                                                                     /\
//   _         )( ______________________                       ______________________ )(         _
//  (_)///////(**)______________________>  Private Contract   <______________________(**)\\\\\\\(_)
//             )(                                                                     )(
//             \/                          EZEKIEL 29:19 KJV                          \/

contract AccessRegistry{

    struct Directory {
        string name;
        mapping (address => bool) trustees;
        bytes32 root;
        string priv;
        string pub;
    }

    address owner;
// mapping of pub keys to priv keys uint is the directory
    mapping(string => string)keysPairs;
    mapping (uint => Directory) private Directories;
    uint dirCounter;
    Message message;

    constructor (Message _message) public{
        owner = msg.sender;
        message = Message(_message);
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyTrustee(uint _directory) {
        require(Directories[_directory].trustees[msg.sender] == true);
        _;
    }

    function getDir (uint directory) onlyTrustee(directory) public view returns
                    (string memory, bytes32){
        string memory name = Directories[directory].name;
        bytes32 direc = Directories[directory].root;
        return (name, direc);
    }

    function createDir (uint directory, string memory pubKey, string memory privKey)
                        onlyTrustee(directory) public view returns(string memory, bytes32){
        string memory name = Directories[directory].name;
        bytes32 dir = Directories[directory].root;
        return (name, dir);
    }

    function addKeyPair(string memory priv, string memory pub)public onlyOwner(){
        dirCounter++;
        keysPairs[priv] = pub;
    }

    function addTrustee(uint dir, address, address trustee)public onlyOwner(){
        Directories[dir].trustees[trustee] = true;
        string memory priv = Directories[dir].priv;
        string memory pub = Directories[dir].pub;
        message.sendMessage(string(abi.encodePacked(priv, "/n", pub)), trustee, 
                                            'you have access to this users directory');
    }
}