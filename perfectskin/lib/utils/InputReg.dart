import 'package:flutter/material.dart';

class InputReg extends StatelessWidget {
  final String hint;
  final bool obscure;
  final IconData icon;
  final TextEditingController controller;
  final int maxi;
  final FocusNode focusNode;
  TextCapitalization textCapitalization;

  InputReg(
      {this.hint,
      this.obscure,
      this.icon,
      this.controller,
      this.maxi,
      this.focusNode,
      @required this.textCapitalization});

  @override
  Widget build(BuildContext context) {
    return (new Container(
      decoration: new BoxDecoration(
        border: new Border(
          bottom: new BorderSide(width: 0.8, color: Theme.of(context).scaffoldBackgroundColor),
        ),
      ),
      child: new TextFormField(
        obscureText: obscure,
        textCapitalization: textCapitalization,
        maxLength: maxi,
        controller: controller,
        focusNode: focusNode,
        style: TextStyle(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        decoration: new InputDecoration(
          icon: new Icon(icon, color: Theme.of(context).scaffoldBackgroundColor),
          border: InputBorder.none,
          hintText: hint,
          counterText: "",
          hintStyle: TextStyle(
              color: Theme.of(context).scaffoldBackgroundColor,
              fontSize: MediaQuery.of(context).size.width * 0.045),
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
