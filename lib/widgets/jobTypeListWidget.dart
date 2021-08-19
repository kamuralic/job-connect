import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:job_connect/services/data_helpers_provider.dart';
import 'package:job_connect/services/storage_services.dart';
import 'package:job_connect/widgets/circular_progress_indicator.dart';
import 'package:provider/provider.dart';

class JobTypeListWidgt extends StatelessWidget {
  const JobTypeListWidgt({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoriesProvider = context.read<StorageService>();
    DataHelpersProvider _dataHelpersProvider =
        context.read<DataHelpersProvider>();
    return FutureBuilder<QuerySnapshot>(
      future: categoriesProvider.jobTypes.orderBy('sortId').get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
              height: 120, child: Center(child: MyCircularProgressIndicator()));
        }

        return Card(
          child: Container(
            height: 120,
            child: Center(
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.docs
                      .length, //Only show 3 categories ,, in case there are others, thyl be seen in categories page
                  itemBuilder: (BuildContext context, int index) {
                    var doc = snapshot.data!.docs[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          _dataHelpersProvider.setType(doc['typeName']);
                          var name = doc['typeName'];
                          print('Job Type pressed: name = $name');
                          print(
                              'Job TYpe pressed: change type = ${_dataHelpersProvider.type}');
                        },
                        child: Container(
                            width: MediaQuery.of(context).size.width / 3 - 24,
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
                                  doc['typeName'],
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black),
                                )
                              ],
                            )),
                      ),
                    );
                  }),
            ),
          ),
        );
      },
    );
  }
}
