import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:job_connect/services/authentication_services.dart';
import 'package:job_connect/services/storage_services.dart';
import 'package:job_connect/widgets/circular_progress_indicator.dart';
import 'package:job_connect/widgets/no_Products_Found.dart';
import 'package:job_connect/widgets/productsGrid.dart';
import 'package:provider/provider.dart';

class MyAdsPage extends StatelessWidget {
  static const id = 'MyAdsPage';
  const MyAdsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    StorageService storageServiceProvider = context.read<StorageService>();
    final authProvider = context.read<AuthenticationService>();
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
          appBar: AppBar(
            title: Text('My Job Ads'),
            bottom: TabBar(tabs: [
              Tab(
                text: 'Favourites',
              ),
              Tab(
                text: 'My Ads',
              ),
            ]),
          ),
          body: TabBarView(children: [
            Container(
              child: FutureBuilder<QuerySnapshot>(
                future: storageServiceProvider.jobs
                    .where('favourites',
                        arrayContains: authProvider.currentFirebaseUser!.uid)
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                        height: 300,
                        child: Center(child: MyCircularProgressIndicator()));
                  }

                  if (snapshot.data!.docs.length == 0) {
                    return NoProductsFound();
                  }
                  var products = snapshot.data!.docs;
                  return ProductsGrid(
                    productList: products,
                    isScrollable: true,
                  );
                },
              ),
            ),
            Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: storageServiceProvider.jobs
                    .where('advertiser_id',
                        isEqualTo: authProvider.currentFirebaseUser!.uid)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                        height: 300,
                        child: Center(child: MyCircularProgressIndicator()));
                  }

                  if (snapshot.data!.docs.length == 0) {
                    return NoProductsFound();
                  }
                  var products = snapshot.data!.docs;
                  return ProductsGrid(
                    productList: products,
                    isScrollable: true,
                  );
                },
              ),
            ),
          ])),
    );
  }
}
