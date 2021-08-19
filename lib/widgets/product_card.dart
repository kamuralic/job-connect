import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/screens/product_details_page.dart';
import 'package:job_connect/services/authentication_services.dart';
import 'package:job_connect/services/storage_services.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'circular_progress_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProductCard extends StatefulWidget {
  final DocumentSnapshot doc;
  final double widthReducer;

  ProductCard({required this.doc, required this.widthReducer});

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isLiked = false;
  List fav = [];

  @override
  void initState() {
    StorageService _storageProvider = context.read<StorageService>();
    final _authProvider = context.read<AuthenticationService>();
    _storageProvider.jobs.doc(widget.doc.id).get().then((value) {
      if (mounted)
        setState(() {
          fav = value['favourites'];
        });
      if (fav.contains(_authProvider.currentFirebaseUser!.uid)) {
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
    double screenWidth = MediaQuery.of(context).size.width;
    StorageService _storageProvider = context.read<StorageService>();
    final _authProvider = context.read<AuthenticationService>();
    String timeSent = timeago
        .format(DateTime.fromMicrosecondsSinceEpoch(widget.doc['postDate']));
    return Container(
      width: screenWidth > 400 ? 300 : screenWidth - widget.widthReducer,
      margin: EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: () {
          pushNewScreen(
            context,
            screen: JobDetailsPage(
              args: widget.doc,
            ),
            withNavBar: false,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
        child: Card(
          elevation: 5.0,
          child: Column(
            children: <Widget>[
              //Product Image
              Stack(
                children: [
                  Container(
                    height: 170,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Hero(
                            tag: widget.doc.id,
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              //width: 60,
                              imageUrl: widget.doc['displayImageUrl'],
                              placeholder: (context, url) =>
                                  MyCircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                      right: 0.0,
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              _isLiked = !_isLiked;
                            });
                            //notifier.setIsLiked(value: !notifier.isLiked);
                            _storageProvider.updateFavourite(
                                isLiked: _isLiked,
                                jobId: widget.doc.id,
                                userId: _authProvider.currentFirebaseUser!.uid,
                                context: context);
                          },
                          icon: _isLiked == true
                              ? Icon(Icons.favorite)
                              : Icon(Icons.favorite_border))),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          //Job Type
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('Type: '),
                                Text(
                                  widget.doc['jobType'],
                                  style: Theme.of(context).textTheme.headline4,
                                  overflow: TextOverflow.fade,
                                  maxLines: 2,
                                  softWrap: true,
                                )
                              ]),
                          SizedBox(
                            height: 10,
                          ),
                          //Job Title
                          Hero(
                            tag: widget.doc.id + widget.doc['title'],
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.doc['title'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1!
                                        .copyWith(fontSize: 20),
                                    overflow: TextOverflow.fade,
                                    maxLines: 2,
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //Product Location
                          Row(children: [
                            Icon(Icons.place),
                            Expanded(
                              child: Text(
                                widget.doc['location'],
                                style: Theme.of(context).textTheme.headline3,
                                overflow: TextOverflow.fade,
                                maxLines: 2,
                                softWrap: true,
                              ),
                            )
                          ]),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.doc['description'],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  softWrap: true,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                            ],
                          ),
                          //Product Condition
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(4.0),
                                      child: Text(
                                        'Sent: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 4.0),
                                      child: Text(timeSent),
                                    ),
                                  ],
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        NumberFormat.simpleCurrency(
                                                name: 'UGX ', decimalDigits: 0)
                                            .format(int.parse(
                                                widget.doc['salary'])),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 20),
                                      ),
                                    ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
