import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:job_connect/screens/authScreens/signup_screen.dart';
import 'package:job_connect/screens/home_page.dart';
import 'package:job_connect/services/authentication_services.dart';
import 'package:job_connect/services/internet_check_provider.dart';
import 'package:job_connect/widgets/connectivity_notifier.dart';
import 'package:job_connect/widgets/loading_button.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  static const id = "login";

  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {
  final GlobalKey<FormState> _fomKey = GlobalKey<FormState>();
  bool _passwordIsVisible = true;
  String _email = '';
  String _password = '';
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
                return "Please fill in your Email Address";
              }
              bool isValidEmail = EmailValidator.validate(value);

              if (!isValidEmail) {
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
                return "Please fill in your Password";
              }
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
        if (_internetIsAvailable == true) {
          if (mounted) setState(() => _showProgressIndicator = true);

          authenticationService
              .signIn(email: _email.trim(), password: _password.trim())
              .then((value) {
            if (mounted)
              setState(() {
                _showProgressIndicator = false;

                _message = value ?? '';
              });
            //Navigate to home sreen only if user is Signed In
            if (value == 'Signed In')
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(HomePage.id, (route) => false);
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
            'Login',
            style: Theme.of(context).textTheme.subtitle2,
          )),
    );
  }

  Widget _googleButton(AuthenticationService authenticationService) {
    return SignInButton(
      Buttons.Google,
      padding: EdgeInsets.all(8.0),
      text: "Login in with Google",
      onPressed: () {
        if (_internetIsAvailable == true) {
          //show progress indicator then sign in the user and remove the indicator wen signin is done
          setState(() => _showProgressIndicator = true);
          authenticationService.signInWithGoogle().then((value) {
            if (mounted)
              setState(() {
                _message = value ?? '';
                _showProgressIndicator = false;
              });
            //Navigate to home sreen only if user is Signed In
            if (value == 'Signed In')
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(HomePage.id, (route) => false);
          });
        }
      },
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

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignUpPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Don\'t have an account ?',
              style: Theme.of(context).textTheme.headline3,
            ),
            SizedBox(
              width: 10,
            ),
            Text('Register', style: Theme.of(context).textTheme.headline4),
          ],
        ),
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _buildEmail(),
        _buildPassword(),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ConnectivityProvider>(context).startMonitoring();
    final authProvider = context.read<AuthenticationService>();

    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            height: height,
            child: Stack(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'logo',
                      child: Image.asset(
                        './assets/images/Logo.png',
                        height: 150,
                        width: 150,
                      ),
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
                          _emailPasswordWidget(),
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
                          _googleButton(authProvider),
                          _createAccountLabel(),
                        ],
                      ),
                    ),
                  ),
                ),
                ConnectivityNotifierWidget(),
              ],
            ),
          )),
    );
  }
}
