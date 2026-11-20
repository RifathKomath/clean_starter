# 🔒 Security & Data Protection Standard (10/10)

This guide documents the mandatory security invariants for the Go Safar codebase based on OWASP Mobile Application Security Verification Standards (MASVS).

---

## 1. Secure Credential & Token Management

- **Encrypted Storage Invariant**: Authentication tokens (access token, refresh token) must **never** be stored in plaintext `SharedPreferences` or local cache files.
- **Dedicated Token Service**: All token reads, writes, and erasures must flow strictly through `TokenService` backed by secure hardware-backed storage (iOS Keychain / Android Keystore / Encrypted Preferences).
- **Zero Plaintext Secrets in Code**:
  - API secrets, private keys, and environment tokens must **never** be committed as raw literals.
  - Runtime environment configuration must be injected via `FlavorConfig` and `--dart-define` flags.

---

## 2. Concurrency-Safe Authentication & Token Refresh

- **Queued Interceptors**: Network interceptors that handle 401 Unauthorized token renewals must extend Dio's `QueuedInterceptor` (e.g., `AuthInterceptor`).
- **Race Condition Prevention**:
  - When multiple concurrent network requests encounter a 401 token expiration, the interceptor must queue incoming requests, execute a single token refresh call, update `TokenService`, and replay the queued requests with the refreshed token.
  - Failed refresh tokens must immediately trigger secure token purge and safe navigation to the login route via `NavigationService`.

---

## 3. Data Privacy & Zero-PII Logging

- **No Sensitive Logging**:
  - `print()` or `debugPrint()` must **never** output passwords, OTPs, auth tokens, credit card numbers, or full personal identity information (PII).
  - Network request logs in production builds must redact `Authorization` headers and sensitive request bodies.
- **Dynamic Masking**:
  - Displayed phone numbers, OTP cards, and user credentials in the UI must be masked (e.g., `+91 9XXXXXXX`, `**** 1234`).

---

## 4. Transport Security & Network Hygiene

- **Mandatory HTTPS**: All endpoints in `ApiClient` and `FlavorConfig` must use `https://`. Cleartext HTTP traffic is strictly prohibited.
- **Strict Network Error Mapping**:
  - Network-level failures must never expose raw socket traces, stack traces, or server internals to end-user UI.
  - Map errors through `handleDioError()` into typed `ApiException` subclasses (`NetworkException`, `TimeoutException`, `ServerException`, `BadRequestException`).

---

## 5. Input Sanitization & Domain Validation

- **Pure Domain Validators**:
  - Phone numbers, email addresses, OTP codes, and custom user inputs must be validated by pure Dart validators (e.g., `AuthValidator`, `SeniorBookingValidator`, `TeensBookingValidator`) before being submitted to repositories or network clients.
  - Length, regex pattern matching, character sanitization, and whitespace stripping must occur prior to serialization.
