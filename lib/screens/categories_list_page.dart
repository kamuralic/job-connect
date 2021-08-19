import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:job_connect/screens/jobs_by_category.dart';
import 'package:job_connect/services/data_helpers_provider.dart';
import 'package:job_connect/services/storage_services.dart';
import 'package:job_connect/widgets/circular_progress_indicator.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class CategoriesPage extends StatelessWidget {
  static const id = "categoriesList";
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoriesProvider = context.read<StorageService>();
    DataHelpersProvider _dataHelpersProvider =
        context.read<DataHelpersProvider>();
    return Scaffold(
        appBar: AppBar(
          title: Text('Categories'),
        ),
        body: FutureBuilder<QuerySnapshot>(
          future: categoriesProvider.categories.orderBy('catName').get(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: MyCircularProgressIndicator());
            }

            return ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  var doc = snapshot.data!.docs[index];
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          onTap: () {
                            //Navigate to jobs page with this category
                            _dataHelpersProvider.setCategory(doc['catName']);
                            //Navigate to jobs page with this category
                            pushNewScreen(
                              context,
                              screen: JobsByCategory(),
                              withNavBar: true,
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          },
                          title: Text(
                            doc['catName'],
                            maxLines: 2,
                            style: TextStyle(color: Colors.black),
                          ),
                          leading: CachedNetworkImage(
                            width: 60,
                            imageUrl: doc['imageUrl'],
                            placeholder: (context, url) =>
                                MyCircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                      ),
                      Divider()
                    ],
                  );
                });
          },
        ));
  }
}
