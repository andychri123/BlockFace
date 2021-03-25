pragma solidity 0.5.0;

import "./Owned.sol";
//import "./Crowdsale.sol";
//import "./AccessReqistry.sol";
//import {ERC20} from "./ERC20.sol";
//import "./VentureToken.sol";
import "./SocialNet.sol";

//-----------------------------------------------------------------------------------------------------------
//                                 |\_______________ (_____\\______________
//     --      --          HH======#H###############H#######################        JOHN 3:16 KJV
//                                 ' ~""""""""""""""`##(_))#H\"""""Y########
//                                                   ))    \#H\       `"Y###
//                                                   "      }#H)
//-----------------------------------------------------------------------------------------------------------


contract Factory{

    address sn;
	
	constructor(address _sn) public {
        sn = _sn;
    }

    modifier onlySN {
        require(msg.sender == sn);
        _;
    }
/*
    function createVenture(string memory entityName, string memory missionDescription,
                           address creator, string memory tokenName, string memory tokenSymbol, 
                           uint rate)public payable returns(address newCon){
    	address manager = msg.sender;
        address newVenture = new Venture(manager,
                                         tokenRate,
                                         entityName,
                                         missionDescription);
        return newVenture;
        }
*/
/*
    function createCrowdsale(ERC20, uint rate, address _wallet)
                             public payable returns(Crowdsale newCon){
    	Crowdsale newCrowdsale = new Crowdsale(ERC20, rate, _wallet); 
        return newCrowdsale;
    }
*/

//    function createToken(string memory name, string memory symbol, address payable creator)
//                         public payable returns(ERC20 newCon){
//    	ERC20 newToken = new ERC20(name, symbol, creator);
//        return newToken;
//    }


/*
    function createAccessReqistry(string memory name, string memory symbol, address payable creator)
                         onlySN() public payable returns(address newCon){
    	address newToken = new AccessRegistry(name, symbol, creator);
        return newToken;
    }
    */
}