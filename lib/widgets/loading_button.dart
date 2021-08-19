import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingButton extends StatelessWidget {
  final double? paddingValue;
  final color;
  const LoadingButton({Key? key, this.paddingValue, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        //width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: paddingValue ?? 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          color: color ?? Theme.of(context).iconTheme.color,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SpinKitFadingCircle(
            size: 30,
            color: Colors.white,
          ),
          SizedBox(width: 8),
          Text(
            'Please wait...',
            style: Theme.of(context).textTheme.subtitle2,
          )
        ]),
      ),
    );
  }
}
