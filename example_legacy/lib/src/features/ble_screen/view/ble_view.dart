import 'package:app_settings/app_settings.dart';
import 'package:example/src/features/ble_screen/bloc/ble_bloc.dart';
import 'package:example/src/features/ble_screen/components/prefix_form.dart';
import 'package:example/src/features/ble_screen/components/scan_again_ble_button.dart';
import 'package:example/src/features/shared/scan_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class BleView extends StatefulWidget {
  const BleView({super.key});

  @override
  State<BleView> createState() => _BleViewState();
}

class _BleViewState extends State<BleView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    BlocProvider.of<BleBloc>(context).add(BleInitialEvent());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    BlocProvider.of<BleBloc>(context).add(BleStopScanEvent());
    super.dispose();
  }

  final _controller = TextEditingController(text: 'PROV_');

  @override
  Widget build(BuildContext context) {
    double sizeWidth = MediaQuery.of(context).size.width;
    double sizeHeight = MediaQuery.of(context).size.height;
    var customPadding = SizedBox(
      height: sizeHeight * 0.05,
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        centerTitle: true,
        title: const Text(
          "Ble Provisioning",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: BlocBuilder<BleBloc, BleState>(
        builder: (context, state) {
          if (state is BleDisabledState) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
                },
                child: const Text('Turn on bluetooth'),
              ),
            );
          } else if (state is BlePermissionDeniedForever) {
            return const Center(
              child: Text(
                'ble permission denied forever',
              ),
            );
          } else if (state is BlePermissionDeniedState) {
            return const Center(
              child: Text(
                'ble permission denied',
              ),
            );
          } else if (state is LocationDisabled) {
            return const Center(
              child: Text(
                'location disabled',
              ),
            );
          } else if (state is PermissionLocationDenied) {
            return const Center(
              child: Text(
                'location permission denied',
              ),
            );
          } else if (state is PermissionLocationDeniedForever) {
            return const Center(
              child: Text(
                'location permission deniedForever',
              ),
            );
          } else if (state is PermissionLocationUnableToDetermine) {
            return const Center(
              child: Text(
                'location permission unable to determine',
              ),
            );
          } else if (state is BleReadytoScan) {
            return const Center(
              child: Text(
                'ble ready to scan',
              ),
            );
          } else if (state is BleScanCompleted) {
            return Column(
              children: [
                customPadding,
                SizedBox(
                  width: sizeWidth * 0.8,
                  child: PrefixForm(
                    controller: _controller,
                  ),
                ),
                customPadding,
                ScanList(
                    items: state.foundedDevices,
                    icon: Icons.bluetooth,
                    onTap: (Map<String, dynamic> item, BuildContext context) {
                      BlocProvider.of<BleBloc>(context).add(BleStopScanEvent());
                      Navigator.pushNamed(
                        context,
                        '/BlePasswordView',
                        arguments: {
                          'peripheralMap': item,
                          'prefix': _controller.text,
                        },
                      );
                    }),
                (state.stopped != null && !state.stopped!)
                    ? SpinKitRipple(
                        color: Colors.purple,
                        size: sizeHeight * 0.1,
                      )
                    : const SizedBox(
                        height: 0.01,
                      ),
                SizedBox(
                    width: sizeWidth * 0.8,
                    child: ScanAgainButton(
                      stopped: state.stopped,
                      prefix: _controller.text,
                    )),
                customPadding,
                customPadding,
              ],
            );
          } else if (state is BleEmptyList) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: sizeWidth * 0.8,
                    child: PrefixForm(
                      controller: _controller,
                    ),
                  ),
                  Text(
                    'NOT FOUND',
                    style: TextStyle(
                      fontSize: sizeHeight * 0.03,
                    ),
                  ),
                  ScanAgainButton(
                    stopped: true,
                    prefix: _controller.text,
                  )
                ],
              ),
            );
          } else if (state is BleScanningError) {
            return const Center(child: Text('ble scan error'));
          } else if (state is BleEmptyList) {
            return const Center(child: Text('ble empty list'));
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
