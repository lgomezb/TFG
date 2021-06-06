import 'package:flutter/material.dart';
import './InputFields.dart';

TextEditingController emailtext;
TextEditingController contratext;

class FormContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: new EdgeInsets.symmetric(horizontal: 20.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new Form(
              child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              new InputFieldArea(
                hint: "Email",
                controller: emailtext,
                obscure: false,
                icon: Icons.person_outline,
              ),
              new InputFieldArea(
                hint: "Password",
                controller: contratext,
                obscure: true,
                icon: Icons.lock_outline,
              ),
            ],
          )),
        ],
      ),
    );
  }
}
