# Security Policy

`esp_provisioning_ble` implements the cryptographic handshake used to provision ESP32 devices over BLE (Security 1: Curve25519 key exchange with AES-CTR), so we take security reports seriously.

## Supported versions

Security fixes target the latest published `1.x` release. Please confirm you can reproduce the issue on the latest version before reporting.

| Version | Supported |
| ------- | :-------: |
| 1.x     | ✅        |
| < 1.0   | ❌        |

## Reporting a vulnerability

Please do not report security vulnerabilities through public issues.

The preferred channel is GitHub's [Private Vulnerability Reporting](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/security/advisories/new): open the repository's **Security** tab and choose **Report a vulnerability**. This creates a private advisory visible only to you and the maintainers.

If you prefer email, or cannot use GitHub, you can reach us privately at security@espprovble.dev.

We will acknowledge your report, work with you on a fix, and coordinate disclosure. Thank you for helping keep the project and its users safe.
