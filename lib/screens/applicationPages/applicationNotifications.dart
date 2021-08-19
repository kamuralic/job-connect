import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:job_connect/services/authentication_services.dart';
import 'package:job_connect/services/storage_services.dart';
import 'package:job_connect/widgets/Job_application_card.dart';
import 'package:job_connect/widgets/circular_progress_indicator.dart';
import 'package:provider/provider.dart';

class ApplicationsNotificationsPage extends StatelessWidget {
  const ApplicationsNotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    StorageService storageServiceProvider = context.read<StorageService>();
    final authProvider = context.read<AuthenticationService>();
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
          appBar: AppBar(
            title: Text('Job Applications'),
            bottom: TabBar(tabs: [
              Tab(
                text: 'Sent',
              ),
              Tab(
                text: 'Received',
              )
            ]),
          ),
          body: TabBarView(children: [
            Container(
              child: StreamBuilder<QuerySnapshot>(
                  stream: storageServiceProvider.jobApplications
                      .where('applicantId',
                          isEqualTo: authProvider.currentFirebaseUser!.uid)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Something went wrong'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                          child: Center(child: MyCircularProgressIndicator()));
                    }
                    if (snapshot.data!.docs.length == 0) {
                      return Center(
                          child: Text('You Havent Applied To Any Job'));
                    }

                    return Container(
                        child: ListView(
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        return JobApplicationCard(
                          docId: document.id,
                          applicationData: data,
                        );
                      }).toList(),
                    ));
                  }),
            ),
            Container(
              child: StreamBuilder<QuerySnapshot>(
                  stream: storageServiceProvider.jobApplications
                      .where('advertiserId',
                          isEqualTo: authProvider.currentFirebaseUser!.uid)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Something went wrong'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                          child: Center(child: MyCircularProgressIndicator()));
                    }
                    if (snapshot.data!.docs.length == 0) {
                      return Center(
                          child: Text('No Job Applications Set To You Yet'));
                    }

                    return Container(
                        child: ListView(
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        return JobApplicationCard(
                          docId: document.id,
                          applicationData: data,
                        );
                      }).toList(),
                    ));
                  }),
            ),
          ])),
    );
  }
}
