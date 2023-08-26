// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


/**
 * @title RandomnessService
 * @dev This is not a stand alone smart contract, it just serves as a means for generation randomness, where you first commit and then fulfill
 */
contract RandomnessService {
    mapping(bytes32 => uint256) public commitments;



    event Commit(bytes32 _requestId, uint256 _intendedFulfillBlock);


    error COMMIT_BLOCK_MUST_BE_GREARTER_THAN_CURRENT_BLOCK();
    error REQUEST_ID_MUST_NOT_BE_ZERO();
    error RANDOMNESS_VARIABLE_NOT_YET_GENERATED();
    error COMMITMENT_EXPIRED();


    function commit(bytes32 _requestId, uint256 _intendedFulfillBlock) external {
        {
            if (_intendedFulfillBlock <= block.number) {
                revert COMMIT_BLOCK_MUST_BE_GREARTER_THAN_CURRENT_BLOCK();
            }

            if (_requestId == bytes32(0)) {
                revert REQUEST_ID_MUST_NOT_BE_ZERO();
            }
        }

        commitments[_requestId] = _intendedFulfillBlock;
        emit Commit(_requestId, _intendedFulfillBlock);
    }



    function fulfill(bytes32 _requestId) external view returns(uint256) {
        uint256 block__ = commitments[_requestId];

        {
            if (_requestId == bytes32(0)) {
                revert REQUEST_ID_MUST_NOT_BE_ZERO();
            }

            if (block.number > block__) {
                revert RANDOMNESS_VARIABLE_NOT_YET_GENERATED();
            }

            if (block.number <= block__ + 256) {
                revert COMMITMENT_EXPIRED();
            }
        }

        return uint256(blockhash(block__));
    }
}