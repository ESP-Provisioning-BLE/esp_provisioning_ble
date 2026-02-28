import 'package:example/src/features/ble_screen/bloc/ble_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScanAgainButton extends StatelessWidget {
  final bool? stopped;
  final String? prefix;
  const ScanAgainButton({super.key, this.stopped, this.prefix});

  @override
  Widget build(BuildContext context) {
    double sizeHeight = MediaQuery.of(context).size.height;
    return ElevatedButton(
      onPressed: () {
        if (stopped != null && stopped!) {
          BlocProvider.of<BleBloc>(context)
              .add(BleRestartingScanEvent(prefix: prefix));
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            (stopped == null || !stopped!) ? Colors.grey : Colors.purple,
      ),
      child: Text(
        'Scan again',
        style: TextStyle(
          fontSize: sizeHeight * 0.023,
          color: Colors.white,
        ),
      ),
    );
  }
}
