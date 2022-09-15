// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../access_controller/PlatformAccessController.sol";

/**
 * @notice ERC20 token with some extra functionality
 * By default, there are restrictions on transfers to contracts not in whitelist
 * Method for transferring without approval, you can see the contracts that use it
 */
contract PlatformToken is ERC20, PlatformAccessController {
    event InsertWalletListToAccessWhitelist(
        address indexed admin,
        address[] walletList
    );

    event RemoveWalletListFromAccessWhitelist(
        address indexed admin,
        address[] walletList
    );

    /**
     * @notice Emit during turn off access confines
     * @param admin Platform admin which do this action
     */
    event TurnOffAccessConfines(address indexed admin);

    address private _vesting;
    address private _staking;
    address private _cashback;

    bool public _isAccessConfinesTurnOff;
    mapping(address => bool) private _accessWhitelistMap;

    modifier accessConfinesTurnOn() {
        require(!_isAccessConfinesTurnOff, "access confines turn off");
        _;
    }

    /**
     * @param adminPanel platform admin panel address
     */
    constructor(
        address adminPanel,
        address recipient,
        uint256 supply
    ) ERC20("Propchain Token", "PROP") {
        _initiatePlatformAccessController(adminPanel);
        _mint(recipient, supply);
    }

    /**
     * @notice Removed the initiate function as recommended and craeted various setters
     */
    function updateVestingAddress(address vesting) external {
        require(_vesting == address(0), "already initiated");
        _vesting = vesting;
        _accessWhitelistMap[vesting] = true;
    }

    function updateStakingAddress(address staking) external {
        require(_staking == address(0), "already initiated");
        _staking = staking;
        _accessWhitelistMap[staking] = true;
    }

    function updateCashbackAddress(address cashback) external {
        require(_cashback == address(0), "already initiated");
        _cashback = cashback;
        _accessWhitelistMap[cashback] = true;
    }

    function isAccessWhitelistMember(address wallet)
        external
        view
        returns (bool)
    {
        return _accessWhitelistMap[wallet];
    }

    /**
     * @notice Turn off access confines checking in transfer, by default turn on
     * After can't turn on back, can call only once
     * Only platform admin can do
     */
    function turnOffAccessConfines()
        external
        accessConfinesTurnOn
        onlyPlatformAdmin
    {
        _isAccessConfinesTurnOff = true;

        emit TurnOffAccessConfines(_msgSender());
    }

    function insertWalletListToAccessWhitelist(address[] calldata walletList)
        external
        accessConfinesTurnOn
        onlyPlatformAdmin
    {
        require(0 < walletList.length, "wallet list is empty");

        uint256 index = walletList.length;
        while (0 < index) {
            --index;

            _accessWhitelistMap[walletList[index]] = true;
        }

        emit InsertWalletListToAccessWhitelist(_msgSender(), walletList);
    }

    function removeWalletListFromAccessWhitelist(address[] calldata walletList)
        external
        accessConfinesTurnOn
        onlyPlatformAdmin
    {
        require(0 < walletList.length, "wallet list is empty");

        uint256 index = walletList.length;
        while (0 < index) {
            --index;

            _accessWhitelistMap[walletList[index]] = false;
        }

        emit RemoveWalletListFromAccessWhitelist(_msgSender(), walletList);
    }

    /**
     * @notice Burn tokens from the sender balance
     * Only platform admin can do
     */
    function burn(uint256 amount) external onlyPlatformAdmin {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Similat to transferFrom, but to address is sender
     * Only vesting, staking and cashback contracts can call
     * Designed to save money, transfers without approval
     */
    function specialTransferFrom(address from, uint256 amount) external {
        address to = _msgSender();
        require(
            to == _vesting || to == _staking || to == _cashback,
            "incorrect sender"
        );

        _transfer(from, to, amount);
    }

    /**
     * @dev Call before transfer
     * If access confines turn on transer to contracts which are not in whitelist will revert
     * @param to address to tokens are transferring
     */
    function _beforeTokenTransfer(
        address,
        address to,
        uint256
    ) internal virtual override {
        if (_isAccessConfinesTurnOff) {
            return;
        }

        bool isWallet = !Address.isContract(to);
        require(isWallet || _accessWhitelistMap[to], "incorrect recipent");
    }

    function _msgSender()
        internal
        view
        virtual
        override(Context, PlatformAccessController)
        returns (address)
    {
        return Context._msgSender();
    }
}
