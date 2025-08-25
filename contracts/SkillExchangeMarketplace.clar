;; Skill Exchange Marketplace
;; Community-driven skill sharing platform

;; Define data structures
(define-map skill-offerings uint {
    teacher: principal,
    skill-category: (string-ascii 100),
    skill-description: (string-ascii 600),
    experience-level: (string-ascii 50),
    learner-interest: uint,
    endorsements: uint,
    is-available: bool
})

(define-map learner-interest {learner: principal, offering-id: uint} bool)
(define-data-var next-offering-id uint u1)

;; Offer a skill
(define-public (offer-skill (skill-category (string-ascii 100)) (skill-description (string-ascii 600)) (experience-level (string-ascii 50)))
    (let ((offering-id (var-get next-offering-id)))
        (map-set skill-offerings offering-id {
            teacher: tx-sender,
            skill-category: skill-category,
            skill-description: skill-description,
            experience-level: experience-level,
            learner-interest: u0,
            endorsements: u0,
            is-available: true
        })
        (var-set next-offering-id (+ offering-id u1))
        (ok offering-id)
    )
)

;; Express interest in learning
(define-public (express-interest (offering-id uint))
    (let ((offering (unwrap! (map-get? skill-offerings offering-id) (err u404)))
          (interest-key {learner: tx-sender, offering-id: offering-id}))
        (asserts! (get is-available offering) (err u400))
        (asserts! (is-none (map-get? learner-interest interest-key)) (err u403))
        
        (map-set learner-interest interest-key true)
        (map-set skill-offerings offering-id (merge offering {
            learner-interest: (+ (get learner-interest offering) u1),
            endorsements: (+ (get endorsements offering) u1)
        }))
        (ok true)
    )
)

;; Get skill offering details
(define-read-only (get-offering (offering-id uint))
    (map-get? skill-offerings offering-id)
)

;; Get interest metrics
(define-read-only (get-interest-metrics (offering-id uint))
    (match (map-get? skill-offerings offering-id)
        offering (ok {interest: (get learner-interest offering), endorsements: (get endorsements offering)})
        (err u404)
    )
)
