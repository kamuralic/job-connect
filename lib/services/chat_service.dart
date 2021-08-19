import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatService {
  Map<String, dynamic> createChatRoomData(
      {required AsyncSnapshot<DocumentSnapshot<Object?>> snapshot,
      required User? currentUser}) {
    Map<String, dynamic> docData =
        snapshot.data!.data() as Map<String, dynamic>;
    //This is the job the buyer wants to bagain on
    Map<String, dynamic> job = {
      'jobId': snapshot.data!.id,
      'jobImage': docData['displayImageUrl'],
      'price': docData['price'],
      'title': docData['title'],
      'advertiser': docData['advertiser_id'],
    };
    //chatRoom participants are Seller and Buyer
    List<String> users = [docData['seller_id'], currentUser!.uid];

    //Chat room id will be Seller id + Buyer id + job id
    String chatRoomId =
        '${docData['advertiser_id']}.${currentUser.uid}.${snapshot.data!.id}';

    //Total chatdata to send to firestore
    Map<String, dynamic> chatData = {
      'chatRoomId': chatRoomId,
      'read': false,
      'users': users,
      'job': job,
      'lastChat': null,
      'lastChatTime': DateTime.now().microsecondsSinceEpoch,
    };
    return chatData;
  }
}
