import 'package:flutter/material.dart';

//To be implemented later
class ShopRegistratioForm extends StatefulWidget {
  const ShopRegistratioForm({Key? key}) : super(key: key);

  @override
  _ShopRegistratioFormState createState() => _ShopRegistratioFormState();
}

class _ShopRegistratioFormState extends State<ShopRegistratioForm> {
  // ignore: unused_element
  Widget _buildAddress() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Address",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            autofocus: true,
            enableSuggestions: true,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (v) {
              FocusScope.of(context).nextFocus();
            },
            obscureText: false,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                labelText: "Address",
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return "Please fill in your Address";
              }
              return null;
            },
            onSaved: (String? value) {},
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
