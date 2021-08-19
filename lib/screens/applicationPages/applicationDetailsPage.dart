import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:job_connect/screens/pdfViewerPage.dart';
import 'package:job_connect/services/storage_services.dart';
import 'package:job_connect/widgets/circular_progress_indicator.dart';
import 'package:job_connect/widgets/connectivity_notifier.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class JobApplicationDetailsPage extends StatelessWidget {
  final String docId;
  const JobApplicationDetailsPage({
    Key? key,
    required this.docId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storageServiceProvider = context.read<StorageService>();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('Application Details'),
          ),
          body: SingleChildScrollView(
            child: FutureBuilder<DocumentSnapshot>(
                future: storageServiceProvider.jobApplications.doc(docId).get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: MyCircularProgressIndicator());
                  }

                  Map<String, dynamic> data =
                      snapshot.data!.data() as Map<String, dynamic>;
                  return Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        applicantImage(context, data),
                        applicantDetails(context, data),
                        Card(
                          elevation: 3,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            width: MediaQuery.of(context).size.width - 16,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Application Documents',
                                      style:
                                          Theme.of(context).textTheme.headline3,
                                    ),
                                  ],
                                ),
                                Divider(),
                                ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: data['documentUrls'].length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        onTap: () {
                                          final docUrl = data['documentUrls']
                                              [index]['url'];

                                          final name = data['documentUrls']
                                              [index]['documentName'];

                                          pushNewScreen(
                                            context,
                                            screen: PdfViewerPage(
                                              pdfName: name,
                                              url: docUrl,
                                            ),
                                            withNavBar: false,
                                            pageTransitionAnimation:
                                                PageTransitionAnimation
                                                    .cupertino,
                                          );
                                        },
                                        leading: Image.asset(
                                          './assets/images/pdf.png',
                                          height: 30,
                                          width: 30,
                                        ),
                                        title: Text(data['documentUrls'][index]
                                            ['documentName']),
                                      );
                                    })
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }),
          ),
        ),
        ConnectivityNotifierWidget(),
      ],
    );
  }

  Card applicantDetails(BuildContext context, Map<String, dynamic> data) {
    return Card(
      elevation: 3,
      child: Container(
        padding: EdgeInsets.all(8),
        width: MediaQuery.of(context).size.width - 16,
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Applicant Details',
                  style: Theme.of(context).textTheme.headline3,
                ),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Name',
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(fontWeight: FontWeight.bold)),
                Text(':',
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(fontWeight: FontWeight.bold)),
                Text(data['applicantName'],
                    style: Theme.of(context).textTheme.bodyText1),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Phone',
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(fontWeight: FontWeight.bold)),
                Text(':',
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(fontWeight: FontWeight.bold)),
                Text(data['phoneN0'],
                    style: Theme.of(context).textTheme.bodyText1),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Email',
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(fontWeight: FontWeight.bold)),
                Text(':',
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(fontWeight: FontWeight.bold)),
                Text(data['email'],
                    style: Theme.of(context).textTheme.bodyText1),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget applicantImage(BuildContext context, Map<String, dynamic> data) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Theme.of(context).primaryColor,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: data['applicantImageUrl'] == null
              ? Container(
                  padding: EdgeInsets.all(4),
                  color: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 100,
                    color: Colors.red,
                  ),
                )
              : CachedNetworkImage(
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                  imageUrl: data['applicantImageUrl'],
                  placeholder: (context, url) => MyCircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
        ),
      ),
    );
  }
}
