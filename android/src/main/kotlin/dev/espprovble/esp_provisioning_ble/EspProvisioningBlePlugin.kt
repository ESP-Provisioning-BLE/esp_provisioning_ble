package dev.espprovble.esp_provisioning_ble

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import java.security.InvalidAlgorithmParameterException
import java.security.InvalidKeyException
import java.security.NoSuchAlgorithmException
import javax.crypto.Cipher
import javax.crypto.NoSuchPaddingException
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec

/** EspProvisioningBlePlugin */
class EspProvisioningBlePlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var cipher: Cipher

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "esp_provisioning_ble")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } 
    else if (call.method == "init") {
      val key: ByteArray? = call.argument("key")
      val iv: ByteArray? = call.argument("iv")
  
      val ivParameterSpec = IvParameterSpec(iv)
      val secretKeySpec = SecretKeySpec(key, 0, key?.size ?: 0, "AES")
      try {
          this.cipher = Cipher.getInstance("AES/CTR/NoPadding")
          this.cipher.init(Cipher.ENCRYPT_MODE, secretKeySpec, ivParameterSpec)
      } catch (e: NoSuchAlgorithmException) {
          e.printStackTrace()
      } catch (e: InvalidKeyException) {
          e.printStackTrace()
      } catch (e: InvalidAlgorithmParameterException) {
          e.printStackTrace()
      } catch (e: NoSuchPaddingException) {
          e.printStackTrace()
      }
  
      result.success(true)
  } else if (call.method == "crypt") {
      val data: ByteArray? = call.argument("data")
      val ret: ByteArray? = cipher?.update(data)
      result.success(ret)
  } else {
      result.notImplemented()
  }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
