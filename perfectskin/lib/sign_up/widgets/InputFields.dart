import 'package:flutter/material.dart';

class InputFieldArea extends StatelessWidget {
  final String hint;
  final bool obscure;
  final IconData icon;
  final TextEditingController controller;

  InputFieldArea({this.hint, this.obscure, this.icon, this.controller});
  @override
  Widget build(BuildContext context) {
    return (new Container(
      height: MediaQuery.of(context).size.height * 0.11,
      decoration: new BoxDecoration(
        border: new Border(
          bottom: new BorderSide(
            width: 2,
            color: Colors.white24,
          ),
        ),
      ),
      child: new TextFormField(
        obscureText: obscure,
        controller: controller,
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration: new InputDecoration(
          icon: new Icon(
            icon,
            color: Colors.white,
            size: MediaQuery.of(context).size.width * 0.077,
          ),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.04,
          ),
          contentPadding: EdgeInsets.only(
              top: 30.0,
              right: 30.0,
              bottom: MediaQuery.of(context).size.height * 0.037,
              left: 5.0),
        ),
      ),
    ));
  }
}
