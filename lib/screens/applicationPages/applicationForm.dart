import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:job_connect/services/authentication_services.dart';
import 'package:job_connect/services/document_picker_service.dart';
import 'package:job_connect/services/internet_check_provider.dart';
import 'package:job_connect/services/storage_services.dart';
import 'package:job_connect/widgets/connectivity_notifier.dart';
import 'package:job_connect/widgets/loading_button.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class ApplicationForm extends StatefulWidget {
  final DocumentSnapshot doc;
  const ApplicationForm({Key? key, required this.doc}) : super(key: key);

  @override
  _ApplicationFormState createState() => _ApplicationFormState();
}

class _ApplicationFormState extends State<ApplicationForm> {
  final GlobalKey<FormState> _fomKey = GlobalKey<FormState>();

  //form field variables

  //TextEditingController _category = TextEditingController();
  //TextEditingController _jobType = TextEditingController();

  String _phoneNumber = '';
  String _countryCode = '+256';

  String _userName = '';
  String _email = '';

  //focus controllers for form fields
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _userNameFocus = FocusNode();
  final FocusNode _phoneNumberFocus = FocusNode();

  //helper variables
  String _message = '';
  bool _showProgressIndicator = false;

  bool _internetIsAvailable = true;

  @override
  Widget build(BuildContext context) {
    Provider.of<ConnectivityProvider>(context).startMonitoring();
    final authProvider = context.read<AuthenticationService>();

    StorageService _storageServiceProvider = context.read<StorageService>();

    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(widget.doc['title']),
          ),
          body: Stack(
            children: <Widget>[
              Container(
                height: height,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  physics: ScrollPhysics(),
                  child: Form(
                    key: _fomKey,
                    child: Column(
                      //mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 40),
                        _buildUserName(authProvider, context),
                        _buildEmail(authProvider, context),
                        _buildPhoneN0(authProvider, context),
                        SizedBox(height: 40),
                        _buildDocumentsList(context),
                        _buildErrorMessage(context),
                        SizedBox(height: 20),
                        _showProgressIndicator == false
                            ? _submitButton(
                                _storageServiceProvider, authProvider, context)
                            : Row(
                                children: [
                                  LoadingButton(),
                                ],
                              )
                      ],
                    ),
                  ),
                ),
              ),
              ConnectivityNotifierWidget(),
            ],
          )),
    );
  }

//methods for building text fields
  Widget _buildDocumentsList(BuildContext context) {
    return Consumer<DocumentsProvider>(builder: (_, notifier, __) {
      return Container(
        color: Color(0xfff3f3f4),
        padding: EdgeInsets.symmetric(
          vertical: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "NOTE: Upload pdf files only",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            Container(
              width: 80,
              margin: EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey.shade200,
                      offset: Offset(2, 4),
                      blurRadius: 5,
                      spreadRadius: 2)
                ],
                color: Theme.of(context).accentColor,
              ),
              padding: EdgeInsets.all(4),
              child: Center(
                child: Column(
                  children: [
                    IconButton(
                        onPressed: () {
                          notifier.getDocuments();
                        },
                        icon: Icon(
                          CupertinoIcons.add_circled_solid,
                          color: Colors.white,
                        )),
                    Text(
                      notifier.documents.isEmpty
                          ? "ATTACH PDF"
                          : "ATTACH MORE PDFs",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
            ListView.builder(
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: notifier.documents.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                      trailing: IconButton(
                          onPressed: () {
                            notifier.removeDocumentFromList(index);
                          },
                          icon: Icon(Icons.close)),
                      title: Text(basename(notifier.documents[index].path)));
                }),
          ],
        ),
      );
    });
  }

  Widget _buildUserName(
    AuthenticationService authProvider,
    BuildContext context,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "User Name",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            initialValue: authProvider.currentFirebaseUser!.displayName,
            focusNode: _userNameFocus,
            enableSuggestions: true,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (v) {
              _userNameFocus.unfocus();
              FocusScope.of(context).requestFocus(_emailFocus);
            },
            obscureText: false,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                helperText: 'Enter your name',
                labelText: "User Name",
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                setState(() {
                  _message = "Something is wrong!! Please Check your inputs";
                });
                return "Please fill in your User Name";
              }
              return null;
            },
            onSaved: (String? value) {
              value == null ? _userName = "" : _userName = value;
            },
          )
        ],
      ),
    );
  }

  Widget _buildEmail(AuthenticationService authProvider, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Email",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            initialValue: authProvider.currentFirebaseUser!.email,
            focusNode: _emailFocus,
            enableSuggestions: true,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (v) {
              _emailFocus.unfocus();
              FocusScope.of(context).requestFocus(_phoneNumberFocus);
            },
            obscureText: false,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                labelText: "Email",
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                setState(() {
                  _message = "Something is wrong!! Please Check your inputs";
                });
                return "Please fill in your Email Address";
              }
              bool isValidEmail = EmailValidator.validate(value);

              if (!isValidEmail) {
                setState(() {
                  _message = "Something is wrong!! Please Check your inputs";
                });
                return "Please Enter a valid Email Address";
              }
              return null;
            },
            onSaved: (String? value) {
              value == null ? _email = "" : _email = value;
            },
          )
        ],
      ),
    );
  }

  String calcCountryCode({required String phone}) {
    return phone.substring(0, phone.length - 9);
  }

  Widget _buildCountryCode(AuthenticationService authProvider) {
    return Container(
      margin: EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
      color: Color(0xfff3f3f4),
      child: CountryCodePicker(
        initialSelection:
            /*authProvider.currentFirebaseUser!.phoneNumber != null
            ? calcCountryCode(
                phone: authProvider.currentFirebaseUser!.phoneNumber!)
            : */
            '+256',
        favorite: ['+256'],
        onChanged: (value) {
          setState(() {
            _countryCode = value.dialCode!;
          });
        },
      ),
    );
  }

  String calcPhoneWithoutCode({required String phone}) {
    return phone.substring(phone.length - 9);
  }

  Widget _buildPhoneN0(
      AuthenticationService authProvider, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "PhoneN0",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: _buildCountryCode(authProvider)),
              Expanded(
                  flex: 2,
                  child: TextFormField(
                    /*initialValue:
                        authProvider.currentFirebaseUser!.phoneNumber != null
                            ? calcPhoneWithoutCode(
                                phone: authProvider
                                    .currentFirebaseUser!.phoneNumber!)
                            : null,*/
                    focusNode: _phoneNumberFocus,
                    maxLength: 9,
                    enableSuggestions: true,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (v) {
                      _phoneNumberFocus.unfocus();
                    },
                    obscureText: false,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                        hintText: '783664226',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
                        //hintText: "PhoneN0",
                        border: InputBorder.none,
                        fillColor: Color(0xfff3f3f4),
                        filled: true),
                    validator: (String? value) {
                      if (value == null || value.isEmpty || value.length != 9) {
                        setState(() {
                          _message =
                              "Something is wrong!! Please Check your inputs";
                        });
                        return "Please fill in your PhoneN0";
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      value == null
                          ? _phoneNumber = ""
                          : _phoneNumber = _countryCode +
                              value; // concatenate contry code to phone number
                    },
                  ))
            ],
          )
        ],
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    return Consumer<ConnectivityProvider>(builder: (context, model, child) {
      return Text(
          model.isOnline ? _message : 'Your Internet Connection Is Off!!!',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red));
    });
  }

  Widget _submitButton(
    StorageService storageServiceProvider,
    AuthenticationService authProvider,
    BuildContext context,
  ) {
    return Consumer<DocumentsProvider>(
      builder: (_, notifier, __) => InkWell(
        onTap: () {
          FocusScope.of(context).unfocus();
          if (!_fomKey.currentState!.validate() || notifier.documents.isEmpty) {
            setState(() {
              _message = 'Please attach documents for your application form';
            });
            return;
          }

          _fomKey.currentState!.save();

          //show progress indicator then upload Advert and remove the indicator wen upload is done
          if (_internetIsAvailable == true) {
            setState(() => _showProgressIndicator = true);
            //add upload method and progress indicator remover goes here
            print(notifier.documents);
            storageServiceProvider
                .uploadApplicationForm(
              context: context,
              currentUserId: authProvider.currentFirebaseUser!.uid,
              documentUrls: notifier.documents,
              advertiserId: widget.doc['advertiser_id'],
              applicantImageUrl: authProvider.currentFirebaseUser!.photoURL,
              applicantName: _userName,
              phoneN0: _phoneNumber,
              email: _email,
              jobId: widget.doc.id,
              jobTitle: widget.doc['title'],
            )
                .then((value) {
              setState(() {
                _showProgressIndicator = false;
              });
            });
          }
        },
        child: Container(
            margin: EdgeInsets.only(bottom: 20),
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: 15),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey.shade200,
                    offset: Offset(2, 4),
                    blurRadius: 5,
                    spreadRadius: 2)
              ],
              color: Theme.of(context).iconTheme.color,
            ),
            child: Text(
              'Submit',
              style: Theme.of(context).textTheme.subtitle2,
            )),
      ),
    );
  }
}
