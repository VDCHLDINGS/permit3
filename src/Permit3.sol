// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {SignatureTransfer} from "./SignatureTransfer.sol";
import {AllowanceTransfer} from "./AllowanceTransfer.sol";

/// @notice Permit3 handles signature-based transfers in SignatureTransfer and allowance-based transfers in AllowanceTransfer,
///         with deployment-time and batch nonce bitmap imports plus an administrative version/deprecation comment setter.
contract Permit3 is SignatureTransfer, AllowanceTransfer {
    error Unauthorized();

    event VersionCommentUpdated(string oldComment, string newComment);

    address public immutable owner;
    string public versionComment;

    constructor(NonceBitmapImport[] memory initialNonces, string memory initialVersionComment) {
        owner = msg.sender;
        versionComment = initialVersionComment;
        if (initialNonces.length > 0) {
            _importNonces(initialNonces);
        }
    }

    /// @notice Batch-import used nonce bitmaps (e.g. cloned from Mainnet / Gnosis Chain deployments)
    function importNonces(NonceBitmapImport[] calldata imports) external {
        if (msg.sender != owner) revert Unauthorized();
        _importNonces(imports);
    }

    /// @notice Update the human-readable version or deprecation comment on-chain
    function setVersionComment(string calldata newComment) external {
        if (msg.sender != owner) revert Unauthorized();
        emit VersionCommentUpdated(versionComment, newComment);
        versionComment = newComment;
    }
}

/// @dev Backward-compatible alias for existing test suites importing Permit2
contract Permit2 is Permit3 {
    constructor() Permit3(new NonceBitmapImport[](0), "v1.0.0") {}
}
