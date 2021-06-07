// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0-solc-0.7/contracts/token/ERC20/ERC20Burnable.sol";


interface IPEER is IERC20 {
    function cut(uint256 value) external view returns (uint256);
}
    

contract LORD is ERC20Burnable {
    using SafeMath for uint256;
    
    uint256 constant InitialSupply = 1180000000 * (10 ** 18);
    uint256 public LastTotalSupply = InitialSupply;
    uint256 public Ratio = 100;
    address public Owner = address(0);
    IPEER public PEER = IPEER(0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8);
    
    modifier isOwner() {
        require(Owner == msg.sender, "You are not Owner");
        _;
    }
    
    constructor () ERC20("Unilord LORD", "LORD") {
        Owner = msg.sender;
    }
    
    function TransferOwnership(address owner) isOwner public {
        Owner = owner;
    }
    
    function Mint() public {
	    uint256 nowTotalSupply = PEER.totalSupply();
	    uint256 mintAmount = (LastTotalSupply - nowTotalSupply) / Ratio;
	    LastTotalSupply = nowTotalSupply;
	    _mint(Owner, mintAmount);
    }
    
    function ChangeRatio(uint256 ratio) isOwner public {
     require(ratio>0, "ratio must >0");
     Mint();
     Ratio = ratio;
    }
    
    function Swap(uint256 amount, bool inverse) public {
        require(amount>(!inverse?Ratio:1/Ratio), "amount must >ratio");
        
        uint256 ratio = Ratio;
        
        
        if(!inverse){
            uint256 tokensBurned = PEER.cut(amount);
            uint256 tokensRecieved = amount.sub(tokensBurned); 
            
            PEER.transferFrom(msg.sender, address(this), amount);
            _mint(msg.sender, tokensRecieved/ratio);
            return;
        }
            burn(amount);
            PEER.transfer(msg.sender, amount*ratio);
            return;
        
        Mint();
    }
}
