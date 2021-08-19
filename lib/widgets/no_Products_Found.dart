import 'package:flutter/material.dart';

class NoProductsFound extends StatelessWidget {
  const NoProductsFound({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 120,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No Jobs Found',
            style: Theme.of(context).textTheme.headline3,
          ),
          SizedBox(
            height: 10,
          ),
          Image.asset(
            './assets/images/search.png',
            height: 150,
            width: 150,
          ),
        ],
      ),
    );
  }
}
