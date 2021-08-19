import 'package:flutter/material.dart';

class EmailVerificationScreen extends StatelessWidget {
  static const id = "EmailVerification";
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'logo',
                  child: Image.asset(
                    './assets/images/Logo.png',
                    height: 150,
                    width: 150,
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 30),
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verify Email',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Check your email to verify your registerd Email',
                    style: TextStyle(
                        fontSize: 15,
                        //color: Colors.red,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            InkWell(
              onTap: () {},
              child: Container(
                  width: MediaQuery.of(context).size.width - 20,
                  margin: EdgeInsets.symmetric(vertical: 20),
                  padding: EdgeInsets.symmetric(vertical: 10),
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
                    color: Theme.of(context).iconTheme.color,
                  ),
                  child: Text(
                    'Verify Email',
                    style: Theme.of(context).textTheme.subtitle2,
                  )),
            )
          ],
        ),
      ),
    );
  }
}
