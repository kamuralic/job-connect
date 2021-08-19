import 'dart:io';
import 'dart:collection';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';

class DocumentsProvider with ChangeNotifier {
  List<File> _documents = [];

  //getters
  UnmodifiableListView<File> get documents => UnmodifiableListView(_documents);

  //For removing a Document from a list of Documents
  void removeDocumentFromList(int index) {
    _documents.removeAt(index);
    notifyListeners();
  }

//Clear everything in the list
  void clearAll() {
    _documents.clear();
    notifyListeners();
  }

  //Pick a list of Documents
  void getDocuments() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      for (String? path in result.paths) {
        _documents.add(File(path!));
      }
      notifyListeners();
    }
  }
}
