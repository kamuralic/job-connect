import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:job_connect/screens/categories_list_page.dart';
import 'package:job_connect/screens/jobs_by_category.dart';
import 'package:job_connect/services/data_helpers_provider.dart';
import 'package:job_connect/services/storage_services.dart';
import 'package:job_connect/widgets/circular_progress_indicator.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class CategoriesWidget extends StatefulWidget {
  const CategoriesWidget({Key? key}) : super(key: key);

  @override
  _CategoriesWidgetState createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget> {
  @override
  Widget build(BuildContext context) {
    final categoriesProvider = context.read<StorageService>();
    DataHelpersProvider _dataHelpersProvider =
        context.read<DataHelpersProvider>();
    return FutureBuilder<QuerySnapshot>(
      future: categoriesProvider.categories.orderBy('catName').get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
              height: 120, child: Center(child: MyCircularProgressIndicator()));
        }

        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(
                      "Job Categories",
                      style: Theme.of(context).textTheme.subtitle1,
                    )),
                    TextButton(
                        onPressed: () {
                          //thi is a navigator method from the nav bar package for correct routing
                          pushNewScreen(
                            context,
                            screen: CategoriesPage(),
                            withNavBar:
                                true, // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                          //Navigator.pushNamed(context, CategoriesPage.id);
                        },
                        child: Row(
                          children: [
                            Text('See All',
                                style: Theme.of(context).textTheme.headline4),
                            Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Theme.of(context).iconTheme.color,
                            ),
                          ],
                        ))
                  ],
                ),
              ),
              Container(
                height: 120,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.docs
                        .length, //Only show 3 categories ,, in case there are others, thyl be seen in categories page
                    itemBuilder: (BuildContext context, int index) {
                      var doc = snapshot.data!.docs[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            _dataHelpersProvider.setCategory(doc['catName']);
                            //Navigate to produccts page with this category
                            pushNewScreen(
                              context,
                              screen: JobsByCategory(),
                              withNavBar: true,
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          },
                          child: Container(
                              width: 64,
                              child: Column(
                                children: [
                                  CachedNetworkImage(
                                    height: 60,
                                    width: 60,
                                    imageUrl: doc['imageUrl'],
                                    placeholder: (context, url) =>
                                        MyCircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                  Text(
                                    doc['catName'],
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.black),
                                  )
                                ],
                              )),
                        ),
                      );
                    }),
              )
            ],
          ),
        );
      },
    );
  }
}
