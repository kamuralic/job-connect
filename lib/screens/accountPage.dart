import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:job_connect/services/authentication_services.dart';
import 'package:job_connect/services/storage_services.dart';
import 'package:job_connect/widgets/circular_progress_indicator.dart';
import 'package:job_connect/widgets/connectivity_notifier.dart';
import 'package:job_connect/widgets/topicSubscription_picker.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatelessWidget {
  static const id = 'AccountPage';
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storageServiceProvider = context.read<StorageService>();
    final authenticationServiceProvider = context.read<AuthenticationService>();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('Account'),
          ),
          body: SingleChildScrollView(
            child: FutureBuilder<QuerySnapshot>(
                future: storageServiceProvider.users
                    .where('uid',
                        isEqualTo: authenticationServiceProvider
                            .currentFirebaseUser!.uid)
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: MyCircularProgressIndicator());
                  }
                  var data = snapshot.data!.docs[0];

                  return Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        userImage(context, data),
                        applicantDetails(context, data),
                        topicSubscription(context, data),
                        SizedBox(
                          height: 20,
                        ),
                        logoutButton(context)
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

  Widget logoutButton(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              context.read<AuthenticationService>().logOut();
            },
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                padding: EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.shade400,
                        offset: Offset(2, 4),
                        blurRadius: 5,
                        spreadRadius: 2)
                  ],
                  color: Theme.of(context).iconTheme.color,
                ),
                child: Text(
                  'Logout',
                  style: Theme.of(context).textTheme.subtitle2,
                )),
          ),
        ),
      ],
    );
  }

  Widget topicSubscription(
      BuildContext context, QueryDocumentSnapshot<Object?> data) {
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
                  'Job Topics',
                  style: Theme.of(context).textTheme.headline3,
                ),
              ],
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return TopicSubscriptionPicker(userDocId: data.id);
                      });
                },
                title: Text('Subscribe To Jobs'),
                leading: Icon(
                  Icons.notifications,
                ),
                subtitle: Text(
                    'Get notified when jobs of desired category are posted'),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Card applicantDetails(
    BuildContext context,
    QueryDocumentSnapshot<Object?> data,
  ) {
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
                  'My Details',
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
                Text(data['userName'],
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
                Text(data['phoneN0'] ?? 'None',
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

  Widget userImage(
    BuildContext context,
    QueryDocumentSnapshot<Object?> data,
  ) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Theme.of(context).primaryColor,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: data['photoUrl'] == null
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
                  imageUrl: data['photoUrl'],
                  placeholder: (context, url) => MyCircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
        ),
      ),
    );
  }
}
