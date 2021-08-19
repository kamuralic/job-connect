import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget myAlertDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Row(children: [
      SpinKitFadingCircle(
        size: 30,
        color: Colors.white,
      ),
      SizedBox(width: 8),
      Text('Please wait...')
    ]),
  );
  return alert;
}
