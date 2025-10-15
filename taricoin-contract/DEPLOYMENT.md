# Taricoin Deployment Guide

## Quick Start

This guide will help you deploy the Taricoin smart contract to different Stacks networks.

## Prerequisites

1. **Clarinet CLI** installed (v3.7.0+)
2. **Node.js 20+** for running tests (current version compatibility issue noted)
3. **Stacks wallet** with STX tokens for deployment

## Contract Verification

First, verify your contract syntax:
```bash
clarinet check
```

## Network Configuration

### Development (Devnet)
The contract is ready for local development testing. The SIP-010 trait is commented out for devnet compatibility.

### Testnet Deployment

1. Configure your testnet settings in `settings/Testnet.toml`
2. Add your wallet details:
```toml
[accounts.deployer]
mnemonic = "your twelve word mnemonic phrase here"
balance = 100000000  # 100 STX
```

3. Deploy to testnet:
```bash
clarinet deploy --network testnet
```

### Mainnet Deployment

1. **⚠️ IMPORTANT**: Uncomment the SIP-010 trait implementation for mainnet:
   
   In `contracts/taricoin.clar`, change line 8 from:
   ```clarity
   ;; (impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
   ```
   
   To:
   ```clarity
   (impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
   ```

2. Configure mainnet settings in `settings/Mainnet.toml`
3. **Ensure sufficient STX balance** for deployment fees
4. Deploy to mainnet:
```bash
clarinet deploy --network mainnet
```

## Post-Deployment Verification

After deployment, verify your contract:

1. **Check contract deployment**:
```bash
clarinet console --network [testnet|mainnet]
```

2. **Verify token metadata**:
```clarity
(contract-call? .taricoin get-name)
(contract-call? .taricoin get-symbol)
(contract-call? .taricoin get-decimals)
(contract-call? .taricoin get-total-supply)
```

3. **Check initial balance**:
```clarity
(contract-call? .taricoin get-balance '<your-principal-address>)
```

## Security Checklist

Before mainnet deployment:

- [ ] Audit smart contract code
- [ ] Test all functions thoroughly
- [ ] Verify access controls
- [ ] Test edge cases and error conditions
- [ ] Review token economics
- [ ] Backup deployment keys securely
- [ ] Test on testnet first

## Common Issues

### Node.js Version Error
If you encounter Node.js version errors during testing:
- Upgrade to Node.js 20+ or use a version manager like nvm
- Alternative: Use Docker with appropriate Node.js version

### SIP-010 Trait Error
- Ensure trait is properly uncommented for mainnet
- Verify trait address is correct for your target network

### Insufficient Balance
- Ensure deployer account has sufficient STX for contract deployment
- Deployment typically costs 1-5 STX depending on contract size

## Contract Functions Summary

### Read-Only Functions
- `get-name()` - Returns token name
- `get-symbol()` - Returns token symbol
- `get-decimals()` - Returns decimal places
- `get-balance(principal)` - Returns balance for address
- `get-total-supply()` - Returns total token supply
- `get-token-uri()` - Returns metadata URI
- `get-contract-owner()` - Returns contract owner
- `get-max-supply()` - Returns maximum supply limit

### Public Functions
- `transfer(amount, sender, recipient, memo)` - Transfer tokens
- `mint(amount, recipient)` - Mint tokens (owner only)
- `burn(amount, owner)` - Burn tokens
- `set-token-uri(uri)` - Update metadata URI (owner only)
- `set-contract-owner(new-owner)` - Transfer ownership (owner only)

## Support

For deployment issues:
1. Check Clarinet documentation: https://docs.hiro.so/clarinet
2. Stacks Discord: https://discord.gg/stacks
3. Review this project's GitHub issues

## Important Notes

- **Mainnet deployments are irreversible** - test thoroughly first
- Keep your deployment mnemonic secure and backed up
- Monitor your contract after deployment for any issues
- Consider implementing a multi-sig for production deployments