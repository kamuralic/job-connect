import 'dart:ui';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:job_connect/services/authentication_services.dart';
import 'package:job_connect/services/data_helpers_provider.dart';
import 'package:job_connect/services/image_picker_provider.dart';
import 'package:job_connect/services/internet_check_provider.dart';
import 'package:job_connect/services/storage_services.dart';
import 'package:job_connect/widgets/connectivity_notifier.dart';
import 'package:job_connect/widgets/imagePicker_widget.dart';
import 'package:job_connect/widgets/jobTypePicker.dart';
import 'package:job_connect/widgets/loading_button.dart';
import 'package:job_connect/widgets/productCategoryPicker.dart';
import 'package:provider/provider.dart';

class SellPage extends StatefulWidget {
  static const id = 'SellPage';
  const SellPage({Key? key}) : super(key: key);

  @override
  _SellPageState createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final GlobalKey<FormState> _fomKey = GlobalKey<FormState>();

  //form field variables
  TextEditingController _title = TextEditingController();
  TextEditingController _location = TextEditingController();
  TextEditingController _description = TextEditingController();
  TextEditingController _category = TextEditingController();
  TextEditingController _jobType = TextEditingController();
  TextEditingController _salary = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();
  TextEditingController _requirements = TextEditingController();
  TextEditingController _company = TextEditingController();

  //focus controllers for form fields
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _requirementsFocus = FocusNode();
  final FocusNode _locationFocus = FocusNode();
  final FocusNode _categoryFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _companyFocus = FocusNode();
  final FocusNode _jobTypeFocus = FocusNode();
  final FocusNode _salaryFocus = FocusNode();
  final FocusNode _phoneNumberFocus = FocusNode();

  //helper variables
  String _message = '';
  bool _showProgressIndicator = false;

  bool _internetIsAvailable = true;

  @override
  void initState() {
    super.initState();

//this addPostFrameCallBack is being used only to ease the use of context in initstate
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      DataHelpersProvider _sellerFormDataProvider =
          context.read<DataHelpersProvider>();

      // this to reset the data to null, jst in case subcatlist page has set the subcat and actegory already
      _sellerFormDataProvider.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ConnectivityProvider>(context).startMonitoring();
    final authProvider = context.read<AuthenticationService>();
    ImagesProvider _imagesProvider = Provider.of<ImagesProvider>(context);
    DataHelpersProvider _sellerFormDataProvider =
        Provider.of<DataHelpersProvider>(context);
    StorageService _storageServiceProvider =
        Provider.of<StorageService>(context);
    _category.text = _sellerFormDataProvider.category ?? '';
    _jobType.text =
        _sellerFormDataProvider.type ?? ''; //listen for category value

    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Consumer<DataHelpersProvider>(
                builder: (_, notifier, __) => notifier.category == null
                    ? Text('Post Job')
                    : Text('Post ' + notifier.category!)),
          ),
          body: Container(
            height: height,
            child: Stack(
              children: <Widget>[
                Container(
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
                          _buildImagesList(),
                          SizedBox(height: 40),
                          _companyName(),
                          _buildTitle(),
                          _buildcategory(),
                          _buildJobType(),
                          _buildLocation(),
                          _buildsalary(),
                          _buildPhoneN0(),
                          _buildrequirements(),
                          _buildDescription(),
                          _buildErrorMessage(),
                          SizedBox(height: 20),
                          _showProgressIndicator == false
                              ? _submitButton(
                                  _imagesProvider,
                                  _storageServiceProvider,
                                  authProvider,
                                  _sellerFormDataProvider)
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
            ),
          )),
    );
  }

//methods for building text fields
  Widget _buildImagesList() {
    return Row(
      children: [
        Container(
          width: 80,
          color: Colors.grey.shade300,
          padding: EdgeInsets.all(4),
          child: Center(
            child: Column(
              children: [
                IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ImagePickerWidget();
                          });
                    },
                    icon: Icon(CupertinoIcons.add_circled_solid)),
                Text(
                  "ADD PHOTOS",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
        Consumer<ImagesProvider>(
            builder: (_, notifier, __) => Expanded(
                    child: Container(
                  height: 100,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: notifier.images.isEmpty
                          ? 4
                          : notifier.images
                              .length, //show 4 image icons if the images list is empty
                      itemBuilder: (BuildContext context, int index) {
                        return notifier.images.isEmpty
                            ? Container(
                                margin: EdgeInsets.all(4),
                                height: 80,
                                width: 80,
                                child: FittedBox(
                                    child: Icon(
                                  CupertinoIcons.photo,
                                  color: Colors.grey,
                                )),
                              )
                            : Container(
                                margin: EdgeInsets.all(4),
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image:
                                            FileImage(notifier.images[index]))),
                              );
                      }),
                ))),
      ],
    );
  }

  Widget _buildcategory() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "category",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ProductCategoryPicker();
                  });
            },
            child: TextFormField(
              controller: _category,
              enabled: false,
              focusNode: _categoryFocus,
              enableSuggestions: true,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (v) {
                _categoryFocus.unfocus();
                FocusScope.of(context).requestFocus(_jobTypeFocus);
                //FocusScope.of(context).nextFocus();
              },
              obscureText: false,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  hintText: "category",
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "Please fill in a category for your Job";
                }

                return null;
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildJobType() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Type",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return JobTypePicker();
                  });
            },
            child: TextFormField(
              controller: _jobType,
              enabled: false,
              focusNode: _jobTypeFocus,
              enableSuggestions: true,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (v) {
                _jobTypeFocus.unfocus();
                FocusScope.of(context).requestFocus(_locationFocus);
              },
              obscureText: false,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  hintText: "Job Type",
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "Please fill in a category for your Job";
                }

                return null;
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Job Title",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: _title,
            focusNode: _titleFocus,
            enableSuggestions: true,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (v) {
              _titleFocus.unfocus();
              FocusScope.of(context).requestFocus(_categoryFocus);
            },
            obscureText: false,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                helperText: ' eg. Game Programmer needed etc',
                hintText: "Title",
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return "Please fill in a title for your Job";
              }

              return null;
            },
          )
        ],
      ),
    );
  }

  Widget _companyName() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Company Name",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: _company,
            focusNode: _companyFocus,
            enableSuggestions: true,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (v) {
              _companyFocus.unfocus();
              FocusScope.of(context).requestFocus(_titleFocus);
            },
            obscureText: false,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                hintText: "Company Name",
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return "Please fill in your company Name";
              }

              return null;
            },
          )
        ],
      ),
    );
  }

  Widget _buildrequirements() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "requirements",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: _requirements,
            focusNode: _requirementsFocus,
            enableSuggestions: true,
            maxLines: 10,
            minLines: 2,
            textInputAction: TextInputAction.newline,
            onFieldSubmitted: (v) {
              _requirementsFocus.unfocus();
              FocusScope.of(context).requestFocus(_locationFocus);
            },
            obscureText: false,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return "Please fill in the job requirements";
              }

              return null;
            },
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
                hintText: "Job requirements",
                helperText: "eg. CV, Experience etc",
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true),
          )
        ],
      ),
    );
  }

  Widget _buildLocation() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Location",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: _location,
            focusNode: _locationFocus,
            enableSuggestions: true,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (v) {
              _locationFocus.unfocus();
              FocusScope.of(context).requestFocus(_salaryFocus);
            },
            obscureText: false,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                hintText: "Company or work place location...",
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return "Please fill in where your Company is located";
              }

              return null;
            },
          )
        ],
      ),
    );
  }

  Widget _buildsalary() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "salary",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: _salary,
            focusNode: _salaryFocus,
            enableSuggestions: true,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (v) {
              _salaryFocus.unfocus();
              FocusScope.of(context).requestFocus(_phoneNumberFocus);
            },
            obscureText: false,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                prefix: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    'UGX',
                    style: Theme.of(context).textTheme.headline2,
                  ),
                ),
                hintText: "salary",
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return "Please fill in the salary of your job";
              }

              return null;
            },
          )
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Description",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: _description,
            focusNode: _descriptionFocus,
            maxLines: 10,
            enableSuggestions: true,
            textInputAction: TextInputAction.newline,
            onFieldSubmitted: (v) {
              _descriptionFocus.unfocus();
            },
            obscureText: false,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
                hintText: "What is Job all about?...",
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return "Please fill in a short Description of your Job";
              }

              return null;
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
          setState(() {});
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
                    controller: _phoneNumber,
                    focusNode: _phoneNumberFocus,
                    maxLength: 9,
                    enableSuggestions: true,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (v) {
                      _phoneNumberFocus.unfocus();
                      FocusScope.of(context).requestFocus(_descriptionFocus);
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
                  ))
            ],
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

  Widget _submitButton(
      ImagesProvider _imagesProvider,
      StorageService storageServiceProvider,
      AuthenticationService authProvider,
      DataHelpersProvider sellerFormDataProvider) {
    return InkWell(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (!_fomKey.currentState!.validate() ||
            _imagesProvider.images.isEmpty) {
          setState(() {
            _message = 'Pick images for the Job Work place';
          });
          return;
        }

        _fomKey.currentState!.save();

        //show progress indicator then upload Advert and remove the indicator wen upload is done
        if (_internetIsAvailable == true) {
          setState(() => _showProgressIndicator = true);
          //add upload method and progress indicator remover goes here
          storageServiceProvider
              .uploadJobAd(
                  context: context,
                  currentUserId: authProvider.currentFirebaseUser!.uid,
                  title: _title.text,
                  imageUrls: _imagesProvider.images,
                  category: sellerFormDataProvider.category!,
                  type: sellerFormDataProvider.type!,
                  company: _company.text,
                  location: _location.text,
                  salary: _salary.text,
                  requirements: _requirements.text,
                  phoneN0: _phoneNumber.text,
                  description: _description.text)
              .then((value) {
            _fomKey.currentState!.reset();
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
    );
  }
}
