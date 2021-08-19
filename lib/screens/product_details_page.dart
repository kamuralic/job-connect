import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/screens/applicationPages/applicationForm.dart';
import 'package:job_connect/services/authentication_services.dart';
import 'package:job_connect/services/storage_services.dart';
import 'package:job_connect/widgets/circular_progress_indicator.dart';
import 'package:job_connect/widgets/connectivity_notifier.dart';
import 'package:job_connect/widgets/loading_button.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailsPage extends StatefulWidget {
  static const id = 'jobDetails';
  final DocumentSnapshot args;
  const JobDetailsPage({
    Key? key,
    required this.args,
  }) : super(key: key);

  @override
  _JobDetailsPageState createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  bool _showProgressIndicator = false;
  bool _isLiked = false;
  List fav = [];

  @override
  void initState() {
    final storageServiceProvider = context.read<StorageService>();
    final authProvider = context.read<AuthenticationService>();
    storageServiceProvider.jobs.doc(widget.args.id).get().then((value) {
      if (mounted)
        setState(() {
          fav = value['favourites'];
        });
      if (fav.contains(authProvider.currentFirebaseUser!.uid)) {
        if (mounted)
          setState(() {
            _isLiked = true;
          });
      } else {
        if (mounted)
          setState(() {
            _isLiked = false;
          });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final storageServiceProvider = context.read<StorageService>();
    final authProvider = context.read<AuthenticationService>();

    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
              title: Text('job Details'),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isLiked = !_isLiked;
                      });
                      //notifier.setIsLiked(value: !notifier.isLiked);
                      storageServiceProvider.updateFavourite(
                          isLiked: _isLiked,
                          jobId: widget.args.id,
                          userId: authProvider.currentFirebaseUser!.uid,
                          context: context);
                    },
                    icon: _isLiked == true
                        ? Icon(Icons.favorite)
                        : Icon(Icons.favorite_border))
              ],
            ),
            body: SingleChildScrollView(
              child: FutureBuilder<DocumentSnapshot>(
                future: storageServiceProvider.jobs.doc(widget.args.id).get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: MyCircularProgressIndicator());
                  }

                  Map<String, dynamic> docData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  return Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            //disply image
                            Stack(
                              alignment: AlignmentDirectional.bottomStart,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 300,
                                  child: Center(
                                      child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      mainWorkPlaceImage(widget.args, docData),
                                    ],
                                  )),
                                ),
                                Positioned(
                                  child: workPlaceImagesVariationList(
                                      docData, widget.args),
                                )
                              ],
                            )
                          ],
                        ),
                        Card(
                          elevation: 3,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            width: MediaQuery.of(context).size.width - 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Badge for condition and date
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    jobType(docData),
                                    jobPostDate(docData)
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                //job Title
                                jobTitle(widget.args, docData, context),
                                SizedBox(
                                  height: 10,
                                ),

                                //job Location
                                jobLocation(docData, context),
                                SizedBox(
                                  height: 10,
                                ),

                                jobSalary(docData, context),
                              ],
                            ),
                          ),
                        ),

                        //Apply & Call  buttons
                        authProvider.currentFirebaseUser!.uid ==
                                docData['advertiser_id']
                            ? Text('')
                            : Container(
                                margin: EdgeInsets.symmetric(vertical: 15),
                                //Edit job button is only visible to the advertiser
                                child: Row(
                                  children: [
                                    //Chat button and call buttons are only visible to the Buyer
                                    if (_showProgressIndicator ==
                                        true) // this helps to put a left margin on the loading button since wraping is with container for magin brings error
                                      SizedBox(width: 8),
                                    _showProgressIndicator == true
                                        ? LoadingButton(
                                            paddingValue: 8,
                                            color: Colors.green,
                                          )
                                        : applyToJobButton(context),
                                    callButton(context, docData['phoneN0']),
                                  ],
                                ),
                              ),
                        jobRequirements(context, docData),
                        jobDescription(context, docData),
                        //get advertiser information and Feedback
                        advertiserInformation(
                            context, storageServiceProvider, docData),
                      ],
                    ),
                  );
                },
              ),
            )),
        ConnectivityNotifierWidget(),
      ],
    );
  }

  Card userFeedback(BuildContext context) {
    return Card(
      elevation: 3,
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.only(bottom: 20),
        width: MediaQuery.of(context).size.width - 16,
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Customer Feedback',
                  style: Theme.of(context).textTheme.headline3,
                ),
              ],
            ),
            Divider(),
            Column(
              children: [
                Icon(
                  Icons.rate_review,
                  size: 60,
                  color: HexColor("#BABABF"),
                ),
                Text(
                  'No Feedback Yet To This advertiser',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Expanded jobType(Map<String, dynamic> docData) {
    return Expanded(
      child: Text(
        docData['jobType'],
        style: Theme.of(context).textTheme.headline3,
        textAlign: TextAlign.left,
      ),
    );
  }

  Expanded jobPostDate(Map<String, dynamic> docData) {
    return Expanded(
      child: Text(
        'Posted On: ' +
            DateFormat.yMEd().format(
                DateTime.fromMicrosecondsSinceEpoch(docData['postDate'])),
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget advertiserInformation(BuildContext context,
      StorageService storageServiceProvider, Map<String, dynamic> docData) {
    return FutureBuilder<QuerySnapshot>(
        future:
            storageServiceProvider.getUserById(uid: docData['advertiser_id']),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: MyCircularProgressIndicator());
          }
          var doc = snapshot.data!.docs[0];
          return Column(
            children: [
              InkWell(
                child: Card(
                  elevation: 3,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    width: MediaQuery.of(context).size.width - 16,
                    child: Row(
                      children: [
                        //advertiser avatar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: doc['photoUrl'] == null
                              ? Container(
                                  padding: EdgeInsets.all(4),
                                  color: Colors.grey.shade200,
                                  child: Icon(
                                    Icons.person,
                                    size: 34,
                                    color: Colors.grey.shade600,
                                  ),
                                )
                              : CachedNetworkImage(
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  imageUrl: doc['photoUrl'],
                                  placeholder: (context, url) =>
                                      MyCircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doc['userName'],
                                  style: Theme.of(context).textTheme.subtitle1),
                              Text(docData['phoneN0'],
                                  style: Theme.of(context).textTheme.headline3),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              //User Feedback
              //userFeedback(context)
            ],
          );
        });
  }

  void makeCall(String number) async => await canLaunch('tel:$number')
      ? await launch('tel:$number')
      : throw 'Could not launch $number';

  Expanded callButton(BuildContext context, String number) {
    return Expanded(
      child: InkWell(
        onTap: () => makeCall(number),
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
              'Call',
              style: Theme.of(context).textTheme.subtitle2,
            )),
      ),
    );
  }

  Expanded editjobButton(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {},
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
              color: Colors.green,
            ),
            child: Text(
              'Edit job',
              style: Theme.of(context).textTheme.subtitle2,
            )),
      ),
    );
  }

  Widget applyToJobButton(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          pushNewScreen(
            context,
            screen: ApplicationForm(doc: widget.args),
            withNavBar: false,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
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
              color: Theme.of(context).accentColor, //Colors.green,
            ),
            child: Text(
              'Apply Now',
              style: Theme.of(context).textTheme.subtitle2,
            )),
      ),
    );
  }

  Card jobDescription(BuildContext context, Map<String, dynamic> docData) {
    return Card(
      elevation: 3,
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.only(bottom: 20),
        width: MediaQuery.of(context).size.width - 16,
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'job Description',
                  style: Theme.of(context).textTheme.headline3,
                ),
              ],
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    docData['description'],
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Row jobSalary(Map<String, dynamic> docData, BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
      Text(
        'Salary: ',
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      Text(
        NumberFormat.simpleCurrency(name: 'UGX ', decimalDigits: 0)
            .format(int.parse(docData['salary'])),
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
      ),
    ]);
  }

  Row jobLocation(Map<String, dynamic> docData, BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.place,
          color: HexColor("#BABABF"),
        ),
        Expanded(
          child: Text(
            docData['location'],
            style: Theme.of(context).textTheme.bodyText2,
            overflow: TextOverflow.fade,
            maxLines: 2,
            softWrap: false,
          ),
        ),
      ],
    );
  }

  Hero jobTitle(DocumentSnapshot<Object?> args, Map<String, dynamic> docData,
      BuildContext context) {
    return Hero(
      tag: args.id + docData['title'],
      child: Row(
        children: [
          Expanded(
            child: Text(
              docData['title'],
              style:
                  Theme.of(context).textTheme.headline4!.copyWith(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Container jobCondition(Map<String, dynamic> docData) {
    return Container(
      //width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.red,
      ),
      constraints: BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      child: Text(
        docData['condition'],
        style: TextStyle(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget mainWorkPlaceImage(
      DocumentSnapshot<Object?> args, Map<String, dynamic> docData) {
    return Container(
      height: 250,
      color: Colors.grey.shade300,
      child: Row(
        children: <Widget>[
          Expanded(
            child: FullScreenWidget(
              child: Hero(
                tag: args.id,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: docData['displayImageUrl'],
                  placeholder: (context, url) => MyCircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container workPlaceImagesVariationList(
      Map<String, dynamic> docData, DocumentSnapshot<Object?> args) {
    return Container(
      height: 100,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: docData['imageUrls'].length,
          itemBuilder: (BuildContext context, int index) {
            return FullScreenWidget(
              child: Center(
                child: Hero(
                  tag: args.id + index.toString(),
                  child: Card(
                    shadowColor: Colors.red,
                    elevation: 10,
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: docData['imageUrls'][index],
                      placeholder: (context, url) =>
                          MyCircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget jobRequirements(BuildContext context, Map<String, dynamic> docData) {
    return Card(
      elevation: 3,
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.only(bottom: 20),
        width: MediaQuery.of(context).size.width - 16,
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'job Requirements',
                  style: Theme.of(context).textTheme.headline3,
                ),
              ],
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    docData['requirements'],
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
