# Epic 1: Voter Access & Credentials - Backend Explainer

This document provides a technical walkthrough of how to explain the **Epic 1** backend implementation. The primary goal of this epic is to ensure **High-Integrity Voter Authentication** while maintaining **Anonymity**.

---

## 1. The Core Philosophy: "Identification vs. Authorization"
*   **The Problem**: A standard login (User + Password) links your identity directly to your actions. 
*   **The Solution**: We verify identity at **Registration/Login**, but we issue a "Blind Token" for **Voting**. This decouples *who you are* from *what you voted*.

---

## 2. Step-by-Step Technical Flow

### A. Authentication & Eligibility (`auth.py`)
1.  **Identity Verification**: The system receives a credential (like an Aadhaar number). 
2.  **Hashing (US-1)**: We never store the raw ID. We use a **Salted SHA-256 Hash** to look up the voter in the `Citizen` database.
3.  **Eligibility DB**: We check if the hashed identity exists and matches requirements (Age, Citizenship, Not Deceased).

### B. Multi-Factor Authentication (`auth.py` & `biometric.py`)
*   **TOTP (US-2)**: Uses the `pyotp` library. Every 30 seconds, a new code is derived from a secret stored in the DB.
*   **WebAuthn (Biometrics)**: Uses the browser's hardware-backed security (Fingerprint/FaceID). This is the highest level of security.
*   **Why?**: To prevent credential theft. Even if an ID is leaked, the second factor is required.

### C. The Blind Signature Pipeline (The "Magic" Step)
This is typically the most impressive part of the presentation.
1.  **Request**: Voter logs in and asks for a credential.
2.  **Blinding**: The client (Frontend) generates a random "Blinding Factor" and masks the token.
3.  **Signing (`security_core.py`)**: The Backend signs the *masked* token using the System Private Key.
4.  **Unblinding**: The Voter's device removes the mask.
5.  **Result**: The Voter now has a valid certificate (Token) that the server signed, but the server *never saw* the final token.

---

## 3. Key Files to Highlight
*   `backend/app/routers/auth.py`: Handles the login logic and MFA verification.
*   `backend/app/core/security_core.py`: Implementation of the `BlindSigner` class—the heart of the privacy logic.
*   `backend/app/models/auth_models.py`: Shows how `User` and `BlindToken` tables are structured with **zero links** between them.

---

## 4. Rationale for presentation
If asked "Why this approach?", use these talking points:
*   **Privacy-by-Design**: We don't just "promise" not to look at your vote; the **mathematics** makes it impossible for us to know.
*   **Defense in Depth**: We use MFA + RBAC + Hashing to ensure multiple layers of security must fail before a breach occurs.
*   **Statelessness**: Using JWTs for sessions ensures the backend remains high-performance and scalable.

---

## 5. Typical presentation Flow
1.  **Voter Login**: Show the Aadhaar hashing.
2.  **MFA**: Explain why TOTP/Biometrics protect against mass identity theft.
3.  **Credential Issuance**: Walk through the "Blind Signing" math simply (use the envelope analogy).
4.  **RBAC**: Briefly show that an Admin cannot see Voter secrets.
