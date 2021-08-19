import 'dart:collection';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
//import 'package:image_picker/image_picker.dart';

class ImagesProvider with ChangeNotifier {
  File? _image;
  List<File> _images = [];
  //final ImagePicker _picker = ImagePicker();

  //getters
  UnmodifiableListView<File> get images => UnmodifiableListView(_images);
  File? get image => _image;

  //For removing an image from a list of images
  void removeImageFromList(int index) {
    _images.removeAt(index);
    notifyListeners();
  }

//Clear everything in the list
  void clearAll() {
    _images.clear();
    notifyListeners();
  }

  //Pick a list of images
  void getImages() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);

    if (result != null) {
      for (String? path in result.paths) {
        _images.add(File(path!));
      }
      //_images = result.paths.map((path) => File(path!)).toList();
      notifyListeners();
    }

    /*final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _images.add(File(pickedFile.path));
      notifyListeners();
    } else {
      getLostDataImages();
    }*/
  }

  //Pick a single image only
  void getImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      _image = File(result.files.single.path!);
      notifyListeners();
    }
    /*final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      notifyListeners();
      _image = File(pickedFile.path);
    } else {
      getLostDataImage();
    }*/
  }
/*
// this is recommended to be done. Image Picker package developers say so. Check documentation
  Future<void> getLostDataImages() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      _images.add(File(response.file!.path));
      notifyListeners();
    } else {}
  }

  //For one image
  Future<void> getLostDataImage() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      _image = File(response.file!.path);
      notifyListeners();
    } else {}
  }*/
}
