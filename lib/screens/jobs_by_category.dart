import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:job_connect/services/data_helpers_provider.dart';
import 'package:job_connect/services/searchService.dart';
import 'package:job_connect/services/storage_services.dart';
import 'package:job_connect/widgets/circular_progress_indicator.dart';
import 'package:job_connect/widgets/jobTypeListWidget.dart';
import 'package:job_connect/widgets/no_Products_Found.dart';
import 'package:job_connect/widgets/productsGrid.dart';
import 'package:job_connect/widgets/searchBar.dart';
import 'package:provider/provider.dart';

class JobsByCategory extends StatefulWidget {
  static const id = 'JobsByCategory';
  const JobsByCategory({Key? key}) : super(key: key);

  @override
  _JobsByCategoryState createState() => _JobsByCategoryState();
}

class _JobsByCategoryState extends State<JobsByCategory> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      StorageService storageServiceProvider = context.read<StorageService>();
      SearchService searchServiceProvider = context.read<SearchService>();
      DataHelpersProvider _dataHelpersProvider =
          context.read<DataHelpersProvider>();

      //set job type to null so that the page starts with all jobs
      //if (_dataHelpersProvider.type != null) _dataHelpersProvider.setType(null);
      //populate jobs from firebase locally
      storageServiceProvider.jobs
          .where('category', isEqualTo: _dataHelpersProvider.category)
          .get()
          .then((value) {
        //this is to populate a local list for making searches to avoid direct search from firebase
        searchServiceProvider.addjobsLocally(value.docs);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    StorageService storageServiceProvider = context.watch<StorageService>();
    SearchService searchServiceProvider = context.read<SearchService>();
    DataHelpersProvider _dataHelpersProvider =
        context.read<DataHelpersProvider>();
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            bottom: searchField(
                context: context,
                hintText: 'Search for ${_dataHelpersProvider.category} jobs',
                searchServiceProvider:
                    searchServiceProvider), //this is the search field
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(bottom: 60, left: 8),
            )),
        SliverList(
            delegate: SliverChildListDelegate([
          JobTypeListWidgt(),
          Consumer<DataHelpersProvider>(
            builder: (context, notifier, _) {
              return Card(
                child: FutureBuilder<QuerySnapshot>(
                  future: storageServiceProvider.jobs
                      .where('category',
                          isEqualTo: _dataHelpersProvider.category)
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

                    List<QueryDocumentSnapshot> products = [];
                    if (notifier.type == null) {
                      products = snapshot.data!.docs;
                    } else
                      products = snapshot.data!.docs
                          .where((doc) => doc['jobType'] == notifier.type)
                          .toList();
                    return products.isEmpty
                        ? NoProductsFound()
                        : ProductsGrid(
                            productList: products,
                            isScrollable: false,
                          );
                  },
                ),
              );
            },
          )
        ]))
      ]),
    );
  }

  Query<Object?> jobsListByType(StorageService storageServiceProvider,
      DataHelpersProvider _dataHelpersProvider) {
    if (_dataHelpersProvider.type == null) {
      var list = storageServiceProvider.jobs
          .where('category', isEqualTo: _dataHelpersProvider.category);
      print('if null condition: $list');
      print(_dataHelpersProvider.type);

      return list;
    } else {
      var list = storageServiceProvider.jobs
          .where('category', isEqualTo: _dataHelpersProvider.category)
          .where('jobType', isEqualTo: _dataHelpersProvider.type);
      print('if not null condition: $list');
      print(_dataHelpersProvider.type);
      print(list);

      return list;
    }
  }
}
