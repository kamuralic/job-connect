import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:job_connect/services/internet_check_provider.dart';
import 'package:provider/provider.dart';

class ConnectivityNotifierWidget extends StatelessWidget {
  const ConnectivityNotifierWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(builder: (context, model, child) {
      return model.isOnline
          ? Text('')
          : Container(
              alignment: Alignment.center,
              height: 40,
              width: MediaQuery.of(context).size.width,
              color: Colors.red,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SpinKitFadingCircle(
                  size: 30,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text('No Internet Connection',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ]));
    });
  }
}
