import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:job_connect/screens/myAds_page.dart';
import 'package:job_connect/services/firebase_notifications_service.dart';
import 'package:path/path.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class StorageService {
  // Create a CollectionReference called users that references the firestore collection
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  //collection reference for jobs
  CollectionReference jobs = FirebaseFirestore.instance.collection('jobs');

  //collection reference for products
  CollectionReference jobApplications =
      FirebaseFirestore.instance.collection('jobApplications');

  // Collection Refrence for categories
  CollectionReference categories =
      FirebaseFirestore.instance.collection('categories');

  // Collection Refrence for job types
  CollectionReference jobTypes =
      FirebaseFirestore.instance.collection('jobTypes');

  //collection reference for products
  CollectionReference messages =
      FirebaseFirestore.instance.collection('messages');

  Future<QuerySnapshot> getUserById({required String uid}) async {
    final QuerySnapshot result = await users.where('uid', isEqualTo: uid).get();

    return result; //docData;
  }

  Future<void> addUser(
      {required uid,
      required userName,
      required email,
      phoneN0,
      photoUrl}) async {
    //Fist check if user info exists before adding him to firestore
    final QuerySnapshot result = await users.where('uid', isEqualTo: uid).get();
    List<DocumentSnapshot> document = result.docs;

// If user data doesent exist, Call the user's CollectionReference to add a new user
    if (document.length == 0) {
      return users
          .add({
            'uid': uid,
            'userName': userName,
            'photoUrl': photoUrl,
            'email': email,
            'phoneN0': phoneN0,
            'subscriptions': []
          })
          .then((value) {})
          .catchError((error) {
            print("Failed to add user: $error");
          });
    }
  }
// jobs functions
  //uploading job images

  Future<String?> uploadImage({
    required String filePath,
    required BuildContext context,
  }) async {
    File file = File(filePath);
    String imageName =
        'workPlaceImage/${DateTime.now().microsecondsSinceEpoch}';
    String? downloadUrl;

    try {
      await firebase_storage.FirebaseStorage.instance
          .ref(imageName)
          .putFile(file);
      //get download url
      downloadUrl = await firebase_storage.FirebaseStorage.instance
          .ref(imageName)
          .getDownloadURL();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          content: Text('Finished')));
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          content: Text(e.code)));
    }
    return downloadUrl;
  }

  //For uploading a list of images and return their urls
  Future<List<String>> uploadWorkPlaceImages(
      {required List<File> localImagesUrlList,
      required BuildContext context}) async {
    int imageCounter = 0;
    List<String> downloadUrls = [];
    for (File image in localImagesUrlList) {
      imageCounter++;
      //show snackbar on wen starting to upload
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          content: Text('Uploading Image $imageCounter.')));
      await uploadImage(filePath: image.path, context: context).then((value) {
        downloadUrls.add(value!);
      });
    }
    return downloadUrls;
  }

  Future<DocumentSnapshot> getProductdetails(id) async {
    DocumentSnapshot doc = await jobs.doc(id).get();
    return doc;
  }

  Future<void> uploadJobAd(
      {required BuildContext context,
      required String currentUserId,
      required String title,
      required List<File> imageUrls,
      required String category,
      required String type,
      required String location,
      required String salary,
      required String requirements,
      required String phoneN0,
      required String description,
      required String company}) async {
    //First upload the product images and retrieve image urls, then appload the form details with a list of image urls
    await uploadWorkPlaceImages(localImagesUrlList: imageUrls, context: context)
        .then((value) =>
            jobs // Call the jpbs CollectionReference to add a new job
                .add({
              'advertiser_id': currentUserId,
              'title': title,
              'company': company,
              'displayImageUrl': value[
                  0], //this is to avoid  unnessesary querying of the imageUrls array for only one image.
              'imageUrls': value,
              'category': category,
              'salary': salary,
              'jobType': type,
              'location': location,
              'requirements': requirements,
              'phoneN0': phoneN0,
              'description': description,
              'postDate': DateTime.now().microsecondsSinceEpoch,
              'favourites': []
            }).then((value) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green,
                  content: Text('Form Uploaded succesfully')));

              //remove all spaces from category name to make a topic
              String topic = category.replaceAll(new RegExp(r"\s+"), "");
              FirebaseNotificationsService.sendNotification(
                  subject: 'A new job has been Uploaded in $category Jobs',
                  title: title,
                  topic: topic);
              //Navigate to my Ads screen wen upload is complete
              pushNewScreenWithRouteSettings(
                context,
                settings: RouteSettings(name: MyAdsPage.id),
                screen: MyAdsPage(),
                withNavBar: true,
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            }).catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  //margin: EdgeInsets.only(bottom: 10),
                  content: Text('Failed to upload job')));
            }));
  }

  //Adding jobs to favourites
  updateFavourite(
      {required bool isLiked,
      required String jobId,
      required String userId,
      required BuildContext context}) {
    if (isLiked) {
      jobs.doc(jobId).update({
        'favourites': FieldValue.arrayUnion([userId]),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to Favourites.'),
        ),
      );
    } else {
      jobs.doc(jobId).update({
        'favourites': FieldValue.arrayRemove([userId])
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('removed from Favourites.'),
        ),
      );
    }
  }

  //Adding subscriptions to user
  updateSubscription(
      {required bool isSubscribed,
      required String topic,
      required String userId,
      required BuildContext context}) {
    if (isSubscribed) {
      users.doc(userId).update({
        'subscriptions': FieldValue.arrayUnion([topic]),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added Subscriptions.'),
        ),
      );
    } else {
      jobs.doc(userId).update({
        'subscriptions': FieldValue.arrayRemove([topic])
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed Subscription'),
        ),
      );
    }
  }

//Applications forms features

  //upload satus
  Dialog buildUploadStatus(firebase_storage.UploadTask task,
          BuildContext context, String fileName) =>
      Dialog(
        child: StreamBuilder<firebase_storage.TaskSnapshot>(
            stream: task.snapshotEvents,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final snap = snapshot.data!;
                final progress = snap.bytesTransferred / snap.totalBytes;
                final percentage = (progress * 100).toStringAsFixed(2);
                if (progress == 1) {
                  Navigator.of(context).pop(true);
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //file name
                    Text(
                      fileName,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),

                    //download progress
                    Text('$percentage %',
                        style: Theme.of(context).textTheme.headline4),
                  ],
                );
              } else
                return Container();
            }),
      );

  //upload document
  Future<String?> uploadDocument({
    required String filePath,
    required BuildContext context,
  }) async {
    File file = File(filePath);
    String documentName =
        'applicantsDocuments/${DateTime.now().microsecondsSinceEpoch}${basename(filePath)}';
    String? downloadUrl;

    try {
      //var ref = firebase_storage.FirebaseStorage.instance.ref(documentName);
      //firebase_storage.UploadTask task = ref.putFile(file);
      await firebase_storage.FirebaseStorage.instance
          .ref(documentName)
          .putFile(file);

      //get download url
      downloadUrl = await firebase_storage.FirebaseStorage.instance
          .ref(documentName)
          .getDownloadURL();

      //show upload status dialog
      /*showDialog(
          context: context,
          builder: (BuildContext context) {
            return buildUploadStatus(task, context, basename(filePath));
          });*/
      //show snack bar if upload complete
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          content: Text('Finished')));
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          content: Text(e.code)));
    }
    return downloadUrl;
  }

  Future<List<Map<String, String>>> uploadApplicationDocuments(
      {required List<File> localDocumentsUrlList,
      required BuildContext context}) async {
    int documentCounter = 0;
    List<Map<String, String>> downloadUrls = [];
    for (File document in localDocumentsUrlList) {
      documentCounter++;
      //show snackbar on wen starting to upload
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          content: Text('Uploading Document $documentCounter.')));
      await uploadDocument(filePath: document.path, context: context)
          .then((value) {
        downloadUrls
            .add({'documentName': basename(document.path), 'url': value!});
      });
    }
    return downloadUrls;
  }

  Future<void> uploadApplicationForm({
    required BuildContext context,
    required String currentUserId,
    required String advertiserId,
    required String jobTitle,
    required String phoneN0,
    required String email,
    required List<File> documentUrls,
    required String jobId,
    required String applicantName,
    String? applicantImageUrl,
  }) async {
    //First upload the product images and retrieve image urls, then appload the form details with a list of image urls
    await uploadApplicationDocuments(
            localDocumentsUrlList: documentUrls, context: context)
        .then((value) {
      return jobApplications // Call the jpbs CollectionReference to add a new job
          .add({
        'applicantId': currentUserId,
        'advertiserId': advertiserId,
        'email': email,
        'phoneN0': phoneN0,
        'jobTitle': jobTitle,
        'documentUrls': value,
        'jobId': jobId,
        'status': 'Pending',
        'applicantName': applicantName,
        'applicantImageUrl': applicantImageUrl,
        'postDate': DateTime.now().microsecondsSinceEpoch,
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            content: Text('Form Uploaded succesfully')));
        //Navigate to my Ads screen wen upload is complete
        /*pushNewScreenWithRouteSettings(
          context,
          settings: RouteSettings(name: MyAdsPage.id),
          screen: MyAdsPage(),
          withNavBar: true,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );*/
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            //margin: EdgeInsets.only(bottom: 10),
            content: Text('Failed to upload document')));
      });
    });
  }

  //changing application form status
  updateStatus(
      {required String applicationId,
      required String status,
      required BuildContext context}) {
    jobApplications.doc(applicationId).update({
      'status': status,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status changed to $status.'),
      ),
    );
  }

  // chating features
  Future<void> creatChatRoom({required Map<String, dynamic> chatData}) async {
    await messages.doc(chatData['chatRoomId']).set(chatData).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> updateChat(String chatRoomId, message) async {
    messages.doc(chatRoomId).collection('chats').add(message).catchError((e) {
      print(e.toString());
    });
    messages.doc(chatRoomId).update({
      'lastChat': message['message'],
      'lastChatTime': message['time'],
      'read': false
    });
  }

  Stream<QuerySnapshot<Object?>>? getChat(chatRoomId) {
    return messages
        .doc(chatRoomId)
        .collection('chats')
        .orderBy('time')
        .snapshots();
  }

  Future<void> deletChat(String chatRoomId) async {
    return messages.doc(chatRoomId).delete();
  }
}
