# Android Non-Invasive Inspection Sources

## Official Android Guidance Captured for the Device-Evidence Assessment

Android documents `dumpsys` as a device-side diagnostic tool invoked through Android Debug Bridge (ADB). It provides system-service information and can be scoped to a specific service rather than altering an application. This supports using ordinary package and network diagnostic output as **evidence collection**, not as an attempt to modify the target application. [1]

Android documents Network Security Configuration as an application-linked declarative configuration file. A manifest can point to it through `android:networkSecurityConfig`; the configuration may set trust anchors, cleartext policy, certificate pinning, domain-specific policy, and debugging overrides. Therefore, an APK/package inspection can establish whether such a declared resource is present, but it cannot establish the runtime behavior of a native host wrapper without host logs or documentation. [2]

Android documents Logcat as the ordinary log viewer for messages emitted by device processes. It can surface a host application's own diagnostic output if that host emits relevant records, but it cannot manufacture an `HttpWrapper` error category when the host emits none. [3]

## Source URLs

[1]: https://developer.android.com/tools/dumpsys "Android Developers — dumpsys"
[2]: https://developer.android.com/privacy-and-security/security-config "Android Developers — Network security configuration"
[3]: https://developer.android.com/studio/debug/logcat "Android Developers — View logs with Logcat"
