# Taricoin (TARI) Smart Contract

A SIP-010 compliant fungible token implementation on the Stacks blockchain.

## Overview

Taricoin is a decentralized cryptocurrency token built on the Stacks blockchain. It follows the SIP-010 fungible token standard, ensuring compatibility with wallets, exchanges, and other DeFi applications in the Stacks ecosystem.

## Token Details

- **Name**: Taricoin
- **Symbol**: TARI
- **Decimals**: 6
- **Max Supply**: 1,000,000,000 TARI (1 billion tokens)
- **Initial Supply**: 100,000 TARI (minted to deployer)

## Features

### Core SIP-010 Functions
- ✅ Transfer tokens between accounts
- ✅ Get token name, symbol, and decimals
- ✅ Check token balances
- ✅ Get total supply
- ✅ Token URI support for metadata

### Administrative Functions
- 🔐 Mint new tokens (owner only)
- 🔥 Burn tokens (token holder only)
- 🔧 Update token URI (owner only)
- 👑 Transfer contract ownership (owner only)

### Security Features
- Access control for administrative functions
- Max supply enforcement
- Input validation for all operations
- Standard error handling

## Contract Structure

```clarity
;; Core token definition
(define-fungible-token taricoin)

;; Key constants
TOKEN_NAME: "Taricoin"
TOKEN_SYMBOL: "TARI"
TOKEN_DECIMALS: 6
TOKEN_MAX_SUPPLY: 1,000,000,000,000,000 (with decimals)

;; Error codes
ERR_OWNER_ONLY: u100
ERR_NOT_TOKEN_OWNER: u101
ERR_INSUFFICIENT_BALANCE: u102
ERR_INVALID_AMOUNT: u103
```

## Functions

### Public Functions

#### `transfer`
Transfer tokens from sender to recipient.
```clarity
(transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
```

#### `mint` (Admin Only)
Mint new tokens to a recipient address.
```clarity
(mint (amount uint) (recipient principal))
```

#### `burn`
Burn tokens from the caller's balance.
```clarity
(burn (amount uint) (owner principal))
```

#### `set-token-uri` (Admin Only)
Update the token metadata URI.
```clarity
(set-token-uri (new-uri (optional (string-utf8 256))))
```

#### `set-contract-owner` (Admin Only)
Transfer contract ownership to a new address.
```clarity
(set-contract-owner (new-owner principal))
```

### Read-Only Functions

#### `get-name`
Returns the token name.

#### `get-symbol`
Returns the token symbol.

#### `get-decimals`
Returns the number of decimals.

#### `get-balance`
Get token balance for an account.
```clarity
(get-balance (account principal))
```

#### `get-total-supply`
Returns the current total supply.

#### `get-token-uri`
Returns the current token URI.

#### `get-contract-owner`
Returns the current contract owner.

#### `get-max-supply`
Returns the maximum supply limit.

## Development Setup

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) v3.7.0 or higher
- Node.js and npm (for testing)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd taricoin-contract
```

2. Install dependencies:
```bash
npm install
```

### Testing

Run the test suite:
```bash
npm test
```

Check contract syntax:
```bash
clarinet check
```

### Deployment

1. Configure your deployment settings in the appropriate network file:
   - `settings/Devnet.toml` - Local development
   - `settings/Testnet.toml` - Stacks testnet
   - `settings/Mainnet.toml` - Stacks mainnet

2. Deploy using Clarinet:
```bash
clarinet deploy --network testnet
```

## Usage Examples

### Basic Token Transfer

```clarity
;; Transfer 1000 TARI from Alice to Bob
(contract-call? .taricoin transfer u1000000 'SP1ALICE... 'SP1BOB... none)
```

### Checking Balance

```clarity
;; Get Alice's TARI balance
(contract-call? .taricoin get-balance 'SP1ALICE...)
```

### Minting (Admin Only)

```clarity
;; Mint 5000 TARI to Alice
(contract-call? .taricoin mint u5000000000 'SP1ALICE...)
```

## Security Considerations

- Only the contract owner can mint new tokens
- Max supply is enforced to prevent unlimited inflation
- Users can only burn their own tokens
- All functions include proper input validation
- Access control is implemented for administrative functions

## Error Codes

| Code | Description |
|------|-------------|
| u100 | ERR_OWNER_ONLY - Only contract owner can perform this action |
| u101 | ERR_NOT_TOKEN_OWNER - Sender is not the token owner |
| u102 | ERR_INSUFFICIENT_BALANCE - Insufficient token balance |
| u103 | ERR_INVALID_AMOUNT - Invalid amount (must be > 0) |
| u104 | Max supply exceeded |

## Token Economics

- **Initial Distribution**: 100,000 TARI minted to deployer
- **Max Supply**: 1 billion TARI tokens
- **Inflation**: Controlled by contract owner through minting
- **Deflationary**: Tokens can be burned by holders

## Roadmap

- [ ] Multi-signature admin controls
- [ ] Time-locked minting schedules
- [ ] Governance integration
- [ ] Staking mechanisms
- [ ] Cross-chain bridges

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions and support, please:
- Open an issue on GitHub
- Join our community Discord
- Follow us on Twitter [@TaricoinOfficial](https://twitter.com/taricoinofficial)

## Disclaimer

This smart contract is provided as-is. Please conduct thorough testing and security audits before deploying to mainnet. The developers are not responsible for any loss of funds or other damages that may occur from using this contract.