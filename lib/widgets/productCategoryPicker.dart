import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:job_connect/services/data_helpers_provider.dart';
import 'package:job_connect/services/storage_services.dart';
import 'package:provider/provider.dart';

import 'circular_progress_indicator.dart';

class ProductCategoryPicker extends StatelessWidget {
  const ProductCategoryPicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    StorageService _storageServiceProvider = context.read<StorageService>();
    DataHelpersProvider _sellerFormDataProvider =
        context.read<DataHelpersProvider>();

    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          AppBar(
            title: Text('Choose Category'),
          ),
          categoryList(_storageServiceProvider, _sellerFormDataProvider),
        ],
      ),
    );
  }

  Widget categoryList(StorageService _storageServiceProvider,
      DataHelpersProvider sellerFormDataProvider) {
    return FutureBuilder<QuerySnapshot>(
      future: _storageServiceProvider.categories.orderBy('catName').get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: MyCircularProgressIndicator());
        }

        return Expanded(
          child: ListView.builder(
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
                          sellerFormDataProvider.setCategory(doc['catName']);
                          Navigator.of(context).pop();
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
              }),
        );
      },
    );
  }
}
