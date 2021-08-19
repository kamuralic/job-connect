import 'package:flutter/cupertino.dart';

class DataHelpersProvider with ChangeNotifier {
  String? _category;
  String? _type;

  String? get category => _category;
  String? get type => _type;

  void setCategory(String cat) {
    _category = cat;
    notifyListeners();
  }

  void setType(String? jobType) {
    _type = jobType;
    notifyListeners();
  }

  void reset() {
    _category = null;
    _type = null;
    notifyListeners();
  }

  // For chat conversations page used by typing area
  bool _canSendMessage = false;

  bool get canSendMessage => _canSendMessage;

  void setCanSendMessage({required bool value}) {
    _canSendMessage = value;
    notifyListeners();
  }
}
