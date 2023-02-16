// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 *
 * 1 11 21 41
 *
 * 17
 */

contract TokenCounter is ERC20 {
    
    uint256 weekCounter;
    mapping(uint256 => uint256) public weekTracker;
    mapping(uint256 => uint256) public weekByWeekTracker; /// index[0] value => End of a week
    mapping(address => bool) public isClaimedUser; /// True => If user has transferred a token
    uint256 currentStartOfWeek;
    
    event WeekOver(uint256 indexed weekStart, uint256 indexed newUserCount);

    constructor() ERC20("Name", "symbol") {}
    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override virtual {
        
        if (!isClaimedUser[to]) {
        // if (balanceOf(to) > 1 wei) {
            isClaimedUser[to] = true; /// User as Claimed/Transfer
            if (currentStartOfWeek + 7 days > block.timestamp) {
                emit WeekOver(currentStartOfWeek, weekByWeekTracker[currentStartOfWeek]);
                currentStartOfWeek = block.timestamp;
                weekCounter = weekCounter + 1;
                weekTracker[weekCounter] = currentStartOfWeek;
            }
            weekByWeekTracker[currentStartOfWeek] = weekByWeekTracker[currentStartOfWeek] + 1;
        }
        
        super._beforeTokenTransfer(from, to, amount);
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function getUserCountByWeek(uint256 timestamp) public view returns (uint256, uint256, uint256) {
        require(block.timestamp > timestamp && currentStartOfWeek >= timestamp);
        
        uint256 counter = weekCounter;

        while (true) {
            uint256 currentStart = weekTracker[counter];
            if (currentStart - 7 days > block.timestamp) {
               return (weekTracker[counter], counter, weekTracker[counter]);
            }

            counter--;
        }

        return (0, 0, 0);
    }

}
