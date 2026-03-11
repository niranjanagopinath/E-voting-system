# Epic 1 Tech Stack: Database & Libraries Walkthrough

If you are asked, "How is this actually built?", use this guide to explain the tools and the data structure.

---

## 1. The Powerhouse Libraries (Frameworks)

### **A. FastAPI (The Engine)**
*   **Why?**: It's one of the fastest Python frameworks available.
*   **Best Feature**: It uses **Asynchronous (async/await)** logic, which allows the server to handle thousands of voters simultaneously without slowing down.
*   **Automatic Docs**: Mention that it automatically generates our API documentation at `/docs`.

### **B. SQLAlchemy (The Database Manager)**
*   **Why?**: It's an ORM (Object-Relational Mapper).
*   **Benefit**: It protects us from **SQL Injection** attacks because we never write raw SQL queries. Instead, we use Python classes to talk to the database.

### **C. PyCryptodome & Cryptography (The Security Guard)**
*   **Why?**: These handle the complex math for **RSA Blind Signatures**.
*   **Benefit**: They ensure our encryption follows modern industry standards (FIPS-compliant).

### **D. PyOTP & WebAuthn (The MFA Duo)**
*   **PyOTP**: Generates the 6-digit Time-based One-Time Passwords (TOTP).
*   **WebAuthn**: The library that lets us talk to your phone's fingerprint scanner or FaceID.

---

## 2. The Database Blueprint (PostgreSQL)

Our database is designed to **break the link** between identity and voting.

### **Table 1: `citizens` (The Source of Truth)**
*   **What it does**: This is like a copy of the National Census or Aadhaar database.
*   **Privacy**: We only store a **Salted Hash** of the ID. Even we don't know who the people are in this table!
*   **Usage**: Used only once during login to see if you are a real person who is allowed to vote.

### **Table 2: `users` (Session Management)**
*   **What it does**: Stores who is currently logged in, what their role is (Admin vs. Voter), and their MFA secret key.
*   **Security**: This table tracks `login_attempts` to lock out hackers after 5 failed tries.

### **Table 3: `blind_tokens` (The Anonymity Layer)**
*   **What it does**: When you vote, we check this table to see if your "Ticket" (Token) has been used.
*   **Crucial Point**: This table has **NO user_id**. It is completely disconnected from Table 1 and Table 2. This is the "Secret" to our anonymity.

### **Table 4: `audit_logs` (The Evidence)**
*   **What it does**: Records every major action (e.g., "Admin logged in", "Credential Issued").
*   **Security**: Each log entry is **Hash-Chained** to the previous one. If a hacker tries to delete a log, the chain breaks, and we instantly know the system was tampered with.

---

## 3. Deployment Stack
*   **Database**: PostgreSQL (Chosen for ACID compliance and reliability).
*   **Cache**: Redis (Used for fast rate-limiting and session tracking).
*   **Environment**: Docker (Ensures the app runs exactly the same on your computer and the server).

---

## **Summary for Presentation:**
> *"We chose **FastAPI** for its speed, **PostgreSQL** for its rock-solid data integrity, and **PyCryptodome** to mathematically guarantee voter privacy. By segregating the **Citizen** data from the **Voting Tokens**, we've built a system where the administrators can prove the election is fair, but can never prove how an individual voted."*
