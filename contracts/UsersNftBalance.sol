// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract UsersNftBalance {
    mapping(address => uint256[]) private nfts;
    uint256[] private _tmpArray;

    function _addItem(address owner, uint256 tokenId) internal {
        uint256[] storage q = nfts[owner];
        q.push(tokenId);
    }

    function _moveItem(
        address owner,
        address to,
        uint256 tokenId
    ) internal returns (bool) {
        uint256[] storage fromTokens = nfts[owner];
        uint256[] storage toTokens = nfts[to];
        delete _tmpArray;
        bool flag = false;
        for (uint256 i = 0; i < fromTokens.length; i++) {
            if (fromTokens[i] == tokenId) {
                toTokens.push(tokenId);
                flag = true;
            } else {
                _tmpArray.push(fromTokens[i]);
            }
        }
        if (flag) {
            nfts[owner] = _tmpArray;
        }
        return flag;
    }

    function _getFirstNFT(address owner) internal view returns (uint256) {
        uint256[] memory vt = nfts[owner];
        require(vt.length > 0, "No NFT in your balance");
        return vt[0];
    }

    function getNFTs() public view returns (uint256[] memory) {
        uint256[] memory q = nfts[msg.sender];
        return q;
    }
}
