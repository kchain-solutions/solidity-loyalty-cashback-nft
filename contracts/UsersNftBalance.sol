// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract UsersNftBalance {
    mapping(address => uint256[]) private validTokens;
    mapping(address => uint256[]) private notValidTokens;
    uint256[] private _tmpArray;

    function _addItem(address owner, uint256 item) internal {
        uint256[] storage q = validTokens[owner];
        q.push(item);
    }

    function _moveItem(
        address owner,
        uint256 itemId,
        address to
    ) internal returns (bool) {
        uint256[] storage fromTokens = validTokens[owner];
        uint256[] storage toTokens = validTokens[to];
        delete _tmpArray;
        bool flag = false;
        for (uint256 i = 0; i < fromTokens.length; i++) {
            if (fromTokens[i] == itemId) {
                toTokens.push(itemId);
                flag = true;
            } else {
                _tmpArray.push(fromTokens[i]);
            }
        }
        if (flag) {
            validTokens[owner] = _tmpArray;
        }
        return flag;
    }

    function _getFirstNFT(address owner) internal view returns (uint256) {
        uint256[] memory vt = validTokens[owner];
        require(vt.length > 0, "No NFT in your balance");
        return vt[0];
    }

    function getValidNFTs() public view returns (uint256[] memory) {
        uint256[] memory q = validTokens[msg.sender];
        return q;
    }

    function getNotValidNFTs() public view returns (uint256[] memory) {
        uint256[] memory q = notValidTokens[msg.sender];
        return q;
    }

    function _dropNotValidTokens(address owner) internal {
        delete notValidTokens[owner];
    }

    function _putInvalid(address owner, uint256 itemId) internal {
        uint256[] storage validTokensArray = validTokens[owner];
        uint256[] storage notValidTokensArray = notValidTokens[owner];
        delete _tmpArray;
        bool flag = false;
        for (uint256 i = 0; i < validTokensArray.length; i++) {
            if (validTokensArray[i] == itemId) {
                notValidTokensArray.push(itemId);
                flag = true;
            } else {
                _tmpArray.push(validTokensArray[i]);
            }
        }
        if (flag) {
            validTokens[owner] = _tmpArray;
        }
    }
}
