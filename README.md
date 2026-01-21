# PhotographerLens

A decentralized Intellectual Property protection platform for photographers built on the Stacks blockchain using Clarity smart contracts.

## Overview

PhotographerLens enables photographers to timestamp their original photos on the blockchain, establishing immutable prior art proof against copyright infringement. Each photo registration is permanently recorded with a cryptographic hash and Bitcoin block height timestamp.

## Features

- **Immutable Timestamping**: Photos are timestamped using Bitcoin block height via Stacks
- **Hash-based Verification**: Each photo is identified by its SHA-256 hash, preventing duplicates
- **Ownership Proof**: Blockchain-verified proof of who registered the photo first
- **Portfolio Tracking**: Complete record of all photos registered by each photographer
- **Update Capability**: Photographers can update titles and descriptions while preserving original timestamp

## How It Works

1. **Photo Registration**: Photographer generates a SHA-256 hash of their original photo
2. **Blockchain Recording**: Hash, metadata, and timestamp are permanently stored on Stacks
3. **Prior Art Establishment**: The Bitcoin block height proves when the work was created
4. **Verification**: Anyone can verify ownership and registration time using the photo hash

## Smart Contract Functions

### Public Functions

#### `register-photo`
Register a new photo with its cryptographic hash.

```clarity
(register-photo 
  (photo-hash (buff 32))
  (title (string-ascii 100))
  (description (string-ascii 500)))
```

**Parameters:**
- `photo-hash`: SHA-256 hash of the photo (32 bytes)
- `title`: Photo title (max 100 characters)
- `description`: Photo description (max 500 characters)

**Returns:** `(ok photo-id)` on success

**Errors:**
- `err-already-registered (u101)`: Photo hash already exists

---

#### `update-photo-info`
Update the title and description of a registered photo (photographer only).

```clarity
(update-photo-info
  (photo-id uint)
  (new-title (string-ascii 100))
  (new-description (string-ascii 500)))
```

**Parameters:**
- `photo-id`: ID of the photo to update
- `new-title`: New photo title
- `new-description`: New photo description

**Returns:** `(ok true)` on success

**Errors:**
- `err-not-found (u102)`: Photo doesn't exist
- `err-unauthorized (u103)`: Caller is not the photographer

---

### Read-Only Functions

#### `get-photo`
Retrieve complete photo information by ID.

```clarity
(get-photo (photo-id uint))
```

**Returns:** Photo data including photographer, hash, title, description, timestamp, and block height

---

#### `get-photo-by-hash`
Look up a photo using its cryptographic hash.

```clarity
(get-photo-by-hash (photo-hash (buff 32)))
```

**Returns:** Photo data if found, none otherwise

---

#### `get-photographer-photo-count`
Get the total number of photos registered by a photographer.

```clarity
(get-photographer-photo-count (photographer principal))
```

**Returns:** `{ count: uint }`

---

#### `get-photographer-photo-at-index`
Retrieve a specific photo from a photographer's portfolio.

```clarity
(get-photographer-photo-at-index 
  (photographer principal) 
  (index uint))
```

**Returns:** Photo data at the specified index

---

#### `get-total-photos`
Get the total number of photos registered on the platform.

```clarity
(get-total-photos)
```

**Returns:** `uint` - total photo count

---

#### `verify-ownership`
Verify if a specific photographer owns a photo.

```clarity
(verify-ownership 
  (photo-id uint) 
  (photographer principal))
```

**Returns:** `(ok true)` if photographer owns the photo, `(ok false)` otherwise

---

## Usage Example

### Registering a Photo

1. Generate SHA-256 hash of your photo file
2. Call the `register-photo` function:

```clarity
(contract-call? .photographer-lens register-photo 
  0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
  "Sunset Over Lagos"
  "Captured at Lekki Beach during golden hour, January 2026")
```

### Verifying a Photo

Check if a photo hash is already registered:

```clarity
(contract-call? .photographer-lens get-photo-by-hash
  0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef)
```

### Viewing Your Portfolio

```clarity
;; Get your photo count
(contract-call? .photographer-lens get-photographer-photo-count tx-sender)

;; Get your first photo
(contract-call? .photographer-lens get-photographer-photo-at-index tx-sender u0)
```

## Data Structure

Each registered photo contains:

```clarity
{
  photographer: principal,      // Stacks address of the photographer
  photo-hash: (buff 32),        // SHA-256 hash of the photo
  title: (string-ascii 100),    // Photo title
  description: (string-ascii 500), // Photo description
  timestamp: uint,              // Bitcoin block height when registered
  block-height: uint            // Bitcoin block height (redundant for clarity)
}
```

## Error Codes

- `u100`: Owner-only operation (currently unused)
- `u101`: Photo hash already registered
- `u102`: Photo not found
- `u103`: Unauthorized operation

## Security Considerations

- **Immutability**: Photo hashes and timestamps cannot be changed once registered
- **Uniqueness**: Each photo hash can only be registered once
- **Ownership**: Only the original photographer can update photo metadata
- **Transparency**: All registrations are publicly verifiable on the blockchain

## Legal Use Cases

- **Copyright Protection**: Establish prior art for copyright claims
- **Infringement Defense**: Prove you created the work before alleged infringement
- **Licensing**: Verify ownership before licensing negotiations
- **Portfolio Authentication**: Prove authenticity of your work to clients

## Deployment

Deploy this contract to the Stacks blockchain using Clarinet or the Stacks CLI:

```bash
clarinet contract deploy photographer-lens
```

## Testing

Run tests using Clarinet:

```bash
clarinet test
```


## Contributing

Contributions are welcome! Please submit pull requests or open issues for improvements.

## Disclaimer

This smart contract provides technical proof of timestamp and ownership on the blockchain. It does not constitute legal advice. Consult with an intellectual property attorney for legal matters regarding copyright and infringement cases.