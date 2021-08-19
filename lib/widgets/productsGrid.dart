import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:job_connect/widgets/product_card.dart';

class ProductsGrid extends StatelessWidget {
  final List<QueryDocumentSnapshot<Object?>> productList;
  final bool isScrollable;
  const ProductsGrid({
    Key? key,
    required this.productList,
    required this.isScrollable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: StaggeredGridView.countBuilder(
        physics: isScrollable == true
            ? AlwaysScrollableScrollPhysics()
            : NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: productList.length,
        staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),

        //we devide screen width with 300 to get how many 300px cards fit in that width
        crossAxisCount: (screenWidth / 300).round(),

        itemBuilder: (BuildContext context, int index) {
          var doc = productList[index];
          return ProductCard(doc: doc, widthReducer: 32.0);
        },
      ),
    );
  }
}
