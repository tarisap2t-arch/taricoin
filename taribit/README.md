# Taribit

A simple fungible token smart contract built with Clarinet. Taribit (symbol: TBIT) is an admin-mintable token with basic read-only metadata and balance queries.

## Prerequisites
- Clarinet CLI installed
  - Verify: `clarinet --version`
  - Install (via npm): `npm install -g @hirosystems/clarinet`

## Project layout
- `contracts/taribit.clar` — main token contract
- `Clarinet.toml` — Clarinet project configuration
- `tests/` — place JS/TS tests here (optional)

## Build and checks
Run syntax/type checks:

```bash
clarinet check
```

## Contract overview
- Admin is set once via `initialize` by the first caller; admin can mint and burn.
- Anyone can transfer tokens they own; admin can also move tokens on behalf of any account.
- Read-only endpoints: `get-name`, `get-symbol`, `get-decimals`, `get-total-supply`, `get-balance`.

### Public functions
- `initialize()` → set admin to `tx-sender` (call once)
- `mint(amount, recipient)` → admin-only
- `burn(amount, owner)` → admin or owner
- `transfer(amount, sender, recipient)` → `tx-sender` must be `sender` or current admin

### Read-only functions
- `get-name()` → "Taribit"
- `get-symbol()` → "TBIT"
- `get-decimals()` → `u8`
- `get-total-supply()` → total tokens minted minus burned
- `get-balance(principal)` → current balance

## Quick start with Clarinet console
Open a REPL for local interactions:

```bash
clarinet console
```

Example session (commands typed in the console):

```clarity
;; Set admin to the deployer of the contract call
(contract-call? .taribit initialize)

;; Mint 1_000 TBIT to wallet_2
(contract-call? .taribit mint u1000 (get-wallet 2))

;; Transfer 250 TBIT from wallet_2 to wallet_3 (signed by wallet_2)
::set_tx_sender wallet_2
(contract-call? .taribit transfer u250 (get-wallet 2) (get-wallet 3))

;; Read balances
(contract-call? .taribit get-balance (get-wallet 2))
(contract-call? .taribit get-balance (get-wallet 3))
```

Notes:
- Decimals are `u8` (8). Treat `amount` as base units (e.g., 1 TBIT = 100_000_000 base units).
- You can customize symbol/name/decimals by editing `contracts/taribit.clar`.
