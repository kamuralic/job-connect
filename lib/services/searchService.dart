import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:job_connect/widgets/no_Products_Found.dart';
import 'package:job_connect/widgets/product_card.dart';
import 'package:job_connect/widgets/productsGrid.dart';
import 'dart:collection';

import 'package:search_page/search_page.dart';

class Job {
  final String title, category, description, salary;
  final num postDate;
  final DocumentSnapshot document;

  Job(
      {required this.title,
      required this.category,
      required this.description,
      required this.salary,
      required this.postDate,
      required this.document});
}

class SearchService with ChangeNotifier {
  List<Job> _localjobs = [];
  List<QueryDocumentSnapshot<Object?>> _firebasejobs = [];
  UnmodifiableListView<QueryDocumentSnapshot<Object?>> get firebasejobs =>
      UnmodifiableListView(_firebasejobs);

  UnmodifiableListView<Job> get localjobs => UnmodifiableListView(_localjobs);

  //Clear everything in the list
  void clearAll() {
    _localjobs.clear();
    notifyListeners();
  }

  void setFirebasejobs(List<QueryDocumentSnapshot<Object?>> jobs) {
    _firebasejobs = jobs;
    notifyListeners();
  }

  void addjobsLocally(List<QueryDocumentSnapshot<Object?>> jobsList) {
    _firebasejobs = jobsList;
    if (_localjobs.isNotEmpty) clearAll();
    jobsList.forEach((doc) {
      _localjobs.add(Job(
          title: doc['title'],
          category: doc['category'],
          description: doc['description'],
          salary: doc['salary'],
          postDate: doc['postDate'],
          document: doc));
    });
    notifyListeners();
  }

//method for searching jobs in the local list
  search(
      BuildContext context, List<QueryDocumentSnapshot<Object?>> firebasejobs) {
    showSearch(
      context: context,
      delegate: SearchPage<Job>(
          items: _localjobs,
          searchLabel: 'Search jobs',
          suggestion: SingleChildScrollView(
              child: ProductsGrid(
            productList: firebasejobs,
            isScrollable: false,
          )),
          failure: Center(
            child: NoProductsFound(),
          ),
          filter: (product) => [
                product.title,
                product.description,
                product.category,
              ],
          builder: (product) =>
              ProductCard(doc: product.document, widthReducer: 32)),
    );
  }
}
