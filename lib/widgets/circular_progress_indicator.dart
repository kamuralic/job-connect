import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// ignore: must_be_immutable
class MyCircularProgressIndicator extends StatelessWidget {
  double size;
  var color;
  MyCircularProgressIndicator({Key? key, this.size = 30, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCircle(
      size: size,
      color: color ?? Theme.of(context).iconTheme.color,
    );
  }
}
