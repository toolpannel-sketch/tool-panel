# Official Android HTTPS Evidence Notes

These notes preserve the external Android-platform facts used by the host-configuration assessment. They do **not** establish what the target BGMI host actually declares or uses.

Android’s network guidance states that an application performing network operations must declare `android.permission.INTERNET` and `android.permission.ACCESS_NETWORK_STATE` in its manifest. Both are normal install-time permissions. [1]

Android’s Network Security Configuration is an app-declared XML resource referenced through `android:networkSecurityConfig` in the application manifest. It can define domain-specific trust anchors, debug overrides, cleartext policy, certificate transparency, and certificate pinning. [2]

For HTTPS, Android validates the server certificate chain and hostname through its networking APIs. Official guidance identifies unknown CAs, self-signed certificates, and missing intermediates as common causes of TLS handshake failure. [3]

## References

[1]: https://developer.android.com/develop/connectivity/network-ops/connecting "Android Developers — Connect to the network"
[2]: https://developer.android.com/privacy-and-security/security-config "Android Developers — Network security configuration"
[3]: https://developer.android.com/privacy-and-security/security-ssl "Android Developers — Security with network protocols"
