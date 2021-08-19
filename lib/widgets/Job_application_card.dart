import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:job_connect/models/pop_up_menu_model.dart';
import 'package:job_connect/screens/applicationPages/applicationDetailsPage.dart';
import 'package:job_connect/services/authentication_services.dart';
import 'package:job_connect/services/storage_services.dart';
import 'package:job_connect/widgets/circular_progress_indicator.dart';
import 'package:job_connect/widgets/myPopUpMenu.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

import 'package:timeago/timeago.dart' as timeago;

class JobApplicationCard extends StatefulWidget {
  final Map<String, dynamic> applicationData;
  final String docId;
  const JobApplicationCard(
      {Key? key, required this.applicationData, required this.docId})
      : super(key: key);

  @override
  _JobApplicationCardState createState() => _JobApplicationCardState();
}

class _JobApplicationCardState extends State<JobApplicationCard> {
  late List<PopUpMenuModel> menuItems;
  CustomPopupMenuController _controller = CustomPopupMenuController();
  String status = 'pending';

  @override
  void initState() {
    menuItems = [
      PopUpMenuModel('Approve', Icons.done),
      PopUpMenuModel('Decline', Icons.close)
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    StorageService storageServiceProvider = context.read<StorageService>();
    final authProvider = context.read<AuthenticationService>();
    String timeSent = timeago.format(DateTime.fromMicrosecondsSinceEpoch(
        widget.applicationData['postDate']));
    return Card(
      child: Container(
        margin: EdgeInsets.only(left: 8, right: 8, top: 4),
        color: Colors.white,
        child: Column(
          children: [
            buildStatus(context),
            ListTile(
              onTap: () {
                //Navigate to job application Details page
                pushNewScreen(
                  context,
                  screen: JobApplicationDetailsPage(
                    docId: widget.docId,
                  ),
                  withNavBar: false,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              contentPadding: EdgeInsets.all(8),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: widget.applicationData['applicantImageUrl'] == null
                    ? Container(
                        padding: EdgeInsets.all(4),
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.person,
                          size: 39,
                          color: Colors.red,
                        ),
                      )
                    : CachedNetworkImage(
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                        imageUrl: widget.applicationData['applicantImageUrl'],
                        placeholder: (context, url) =>
                            MyCircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
              ),
              subtitle: Text(widget.applicationData['jobTitle'],
                  style: Theme.of(context)
                      .textTheme
                      .headline5!
                      .copyWith(color: Colors.black)),
              title: Text(widget.applicationData['applicantName'],
                  style: Theme.of(context).textTheme.headline2),
              trailing: authProvider.currentFirebaseUser!.uid ==
                      widget.applicationData['applicantId']
                  ? Text('')
                  : MyPopUpMenu(
                      menuItems: menuItems,
                      storageServiceProvider: storageServiceProvider,
                      applicationId: widget.docId,
                      controller: _controller),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(timeSent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Row buildStatus(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        widget.applicationData['status'] == 'Pending'
            ? Container(
                padding: EdgeInsets.all(4),
                decoration: new BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: BoxConstraints(
                  minWidth: 12,
                  minHeight: 12,
                ),
                child: Center(
                  child: new Text(
                    widget.applicationData['status'],
                    style: new TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Container(
                padding: EdgeInsets.all(4),
                decoration: new BoxDecoration(
                  color: widget.applicationData['status'] == 'Declined'
                      ? Theme.of(context).primaryColor
                      : Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: BoxConstraints(
                  minWidth: 12,
                  minHeight: 12,
                ),
                child: Center(
                  child: new Text(
                    widget.applicationData['status'],
                    style: new TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
      ],
    );
  }
}
