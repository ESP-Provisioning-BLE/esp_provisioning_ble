# example

"A new Flutter project."

## Getting Started

In this example, we used the [flutter_ble_lib_ios_15](https://github.com/davejlin/flutter_ble_lib_ios_15) as the BLE Flutter package.

If you are also using this library, please make the following changes to your application:

1. Inside your `android/app/build.gradle` file, change the `minSdkVersion` to 21:

```gradle
minSdkVersion 21
```

2. Inside your `android/build.gradle` file, update the `ext.kotlin_version` to 1.9.0:

```gradle
ext.kotlin_version = '1.9.0'
```

3. Inside your `android/app/src/main/AndroidManifest.xml` file, add the following `uses-permission`:

```xml
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" android:minSdkVersion="29"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30"/>
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:minSdkVersion="31" android:usesPermissionFlags="neverForLocation"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
```