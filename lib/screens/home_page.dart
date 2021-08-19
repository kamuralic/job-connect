import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:job_connect/services/searchService.dart';
import 'package:job_connect/services/storage_services.dart';
import 'package:job_connect/widgets/categories_widget.dart';
import 'package:job_connect/widgets/circular_progress_indicator.dart';
import 'package:job_connect/widgets/no_products_Found.dart';
import 'package:job_connect/widgets/productsGrid.dart';
import 'package:job_connect/widgets/searchBar.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  static const id = "home";
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

//this addPostFrameCallBack is being used only to ease the use of context in initstate
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      StorageService storageServiceProvider = context.read<StorageService>();
      SearchService searchServiceProvider = context.read<SearchService>();

      storageServiceProvider.jobs.get().then((value) {
        //this is to populate a local list for making searches to avoid direct search from firebase
        searchServiceProvider.addjobsLocally(value.docs);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    StorageService storageServiceProvider = context.read<StorageService>();
    SearchService searchServiceProvider = context.read<SearchService>();

    List<QueryDocumentSnapshot<Object?>> jobs;
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            bottom: searchField(
                searchServiceProvider: searchServiceProvider,
                context: context,
                hintText: 'Search Jobs'), //this is the search field
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(bottom: 60, left: 8),
              title: Text(
                "Get Your Dream Job",
                style: TextStyle(fontSize: 15),
              ),
            )),
        SliverList(
            delegate: SliverChildListDelegate([
          Card(child: CategoriesWidget()),
          Card(
              child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      "Recent Jobs",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ],
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: storageServiceProvider.jobs.snapshots(),
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
                  jobs = snapshot.data!.docs;

                  return ProductsGrid(
                    productList: jobs,
                    isScrollable: false,
                  );
                },
              ),
            ],
          ))
        ]))
      ]),
    );
  }
}
