;; brief-winning-rfp.clar
;; A short, unique RFP contract for Google Clarity Web3

(clarity-version 2)

;; Errors
(define-constant ERR-NOT-FOUND (err u100))
(define-constant ERR-BAD-TIME (err u101))
(define-constant ERR-HASH-MISMATCH (err u102))

;; Track RFPs
(define-data-var next-id uint u0)
(define-map rfps ((id uint))
  ((owner principal) (commit-dead uint) (reveal-dead uint) (winner (optional principal))))

;; Commit + Reveal storage
(define-map commits ((id uint) (vendor principal)) ((h (buff 32))))
(define-map reveals ((id uint) (vendor principal)) ((uri (string-utf8 80))))

;; Create new RFP
(define-public (create-rfp (commit-dead uint) (reveal-dead uint))
  (begin
    (asserts! (> commit-dead block-height) ERR-BAD-TIME)
    (asserts! (> reveal-dead commit-dead) ERR-BAD-TIME)
    (let ((id (+ (var-get next-id) u1)))
      (map-set rfps { id: id } { owner: tx-sender, commit-dead: commit-dead, reveal-dead: reveal-dead, winner: none })
      (var-set next-id id)
      (ok id))))

;; Vendor commit: sha256(id || vendor || uri || salt)
(define-public (commit (id uint) (h (buff 32)))
  (let ((r (map-get? rfps { id: id })))
    (match r
      some (asserts! (<= block-height (get commit-dead (unwrap! r ERR-NOT-FOUND))) ERR-BAD-TIME)
      (map-set commits { id: id, vendor: tx-sender } { h: h })
      (ok true))
      none ERR-NOT-FOUND)))

;; Vendor reveal
(define-public (reveal (id uint) (uri (string-utf8 80)) (salt (buff 32)))
  (let ((c (map-get? commits { id: id, vendor: tx-sender })))
    (match c
      somec (let ((calc (sha256 (concat (to-buff id) (concat (to-buff (hash160 tx-sender)) (concat (utf8-to-bytes uri) salt))))))
                  (stored (get h (unwrap! c ERR-NOT-FOUND))))
              (asserts! (is-eq stored calc) ERR-HASH-MISMATCH)
              (map-set reveals { id: id, vendor: tx-sender } { uri: uri })
              (ok true))
      none ERR-NOT-FOUND)))

;; Owner finalizes winner
(define-public (finalize (id uint) (winner principal))
  (let ((r (map-get? rfps { id: id })))
    (match r
      some (let ((rfp (unwrap! r ERR-NOT-FOUND)))
             (asserts! (is-eq (get owner rfp) tx-sender) ERR-NOT-FOUND)
             (asserts! (> block-height (get reveal-dead rfp)) ERR-BAD-TIME)
             (map-set rfps { id: id } (merge rfp { winner: (some winner) }))
             (ok winner))
      none ERR-NOT-FOUND)))
