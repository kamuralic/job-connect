import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:job_connect/services/firebase_notifications_service.dart';
import 'package:job_connect/services/storage_services.dart';
import 'package:job_connect/widgets/circular_progress_indicator.dart';
import 'package:provider/provider.dart';

class TopicCard extends StatefulWidget {
  final QueryDocumentSnapshot doc;
  final String userDocId;
  const TopicCard({Key? key, required this.doc, required this.userDocId})
      : super(key: key);

  @override
  _TopicCardState createState() => _TopicCardState();
}

class _TopicCardState extends State<TopicCard> {
  bool isSubscribed = false;

  List subscriptions = [];

  @override
  void initState() {
    StorageService _storageProvider = context.read<StorageService>();

    String catName = widget.doc['catName'];
    String topic = catName.replaceAll(new RegExp(r"\s+"), "");

    _storageProvider.users.doc(widget.userDocId).get().then((value) {
      if (mounted)
        setState(() {
          subscriptions = value['subscriptions'];
        });
      if (subscriptions.contains(topic.trim())) {
        if (mounted)
          setState(() {
            isSubscribed = true;
          });
      } else {
        if (mounted)
          setState(() {
            isSubscribed = false;
          });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    StorageService _storageProvider = context.read<StorageService>();
    return CheckboxListTile(
      secondary: CachedNetworkImage(
        width: 60,
        imageUrl: widget.doc['imageUrl'],
        placeholder: (context, url) => MyCircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
      title: Text(
        widget.doc['catName'],
        maxLines: 2,
        style: TextStyle(color: Colors.black),
      ),
      value: isSubscribed,
      activeColor: Theme.of(context).accentColor,
      onChanged: (bool? value) {
        setState(() {
          isSubscribed = value!;
        });

        String catName = widget.doc['catName'];
        //remove all spaces from category name to make a topic
        String topic = catName.replaceAll(new RegExp(r"\s+"), "");
        print('topic: $topic');
        _storageProvider.updateSubscription(
            isSubscribed: isSubscribed,
            topic: topic,
            userId: widget.userDocId,
            context: context);
        if (isSubscribed = true) {
          FirebaseNotificationsService.subscribeToTopic(topic: topic);
        } else {
          FirebaseNotificationsService.unSubscribeFromTopic(topic: topic);
        }
      },
    );
  }
}
