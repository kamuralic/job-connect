import 'package:country_code_picker/country_code_picker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:job_connect/screens/authScreens/login_screen.dart';
import 'package:job_connect/services/authentication_services.dart';
import 'package:job_connect/services/internet_check_provider.dart';
import 'package:job_connect/widgets/connectivity_notifier.dart';
import 'package:job_connect/widgets/loading_button.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  static const id = "signUp";
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final id = 'signUpPageID';

  final GlobalKey<FormState> _fomKey = GlobalKey<FormState>();
  bool _passwordIsVisible = true;
  var _message = '';
  bool _showProgressIndicator = false;
  bool _internetIsAvailable = true;
  Icon _visble = Icon(
    Icons.visibility,
    color: HexColor("#dc2430"),
    size: 25,
  );
  Icon _hidden = Icon(
    Icons.visibility_off,
    color: Colors.grey,
    size: 25,
  );
  String _userName = '';
  String _password = '';
  String _phoneNumber = '';
  String _email = '';
  String _countryCode = '+243';

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _buildUserName() {
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
            autofocus: true,
            enableSuggestions: true,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (v) {
              FocusScope.of(context).nextFocus();
            },
            obscureText: false,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                helperText: 'This can be company name or your name',
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

  Widget _buildEmail() {
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
            autofocus: true,
            enableSuggestions: true,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (v) {
              FocusScope.of(context).nextFocus();
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

  Widget _buildCountryCode() {
    return Container(
      margin: EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
      color: Color(0xfff3f3f4),
      child: CountryCodePicker(
        initialSelection: '+256',
        favorite: ['+256'],
        onChanged: (value) {
          setState(() {
            _countryCode = value.dialCode!;
          });
        },
      ),
    );
  }

  Widget _buildPhoneN0() {
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
              Expanded(flex: 1, child: _buildCountryCode()),
              Expanded(
                  flex: 2,
                  child: TextFormField(
                    maxLength: 9,
                    autofocus: true,
                    enableSuggestions: true,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).nextFocus();
                    },
                    obscureText: false,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                        hintText: '783664226',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
                        //labelText: "PhoneN0",
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

  Widget _buildPassword() {
    return Container(
      width: MediaQuery.of(context).size.width - 20,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Password",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            obscureText: _passwordIsVisible,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (v) {
              FocusScope.of(context).unfocus();
            },
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
                hintText: 'minimum 6 characters... ',
                labelText: "Password",
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true,
                suffixIcon: IconButton(
                    icon: _passwordIsVisible == true ? _hidden : _visble,
                    onPressed: () {
                      setState(() {
                        _passwordIsVisible = !_passwordIsVisible;
                      });
                    })),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                setState(() {
                  _message = "Something is wrong!! Please Check your inputs";
                });
                return "Please fill in your Password";
              }
              _password = value;
              return null;
            },
            onSaved: (String? value) {
              value == null ? _password = "" : _password = value;
            },
          )
        ],
      ),
    );
  }

  Widget _buildConfirmPassword() {
    return Container(
      width: MediaQuery.of(context).size.width - 20,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Confirm Password",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            obscureText: _passwordIsVisible,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (v) {
              FocusScope.of(context).unfocus();
            },
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
                labelText: "Confirm Password",
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true,
                suffixIcon: IconButton(
                    icon: _passwordIsVisible == true ? _hidden : _visble,
                    onPressed: () {
                      setState(() {
                        _passwordIsVisible = !_passwordIsVisible;
                      });
                    })),
            validator: (String? value) {
              if (value == null || value.isEmpty || value != _password) {
                setState(() {
                  _message = "Something is wrong!! Please Check your inputs";
                });
                return "Confirmation Password not matching with Password";
              }
              return null;
            },
          )
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Consumer<ConnectivityProvider>(builder: (context, model, child) {
      return Text(
          model.isOnline ? _message : 'Your Internet Connection Is Off!!!',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red));
    });
  }

  Widget _submitButton(AuthenticationService authenticationService) {
    return InkWell(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (!_fomKey.currentState!.validate()) {
          return;
        }

        _fomKey.currentState!.save();

        //show progress indicator then sign in the user and remove the indicator wen signin is done

        setState(() => _showProgressIndicator = true);
        if (_internetIsAvailable == true) {
          authenticationService
              .signUp(
                  email: _email.trim(),
                  password: _password.trim(),
                  userName: _userName,
                  phoneN0: _phoneNumber)
              .then((value) {
            setState(() {
              _showProgressIndicator = false;

              _message = value ?? '';
              //Navigate to Login sreen only if user is Signed Up
              if (value == 'Signed Up')
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(LoginPage.id, (route) => false);
            });
          });
        }
      },
      child: Container(
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
            'Sign Up',
            style: Theme.of(context).textTheme.subtitle2,
          )),
    );
  }

  Widget _loginAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Already have an account ?',
              style: Theme.of(context).textTheme.headline3,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Login',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('or'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  Widget _textFieldsWidget() {
    return Column(
      children: <Widget>[
        _buildEmail(),
        _buildUserName(),
        _buildPhoneN0(),
        _buildPassword(),
        _buildConfirmPassword(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    Provider.of<ConnectivityProvider>(context).startMonitoring();
    final authProvider = context.read<AuthenticationService>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: height,
        child: Stack(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  './assets/images/Logo.png',
                  height: 150,
                  width: 150,
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Form(
                  key: _fomKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: height * .2),
                      _textFieldsWidget(),
                      SizedBox(
                        height: 20,
                      ),
                      _buildErrorMessage(),
                      SizedBox(height: 20),
                      _showProgressIndicator == false
                          ? _submitButton(authProvider)
                          : Row(
                              children: [
                                LoadingButton(),
                              ],
                            ),
                      _divider(),
                      _loginAccountLabel(),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(top: 40, left: 0, child: _backButton()),
            ConnectivityNotifierWidget(),
          ],
        ),
      ),
    );
  }
}
