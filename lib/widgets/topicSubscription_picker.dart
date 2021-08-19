import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:job_connect/services/storage_services.dart';
import 'package:job_connect/widgets/circular_progress_indicator.dart';
import 'package:job_connect/widgets/topicCard.dart';
import 'package:provider/provider.dart';

class TopicSubscriptionPicker extends StatelessWidget {
  final String userDocId;
  const TopicSubscriptionPicker({Key? key, required this.userDocId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    StorageService _storageServiceProvider = context.read<StorageService>();

    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          AppBar(
            title: Text('Choose Job Topic'),
          ),
          topicsList(
            _storageServiceProvider,
          ),
        ],
      ),
    );
  }

  Widget topicsList(
    StorageService _storageServiceProvider,
  ) {
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
                      child: TopicCard(doc: doc, userDocId: userDocId),
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
