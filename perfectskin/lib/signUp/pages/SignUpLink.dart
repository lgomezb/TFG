import 'package:flutter/material.dart';
import 'package:perfectskin/utils/MyLocalizationsDelegate.dart';

class SignUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return (new FlatButton(
      onPressed: () {
        changePwd("¿A qué email deseas cambiar la contraseña?", context);
      },
      child: new Text(
        MyLocalizations.of(context).getText('forgot'),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        style: new TextStyle(
            fontWeight: FontWeight.w300,
            letterSpacing: 0.5,
            fontFamily: 'Dosis',
            color: Colors.white,
            fontSize: 15.0),
      ),
    ));
  }

  void agree(String value, BuildContext context) {
    AlertDialog dialog = new AlertDialog(
      title: Center(child: Text(value)),
      content: Container(
        height: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Text(
                MyLocalizations.of(context).getText('forgotten'),
              ),
            ),
          ],
        ),
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      actions: <Widget>[
        new FlatButton(
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop('dialog');
          },
          child: new Text(
            MyLocalizations.of(context).getText('agreed'),
          ),
        ),
      ],
    );

    showDialog(context: context, builder: (_) => dialog);
  }

  void changePwd(String value, BuildContext context) {
    final nombreController = TextEditingController();

    AlertDialog dialog = new AlertDialog(
      title: new Center(
          child: Text(
            "• " + value + " •",
          )),
      content: Container(
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 70,
              margin: new EdgeInsets.symmetric(horizontal: 5.0),
              child: TextField(
                maxLength: 70,
                style: TextStyle(color: Colors.black, fontSize: 15.0),
                controller: nombreController,
                decoration: InputDecoration.collapsed(
                  hintText: MyLocalizations.of(context).getText('emailrec'),
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      actions: <Widget>[
        FlatButton(
          child: Text(
            MyLocalizations.of(context).getText('continue'),
          ),
          onPressed: () {
            if (nombreController.text != "" &&
                nombreController.text.contains("@")) {
              //usuario.resetPassword(nombreController.text);
              Navigator.of(context, rootNavigator: true).pop('dialog');
              agree(MyLocalizations.of(context).getText('info'), context);
            }
          },
        ),
      ],
    );

    showDialog(context: context, builder: (_) => dialog);
  }
}
