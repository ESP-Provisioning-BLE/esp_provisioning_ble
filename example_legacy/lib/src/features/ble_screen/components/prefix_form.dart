import 'package:flutter/material.dart';

class PrefixForm extends StatelessWidget {
  final TextEditingController controller;
  const PrefixForm({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    double sizeHeight = MediaQuery.of(context).size.height;
    return TextField(
      style: TextStyle(
        fontSize: sizeHeight * 0.03,
      ),
      onSubmitted: (value) async {},
      controller: controller,
    );
  }
}
