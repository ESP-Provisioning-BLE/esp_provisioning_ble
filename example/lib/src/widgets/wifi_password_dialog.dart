import 'package:flutter/material.dart';

/// Dialog that prompts the user for a WiFi password before provisioning.
///
/// Returns a [WifiCredentials] record with the SSID, password, and optional
/// custom data message when the user taps "Connect". Returns null on cancel.
class WifiPasswordDialog extends StatefulWidget {
  final String ssid;

  const WifiPasswordDialog({super.key, required this.ssid});

  /// Shows the dialog and returns credentials, or null if cancelled.
  static Future<WifiCredentials?> show(
    BuildContext context, {
    required String ssid,
  }) {
    return showDialog<WifiCredentials>(
      context: context,
      builder: (_) => WifiPasswordDialog(ssid: ssid),
    );
  }

  @override
  State<WifiPasswordDialog> createState() => _WifiPasswordDialogState();
}

class _WifiPasswordDialogState extends State<WifiPasswordDialog> {
  final _passwordController = TextEditingController();
  final _customDataController = TextEditingController(text: 'Hello from app');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _customDataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.ssid),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'WiFi password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _customDataController,
            decoration: const InputDecoration(
              labelText: 'Custom data (optional)',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(
              context,
              WifiCredentials(
                ssid: widget.ssid,
                password: _passwordController.text,
                customData: _customDataController.text,
              ),
            );
          },
          child: const Text('Connect'),
        ),
      ],
    );
  }
}

/// Holds the WiFi credentials entered by the user.
class WifiCredentials {
  final String ssid;
  final String password;
  final String customData;

  const WifiCredentials({
    required this.ssid,
    required this.password,
    required this.customData,
  });
}
