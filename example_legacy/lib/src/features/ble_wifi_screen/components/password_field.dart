import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final FormFieldSetter<String>? onSaved;

  const PasswordField(
      {Key? key, this.initialValue, this.onChanged, this.onSaved})
      : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool isObscureText = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double sizeWidth = MediaQuery.of(context).size.width;
    double sizeHeight = MediaQuery.of(context).size.height;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: sizeWidth * 0.4,
          height: sizeHeight * 0.04,
          child: TextFormField(
            obscureText: isObscureText,
            initialValue: widget.initialValue,
            onChanged: widget.onChanged,
            onSaved: widget.onSaved,
          ),
        ),
        Container(
          width: sizeHeight * 0.02,
        ),
        SizedBox(
          width: sizeWidth * 0.18,
          height: sizeHeight * 0.04,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              setState(() {
                isObscureText = !isObscureText;
              });
            },
            child: Center(
              child: Icon(
                isObscureText ? Icons.remove_red_eye : Icons.lock_outline,
                color: Colors.white,
                size: sizeWidth * 0.07,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
