;; title: Taricoin (TARI)
;; version: 1.0.0
;; summary: Taricoin is a SIP-010 compliant fungible token on Stacks
;; description: A decentralized cryptocurrency token with standard fungible token functionality

;; traits
;; SIP-010 trait implementation (commented for devnet compatibility)
;; (impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; token definitions
(define-fungible-token taricoin)

;; constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_OWNER_ONLY (err u100))
(define-constant ERR_NOT_TOKEN_OWNER (err u101))
(define-constant ERR_INSUFFICIENT_BALANCE (err u102))
(define-constant ERR_INVALID_AMOUNT (err u103))

;; Token metadata
(define-constant TOKEN_NAME "Taricoin")
(define-constant TOKEN_SYMBOL "TARI")
(define-constant TOKEN_DECIMALS u6)
(define-constant TOKEN_MAX_SUPPLY u1000000000000000) ;; 1 billion TARI with 6 decimals

;; data vars
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://taricoin.com/metadata.json"))
(define-data-var contract-owner principal CONTRACT_OWNER)

;; data maps
;; None needed for basic SIP-010 implementation

;; public functions

;; SIP-010 Standard Functions

;; Transfer tokens
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) ERR_NOT_TOKEN_OWNER)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (ft-transfer? taricoin amount sender recipient)
  )
)

;; Get token name
(define-read-only (get-name)
  (ok TOKEN_NAME)
)

;; Get token symbol
(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL)
)

;; Get token decimals
(define-read-only (get-decimals)
  (ok TOKEN_DECIMALS)
)

;; Get token balance of a principal
(define-read-only (get-balance (account principal))
  (ok (ft-get-balance taricoin account))
)

;; Get total supply
(define-read-only (get-total-supply)
  (ok (ft-get-supply taricoin))
)

;; Get token URI
(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)

;; Admin Functions (only contract owner)

;; Mint tokens (only owner)
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_OWNER_ONLY)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (<= (+ (ft-get-supply taricoin) amount) TOKEN_MAX_SUPPLY) (err u104))
    (ft-mint? taricoin amount recipient)
  )
)

;; Burn tokens (only token holder can burn their own tokens)
(define-public (burn (amount uint) (owner principal))
  (begin
    (asserts! (or (is-eq tx-sender owner) (is-eq contract-caller owner)) ERR_NOT_TOKEN_OWNER)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (ft-burn? taricoin amount owner)
  )
)

;; Set token URI (only owner)
(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_OWNER_ONLY)
    (ok (var-set token-uri new-uri))
  )
)

;; Transfer ownership (only current owner)
(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_OWNER_ONLY)
    (ok (var-set contract-owner new-owner))
  )
)

;; read only functions

;; Get contract owner
(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

;; Get max supply
(define-read-only (get-max-supply)
  (ok TOKEN_MAX_SUPPLY)
)

;; Initialize contract with initial supply to deployer
(begin
  (try! (ft-mint? taricoin u100000000000 CONTRACT_OWNER)) ;; Mint 100,000 TARI to deployer
)

;; private functions
;; None needed for this implementation
