;; PhotographerLens - IP Protection for Photographers
;; A simple platform to timestamp original photos and establish prior art

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-already-registered (err u101))
(define-constant err-not-found (err u102))
(define-constant err-unauthorized (err u103))

;; Data Variables
(define-data-var photo-count uint u0)

;; Data Maps
(define-map photos
    { photo-id: uint }
    {
        photographer: principal,
        photo-hash: (buff 32),
        title: (string-ascii 100),
        description: (string-ascii 500),
        timestamp: uint,
        block-height: uint
    }
)

(define-map photographer-photos
    { photographer: principal, index: uint }
    { photo-id: uint }
)

(define-map photographer-photo-count
    { photographer: principal }
    { count: uint }
)

(define-map hash-to-photo
    { photo-hash: (buff 32) }
    { photo-id: uint }
)

;; Read-only functions
(define-read-only (get-photo (photo-id uint))
    (map-get? photos { photo-id: photo-id })
)

(define-read-only (get-photo-by-hash (photo-hash (buff 32)))
    (match (map-get? hash-to-photo { photo-hash: photo-hash })
        entry (get-photo (get photo-id entry))
        none
    )
)

(define-read-only (get-photographer-photo-count (photographer principal))
    (default-to 
        { count: u0 }
        (map-get? photographer-photo-count { photographer: photographer })
    )
)

(define-read-only (get-photographer-photo-at-index (photographer principal) (index uint))
    (match (map-get? photographer-photos { photographer: photographer, index: index })
        entry (get-photo (get photo-id entry))
        none
    )
)

(define-read-only (get-total-photos)
    (var-get photo-count)
)

(define-read-only (verify-ownership (photo-id uint) (photographer principal))
    (match (get-photo photo-id)
        photo (ok (is-eq (get photographer photo) photographer))
        (err err-not-found)
    )
)

;; Public functions
(define-public (register-photo 
    (photo-hash (buff 32))
    (title (string-ascii 100))
    (description (string-ascii 500)))
    (let
        (
            (new-photo-id (+ (var-get photo-count) u1))
            (photographer tx-sender)
            (current-count (get count (get-photographer-photo-count photographer)))
        )
        ;; Check if hash already exists
        (asserts! (is-none (map-get? hash-to-photo { photo-hash: photo-hash })) err-already-registered)
        
        ;; Store photo data
        (map-set photos
            { photo-id: new-photo-id }
            {
                photographer: photographer,
                photo-hash: photo-hash,
                title: title,
                description: description,
                timestamp: burn-block-height,
                block-height: burn-block-height
            }
        )
        
        ;; Map hash to photo-id
        (map-set hash-to-photo
            { photo-hash: photo-hash }
            { photo-id: new-photo-id }
        )
        
        ;; Add to photographer's photo list
        (map-set photographer-photos
            { photographer: photographer, index: current-count }
            { photo-id: new-photo-id }
        )
        
        ;; Update photographer's photo count
        (map-set photographer-photo-count
            { photographer: photographer }
            { count: (+ current-count u1) }
        )
        
        ;; Update total photo count
        (var-set photo-count new-photo-id)
        
        (ok new-photo-id)
    )
)

(define-public (update-photo-info
    (photo-id uint)
    (new-title (string-ascii 100))
    (new-description (string-ascii 500)))
    (let
        (
            (photo (unwrap! (get-photo photo-id) err-not-found))
        )
        ;; Only the original photographer can update
        (asserts! (is-eq (get photographer photo) tx-sender) err-unauthorized)
        
        ;; Update photo info (keeping hash and timestamp unchanged)
        (map-set photos
            { photo-id: photo-id }
            (merge photo {
                title: new-title,
                description: new-description
            })
        )
        
        (ok true)
    )
)

;; Initialize contract
(begin
    (var-set photo-count u0)
)