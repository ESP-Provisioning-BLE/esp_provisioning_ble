import 'package:example/src/features/ble_wifi_screen/bloc/ble_wifi_bloc.dart';
import 'package:example/src/features/ble_wifi_screen/components/password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WifiDialog extends StatefulWidget {
  final String wifiName;

  const WifiDialog({
    Key? key,
    required this.wifiName,
  }) : super(key: key);
  @override
  State<WifiDialog> createState() => _WifiDialogState();
}

class _WifiDialogState extends State<WifiDialog> {
  String? ssid = '';
  String ssidPassword = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    ssid = widget.wifiName;
  }

  @override
  Widget build(BuildContext context) {
    double sizeWidth = MediaQuery.of(context).size.width;
    double sizeHeight = MediaQuery.of(context).size.height;
    return Dialog(
      elevation: 5,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        height: sizeHeight * 0.3,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'Type the wifi password',
                  style: TextStyle(
                    fontSize: sizeHeight * 0.02,
                  ),
                ),
                SizedBox(
                  height: sizeHeight * 0.02,
                ),
                SizedBox(
                  width: sizeWidth * 0.8,
                  height: sizeHeight * 0.06,
                  child: TextFormField(
                    onSaved: (text) {
                      ssid = text;
                    },
                    initialValue: widget.wifiName,
                    readOnly: true,
                  ),
                ),
                SizedBox(
                  height: sizeHeight * 0.02,
                ),
                SizedBox(
                  child: PasswordField(
                    initialValue: ssidPassword,
                    onChanged: (text) {
                      ssidPassword = text;
                    },
                  ),
                ),
                SizedBox(height: sizeHeight * 0.02),
                SizedBox(
                  width: sizeWidth * 0.8,
                  height: sizeHeight * 0.05,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                      ),
                      child: Text(
                        'Connect',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          // fontSize: 2.h,
                          fontSize: sizeHeight * 0.02,
                        ),
                      ),
                      onPressed: () {
                        BlocProvider.of<BleWifiBloc>(context).add(
                          BleWifiSendConfigEvent(
                            ssid: ssid!,
                            password: ssidPassword,
                            customSendMessage: "Hello from app :)",
                          ),
                        );
                        Navigator.pop(context);
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
