import 'package:flutter/material.dart';
import 'package:job_connect/services/searchService.dart';
import 'package:provider/provider.dart';

PreferredSize searchField({
  required BuildContext context,
  required String hintText,
  required SearchService searchServiceProvider,
}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(40),
    child: Consumer<SearchService>(
      builder: (_, notifier, __) => Container(
        margin: EdgeInsets.all(8),
        height: 40.0,
        width: double.infinity,
        child: InkWell(
          onTap: () {
            searchServiceProvider.search(context, notifier.firebasejobs);
          },
          child: TextField(
            enabled: false,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xfff3f3f4),
              hintText: hintText,
              labelStyle: TextStyle(
                fontSize: 14.0,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).iconTheme.color,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.black,
                ),
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
        ),
      ),
    ),
  );
}
