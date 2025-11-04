;; Taribit Fungible Token (simple SIP-010-like interface, admin-mintable)
;; This contract provides a basic fungible token with admin-controlled mint/burn

(define-data-var admin (optional principal) none)
(define-data-var total-supply uint u0)
(define-map balances { who: principal } { amount: uint })

(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-INSUFFICIENT-BALANCE u101)
(define-constant ERR-ALREADY-INITIALIZED u102)

(define-read-only (get-name)
  (ok "Taribit"))

(define-read-only (get-symbol)
  (ok "TBIT"))

(define-read-only (get-decimals)
  (ok u8))

(define-read-only (get-total-supply)
  (ok (var-get total-supply)))

(define-read-only (get-balance (who principal))
  (ok (default-to u0 (get amount (map-get? balances { who: who })))))

(define-public (initialize)
  (if (is-some (var-get admin))
      (err ERR-ALREADY-INITIALIZED)
      (begin
        (var-set admin (some tx-sender))
        (ok true))))

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (let (
        (admin-opt (var-get admin))
        (authorized (or (is-eq tx-sender sender)
                        (and (is-some admin-opt)
                             (is-eq (unwrap-panic admin-opt) tx-sender))))
        (sender-bal (default-to u0 (get amount (map-get? balances { who: sender }))))
        (recipient-bal (default-to u0 (get amount (map-get? balances { who: recipient }))))
       )
    (if (not authorized)
        (err ERR-NOT-AUTHORIZED)
        (if (< sender-bal amount)
            (err ERR-INSUFFICIENT-BALANCE)
            (begin
              (map-set balances { who: sender } { amount: (- sender-bal amount) })
              (map-set balances { who: recipient } { amount: (+ recipient-bal amount) })
              (ok true))))))

(define-public (mint (amount uint) (recipient principal))
  (let (
        (admin-opt (var-get admin))
        (authorized (and (is-some admin-opt)
                         (is-eq (unwrap-panic admin-opt) tx-sender)))
        (recipient-bal (default-to u0 (get amount (map-get? balances { who: recipient }))))
       )
    (if (not authorized)
        (err ERR-NOT-AUTHORIZED)
        (begin
          (var-set total-supply (+ (var-get total-supply) amount))
          (map-set balances { who: recipient } { amount: (+ recipient-bal amount) })
          (ok true)))))

(define-public (burn (amount uint) (owner principal))
  (let (
        (admin-opt (var-get admin))
        (authorized (or (and (is-some admin-opt)
                             (is-eq (unwrap-panic admin-opt) tx-sender))
                        (is-eq tx-sender owner)))
        (owner-bal (default-to u0 (get amount (map-get? balances { who: owner }))))
       )
    (if (not authorized)
        (err ERR-NOT-AUTHORIZED)
        (if (< owner-bal amount)
            (err ERR-INSUFFICIENT-BALANCE)
            (begin
              (var-set total-supply (- (var-get total-supply) amount))
              (map-set balances { who: owner } { amount: (- owner-bal amount) })
              (ok true))))))
