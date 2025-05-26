# 🪙 Cross-Chain Rebase Token using Chainlink CCIP

This repository implements a fully functional **cross-chain rebase token system** leveraging **Chainlink CCIP**. It features a custom ERC20 token with per-user interest tracking, a pool contract for secure bridging, and a full local simulation environment using Foundry and the Chainlink Local CCIP Simulator.

---

## 📦 Overview

This project allows users to **bridge rebase tokens** across chains while preserving their **individual interest rates** and balances. It includes:

- ✨ A custom `RebaseToken` ERC20 token with auto-compounding interest.
- 🔁 A `RebaseTokenPool` contract implementing `lockOrBurn` and `releaseOrMint` for CCIP bridging.
- 🌉 Bi-directional cross-chain simulation between Sepolia and Arbitrum Sepolia.
- ⚙️ Full suite of tests using Foundry, including `fork()`-based simulations.
- 🧪 Manual bridging scripts and `Deployer` contracts for realistic deployment flows.

---

## 📁 Project Structure

```bash
├── src/
│   ├── RebaseToken.sol          # Custom ERC20 token with interest logic
│   ├── RebaseTokenPool.sol      # Pool contract for CCIP bridging
│   ├── Vault.sol                # Deposit contract to mint tokens
│   └── interfaces/
│       └── IRebaseToken.sol     # Token interface with interest functions
├── test/
│   └── CrossChainTest.t.sol     # End-to-end forked test with CCIP simulation
├── script/
│   ├── Deployer.s.sol           # Deployment script for testnets
│   ├── ConfigurePoolScript.s.sol
│   ├── BridgeTokensScript.s.sol
├── bridgeToZKsync.sh            # Example bash script for ZKSync deployment
└── .env                         # Environment variables for RPCs and accounts


