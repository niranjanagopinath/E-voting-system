# E-Voting System: Final Backend Architecture Walkthrough

This document is your "Master Guide" for understanding and presenting the entire backend system. It covers the technology, the security math, and how to demo the system.

---

## 1. The Tech Stack (What we used and Why)

| Layer | Technology | Rationale |
| :--- | :--- | :--- |
| **Language** | Python 3.11 | Industry standard for crypto-analysis and security. |
| **Framework** | **FastAPI** | High-performance, handles asynchronous requests (async/await). |
| **Database** | **PostgreSQL** | Relational integrity (ACID) ensures no vote is ever lost. |
| **ORM** | **SQLAlchemy 2.0** | Protects against SQL Injection; maps Python to Database tables. |
| **Security** | **PyCryptodome** | Enterprise-grade library for RSA Blind Signatures. |
| **MFA** | **PyOTP & WebAuthn** | Multi-factor auth using both time-codes and biometrics. |
| **Cache** | **Redis** | Fast session tracking and rate-limiting. |

---

## 2. Epic 1: Voter Access & Credentials (The Flow)

### 2.1 Identity Hashing (Privacy-First Login)
We never store raw IDs (like Aadhaar). Every ID is passed through a **Salted SHA-256 Hash**. 
*   **Location**: `backend/app/routers/auth.py` -> `hash_identity()`
*   **Benefit**: Even if the database is leaked, voter IDs remain unreadable.

### 2.2 Multi-Factor Authentication (MFA)
*   **TOTP**: 6-digit codes that reset every 30 seconds.
*   **Biometrics**: Passkey support (Fingerprint/FaceID) allowing cross-device login.
*   **Location**: `backend/app/routers/biometric.py` and `auth.py`.

### 2.3 Blind Signing (The Anonymity "Magic")
This process ensures the server knows you are eligible, but doesn't know what your token looks like.
1.  **Blinding**: Client hides the token.
2.  **Signing**: Server stamps the hidden token.
3.  **Unblinding**: Client reveals the signed token.
*   **Location**: `backend/app/core/security_core.py` -> `BlindSigner` class.

---

## 3. Database Architecture (The "Data Wall")

The database is split into four disconnected areas to prevent "tracking" a voter.

1.  **`Citizens`**: Salted list of eligible people. (Identity)
2.  **`Users`**: Current session, role (Admin/Voter), and MFA secrets. (Access)
3.  **`BlindTokens`**: Anonymous "Used Ticket" registry. Stores only hashes. (Privacy)
4.  **`AuditLogs`**: Tamper-evident ledger of all actions using **Hash-Chaining**. (Integrity)

> **The Anonymity Gap**: There is NO "Foreign Key" or link between the `Users` table and the `BlindTokens` table. This is by design.

---

## 4. Operational Toolkit (Demo Tools)

All these scripts are in your `backend/` folder:

*   **`view_db.py`**: The most important tool. Shows clean tables of all database content.
*   **`get_mfa_code.py`**: Generates a 6-digit code for the `admin` user if you are locked out.
*   **`disable_mfa.py`**: Emergency script to turn off MFA requirements for all users.
*   **`list_secrets.py`**: Shows the secret keys stored in the database.

---

## 5. Presentation Script: The "Carnival Analogy"

When presenting, use this story to explain the **Blind Token** logic:

1.  **Gate Guard (Auth)**: You show your ID at the Carnival gate. He checks you're on the list.
2.  **The Sealed Ticket (Blinding)**: You hold a ticket inside a carbon-paper envelope.
3.  **The Stamp (Signing)**: The guard stamps the *outside* of the envelope. The ink bleeds through.
4.  **The Private Reveal (Unblinding)**: You walk into a booth, open the envelope, and take out the stamped ticket. 
5.  **The Game (The Vote)**: You give the stamped ticket to a game operator. He sees it's valid, but has no idea who you are because he never saw you at the front gate!

---

## 6. Common Interview/Presentation Questions

**Q: How do you prevent double voting?**
> **A:** We store a SHA-256 hash of the used token in the `blind_tokens` table. If the same token comes back, the server sees the hash already exists and rejects it.

**Q: Can an Admin link my vote to my ID?**
> **A:** No. Mathematically, the blinded signature and unblinded signature look completely different. Architecturally, there is no database link connecting the two.

**Q: What if the database is reset?**
> **A:** We have hardcoded the MFA secret (`OUINEERXLD...`) in `main.py` for demo users, so your scripts will still work even after a full reset.
