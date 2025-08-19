# Skill Exchange Marketplace

A decentralized smart contract system for facilitating skill exchange opportunities through community interest voting.

## Overview

The Skill Marketplace platform connects individuals looking to exchange skills by allowing them to post opportunities and express interest in learning from others. The system tracks interest levels to help identify the most sought-after skill exchanges.

## Features

- **Opportunity Posting**: Users can post skill exchange opportunities
- **Interest Expression**: Community members can express interest in one opportunity per cycle
- **Demand Tracking**: Real-time tracking of interest levels for different skills
- **Community Matching**: Facilitates connections between skill providers and seekers

## Smart Contract Functions

### Public Functions
- `post-opportunity()` - Post a new skill exchange opportunity
- `express-interest(opportunity-id)` - Express interest in a specific opportunity

### Read-Only Functions
- `get-interest-level(opportunity-id)` - Get total interest count for an opportunity
- `has-expressed-interest(seeker)` - Check if user has expressed interest
- `get-total-opportunities()` - Get total number of posted opportunities

## Usage

Deploy the contract to create a decentralized skill exchange marketplace where community members can share knowledge and learn from each other through transparent interest-based matching.
\`\`\`

```clarity file="project-5-neighborhood-improvement/contracts/improvement-tracker.clar"
;; ImprovementTracker: A decentralized platform for neighborhood improvement initiative prioritization
;; Core Data Structures
(define-map residents principal uint)         ;; Tracks residents and their priority initiatives
(define-map improvement-initiatives uint uint) ;; Tracks initiatives and their priority scores
(define-data-var initiative-counter uint u0)  ;; Keeps count of total submitted initiatives

;; Public function to submit a new improvement initiative
(define-public (submit-initiative)
  (let ((initiative-id (+ (var-get initiative-counter) u1)))
    (map-set improvement-initiatives initiative-id u0) ;; Initialize priority for the new initiative to 0
    (var-set initiative-counter initiative-id)         ;; Increment initiative-counter
    (ok initiative-id)
  )
)

;; Public function to prioritize an improvement initiative
(define-public (prioritize-initiative (initiative-id uint))
  (let ((resident tx-sender))
    (if (is-some (map-get? residents resident))
        (err u7000)  ;; Error: Resident has already prioritized an initiative
        (if (is-none (map-get? improvement-initiatives initiative-id))
            (err u7001)  ;; Error: Improvement initiative does not exist
            (begin
              ;; Register the resident's priority choice
              (map-set residents resident initiative-id)
              ;; Increment the initiative's priority score
              (map-set improvement-initiatives initiative-id (+ (default-to u0 (map-get? improvement-initiatives initiative-id)) u1))
              (ok initiative-id)
            )
        )
    )
  )
)

;; Read-only function to get total priority score for an initiative
(define-read-only (get-priority-score (initiative-id uint))
  (default-to u0 (map-get? improvement-initiatives initiative-id))
)

;; Read-only function to check if a resident has prioritized any initiative
(define-read-only (has-prioritized (resident principal))
  (is-some (map-get? residents resident))
)

;; Read-only function to get the total number of initiatives
(define-read-only (get-total-initiatives)
  (var-get initiative-counter)
)

;; Read-only function to find the higher priority score
(define-read-only (max-priority (priority-a uint) (priority-b uint))
  (if (>= priority-a priority-b)
      priority-a
      priority-b
  )
)
