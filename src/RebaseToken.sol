//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract RebaseToken is ERC20, Ownable, AccessControl {
    error RebaseToken__InterestRateCanOnlyDecrease(uint256 oldInterestRate, uint256 newInterestRate);

    uint256 private constant PRECISION_FACTOR = 1e18;
    bytes32 private constant MINT_AND_BURN_ROLE = keccak256("MINT_AND_BURN_ROLE");
    uint256 private s_interestRate = (5 * PRECISION_FACTOR) / 1e8;
    mapping(address => uint256) private s_userInterestRateMapping;
    mapping(address => uint256) private s_userLastUpdatedTimestampMapping;

    event InterestRateSet(uint256 newInterestRate);

    constructor() ERC20("Rebase Token", "RBT") Ownable(msg.sender) {}

    function grantMintAndBurnRole(address _account) external onlyOwner {
        _grantRole(MINT_AND_BURN_ROLE, _account);
    }

    function setInterestRate(uint256 _newInterestRate) external onlyOwner {
        if (_newInterestRate >= s_interestRate) {
            revert RebaseToken__InterestRateCanOnlyDecrease(s_interestRate, _newInterestRate);
        }
        s_interestRate = _newInterestRate;
        emit InterestRateSet(_newInterestRate);
    }

    function getPrincipleBalanceOf(address _user) external view returns (uint256) {
        return super.balanceOf(_user);
    }

    function mint(address _to, uint256 _amount, uint256 _userInterestRate) external onlyRole(MINT_AND_BURN_ROLE) {
        _mintAccruedInterest(_to);
        s_userInterestRateMapping[_to] = _userInterestRate;
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) external onlyRole(MINT_AND_BURN_ROLE) {
        _mintAccruedInterest(_from);

        _burn(_from, _amount);
    }

    function balanceOf(address _user) public view override returns (uint256) {
        return (super.balanceOf(_user) * _calculateUserAccumulatedInterestSinceLastUpdate(_user)) / PRECISION_FACTOR;
    }

    function transfer(address _recipient, uint256 _amount) public override returns (bool) {
        _mintAccruedInterest(msg.sender);
        _mintAccruedInterest(_recipient);
        if (_amount == type(uint256).max) {
            _amount = balanceOf(msg.sender);
        }
        if (balanceOf(_recipient) == 0) {
            s_userInterestRateMapping[_recipient] = s_userInterestRateMapping[msg.sender];
        }
        return super.transfer(_recipient, _amount);
    }

    function transferFrom(address _sender, address _recipient, uint256 _amount) public override returns (bool) {
        _mintAccruedInterest(_sender);
        _mintAccruedInterest(_recipient);
        if (_amount == type(uint256).max) {
            _amount = balanceOf(_sender);
        }
        if (balanceOf(_recipient) == 0) {
            s_userInterestRateMapping[_recipient] = s_userInterestRateMapping[_sender];
        }
        return super.transferFrom(_sender, _recipient, _amount);
    }

    function _calculateUserAccumulatedInterestSinceLastUpdate(address _user)
        internal
        view
        returns (uint256 linearInterest)
    {
        uint256 timeElapsed = block.timestamp - s_userLastUpdatedTimestampMapping[_user];
        linearInterest = PRECISION_FACTOR + (s_userInterestRateMapping[_user] * timeElapsed);
        return linearInterest;
    }

    function _mintAccruedInterest(address _user) internal {
        uint256 previousPrincipleBalance = super.balanceOf(_user);
        uint256 currentBalance = balanceOf(_user);

        uint256 balanceIncrease = currentBalance - previousPrincipleBalance;

        s_userLastUpdatedTimestampMapping[_user] = block.timestamp;

        _mint(_user, balanceIncrease);
    }

    function getUserInterestRate(address _user) external view returns (uint256) {
        return s_userInterestRateMapping[_user];
    }

    function getInterestRate() external view returns (uint256) {
        return s_interestRate;
    }
}
