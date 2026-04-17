import 'package:flutter/material.dart';

class RestartApplicationButton extends StatelessWidget {
  final String textButton;
  const RestartApplicationButton({
    super.key,
    required this.textButton,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).popUntil(
          ModalRoute.withName('/ble'),
        );
      },
      child: Text(
        textButton,
        textAlign: TextAlign.center,
      ),
    );
  }
}
