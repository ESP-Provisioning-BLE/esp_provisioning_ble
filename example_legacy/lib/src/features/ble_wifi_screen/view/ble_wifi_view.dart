import 'package:example/src/features/ble_screen/components/restart_application_button.dart';
import 'package:example/src/features/ble_wifi_screen/bloc/ble_wifi_bloc.dart';
import 'package:example/src/features/ble_wifi_screen/components/scan_again_wifi_button.dart';
import 'package:example/src/features/ble_wifi_screen/components/wifi_dialog.dart';
import 'package:example/src/features/shared/scan_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class BleWifiView extends StatefulWidget {
  const BleWifiView({super.key});

  @override
  State<BleWifiView> createState() => _BleWifiViewState();
}

class _BleWifiViewState extends State<BleWifiView> {
  late BleWifiBloc _bleWifiBloc;
  @override
  void dispose() {
    _bleWifiBloc.add(BleWifiDisposeGetStatusEvent());
    super.dispose();
  }

  void _showDialog(
      {required String wifi,
      required dynamic instance,
      required BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WifiDialog(
          wifiName: wifi,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double sizeWidth = MediaQuery.of(context).size.width;
    double sizeHeight = MediaQuery.of(context).size.height;
    _bleWifiBloc = BlocProvider.of<BleWifiBloc>(context);
    var customPadding = SizedBox(
      height: sizeHeight * 0.05,
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        centerTitle: true,
        title: const Text(
          'Scan Wifi',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: BlocBuilder<BleWifiBloc, BleWifiState>(
        builder: (context, state) {
          if (state is BleWifiEstablishedConnectionState) {
            return Center(
              child: SizedBox(
                width: sizeWidth * 0.8,
                child: const ScanAgainWifiButton(),
              ),
            );
          } else if (state is BleWifiScannedNetworksState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  customPadding,
                  Text(
                    'List of founded Networks',
                    style: TextStyle(
                      fontSize: sizeHeight * 0.023,
                    ),
                  ),
                  customPadding,
                  ScanList(
                      icon: Icons.wifi,
                      items: state.foundedNetworks,
                      onTap: (Map<String, dynamic> item, BuildContext context) {
                        _showDialog(
                          wifi: item["ssid"],
                          instance: item["instance"],
                          context: context,
                        );
                      }),
                  SizedBox(
                    width: sizeWidth * 0.8,
                    child: const ScanAgainWifiButton(),
                  ),
                  customPadding,
                  customPadding,
                ],
              ),
            );
          } else if (state is BleWifiEstablishedConnectionKeyMismatch) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: sizeWidth,
                  child: const Text(
                    "Connection failed",
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Retype"),
                ),
              ],
            );
          } else if (state is BleWifiEstablishedConnectionFailedState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: sizeWidth,
                  child: const Text(
                    "Connection failed",
                    textAlign: TextAlign.center,
                  ),
                ),
                const RestartApplicationButton(
                  textButton: "established a Connection",
                ),
              ],
            );
          } else if (state is BleWifiConnectedState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Center(
                  child: Text("Provisioned!! ;)"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil(ModalRoute.withName('/'));
                  },
                  child: const Text(
                    "Go to Home",
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          } else if (state is BleWifiConnectionFailedState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Center(
                  child: Text(
                      "Failed!!! ${state.failedReason} \nIf your ESP32 has the function to retries, wait some time before click the button"),
                ),
                const RestartApplicationButton(
                  textButton: "Restart",
                ),
              ],
            );
          } else if (state is BleWifiDisconnectedState) {
            return const Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Center(
                  child: Text("Disconnected Device"),
                ),
                RestartApplicationButton(
                  textButton: "Restart",
                ),
              ],
            );
          } else {
            return const SpinKitRipple(
              color: Colors.purple,
            );
          }
        },
      ),
    );
  }
}
