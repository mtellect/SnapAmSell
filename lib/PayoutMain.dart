import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:flutter_keyboard_size/screen_height.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maugost_apps/AppConfig.dart';
import 'package:maugost_apps/AppEngine.dart';
import 'package:maugost_apps/admin/StripeService.dart';
import 'package:maugost_apps/app/dotsIndicator.dart';
import 'package:maugost_apps/assets.dart';
import 'package:maugost_apps/basemodel.dart';
import 'package:maugost_apps/date_picker/flutter_datetime_picker.dart';

class PayoutMain extends StatefulWidget {
  @override
  _PayoutMainState createState() => _PayoutMainState();
}

class _PayoutMainState extends State<PayoutMain> {
  BaseModel model = userModel.getModel(PAYOUT_INFO);

  //final mobileController = MaskedController(mask: Mask(mask: 'NNN-NNN-NNNNN'));
  String birthDate = '';
  final routingController = TextEditingController();
  final acctNameController = TextEditingController();
  final acctNumberController = TextEditingController();
  final bankNameController = TextEditingController();

  final ssnController = TextEditingController();
  final emailController = TextEditingController();
  final fNameController = TextEditingController();
  final lNameController = TextEditingController();

  FocusNode ssnFocus = new FocusNode();
  FocusNode emailFocus = new FocusNode();
  FocusNode fNameFocus = new FocusNode();
  FocusNode lNameFocus = new FocusNode();

  FocusNode routeFocus = new FocusNode();
  FocusNode acctNumFocus = new FocusNode();
  FocusNode acctNameFocus = new FocusNode();
  FocusNode bankNameFocus = new FocusNode();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  int currentPage = 0;
  final vp = PageController();
  String documentPath = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    birthDate = userModel.getString(BIRTH_DATE);
    ssnController.text = userModel.getString(SS_NUMBER);
    fNameController.text = userModel.getString(FIRST_NAME);
    lNameController.text = userModel.getString(LAST_NAME);
    routingController.text = userModel.getString(ROUTING_NUMBER);
    acctNameController.text = userModel.getString(ACCOUNT_NAME);
    acctNumberController.text = userModel.getString(ACCOUNT_NUMBER);
    bankNameController.text = userModel.getString(BANK_NAME);
  }

  String formatPackageDuration(int p) {
    return "${p + 1} Month${p == 0 ? "" : "s"}";
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      gestures: [
        GestureType.onTap,
        GestureType.onPanUpdateDownDirection,
      ],
      child: KeyboardSizeProvider(
        smallSize: 500.0,
        child:
            Consumer<ScreenHeight>(builder: (context, ScreenHeight sh, child) {
          return Scaffold(
            key: scaffoldKey,
            backgroundColor: white,
            body: Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
                  color: white,
                  child: Row(
                    children: <Widget>[
                      InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            child: Center(
                                child: Icon(
                              Icons.keyboard_backspace,
                              color: black,
                              size: 25,
                            )),
                          )),
                      Text(
                        "Payout SetUp",
                        style: textStyle(true, 25, black),
                      ),
                      Spacer()
                    ],
                  ),
                ),
                Container(
                  color: blue3,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        currentPage == 0
                            ? "Tell us more about yourself"
                            : "Add your bank information for payments",
                        style: textStyle(true, 18, white),
                      ),
                      addSpace(4),
                      Container(
                        decoration: BoxDecoration(
                            color: black.withOpacity(.4),
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.all(3),
                        child: DotsIndicator(
                          dotsCount: 2,
                          position: currentPage,
                          decorator: DotsDecorator(
                              color: white.withOpacity(.5),
                              activeColor: white,
                              spacing: EdgeInsets.all(3),
                              size: Size(6, 6),
                              activeSize: Size(10, 10)),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  width: double.infinity,
                  height: errorText.isEmpty ? 0 : 40,
                  color: red0,
                  padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                  child: Center(
                      child: Text(
                    errorText,
                    style: textStyle(true, 14, white),
                  )),
                ),
                Expanded(
                  child: PageView(
                    controller: vp,
                    //physics: NeverScrollableScrollPhysics(),
                    onPageChanged: (p) {
                      currentPage = p;
                      setState(() {});
                    },
                    children: [page1(), page2()],
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  page1() {
    return ListView(
      padding: EdgeInsets.all(0),
      children: [
        Container(
          decoration:
              BoxDecoration(color: red, borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Row(
            children: [
              Icon(
                Icons.info,
                color: white,
              ),
              addSpaceWidth(10),
              Flexible(
                child: Text(
                  "Note: You are required to upload a picture of the front "
                  "side of any government-issued ID in order"
                  " to verify your identity.Your photo must be in "
                  "JPG or PNG format and under 10MB in size.",
                  style: textStyle(false, 14, white),
                ),
              ),
            ],
          ),
        ),
        selectorField(
            value: documentPath,
            title: "",
            hint: "Upload Verification Document",
            icon: Icons.verified_user,
            onTap: () async {
              final file =
                  await ImagePicker.pickImage(source: ImageSource.gallery);
              if (file == null) return;
              setState(() {
                documentPath = file.path;
              });
            }),
        selectorField(
            value: birthDate,
            title: "",
            hint: "Date of Birth",
            icon: Icons.event,
            asset: "assets/icons/gender.png",
            onTap: () {
              bool empty = null == birthDate || birthDate.isEmpty;
              int year;
              int month;
              int day;
              if (!empty) {
                var birthDay = birthDate.split("-");
                year = num.parse(birthDay[0]);
                month = num.parse(birthDay[1]);
                day = num.parse(birthDay[2]);
              }
              DatePicker.showDatePicker(
                context,
                showTitleActions: true,
                minTime: DateTime(1930, 12, 31),
                maxTime: DateTime(2040, 12, 31),
                onChanged: (date) {},
                onConfirm: (date) {
                  setState(() {
                    int year = date.year;
                    int month = date.month;
                    int day = date.day;
                    birthDate = "$year-${formatDOB(month)}-${formatDOB(day)}";
                  });
                },
                currentTime: empty ? null : DateTime(year, month, day),
              );
            }),
        textInputField(
          controller: ssnController,
          focusNode: ssnFocus,
          title: "",
          hint: "last 4 digit of Social Security Number",
          asset: "null",
          isPhone: true,
          icon: LineIcons.key,
        ),
        textInputField(
          controller: fNameController,
          focusNode: fNameFocus,
          title: "",
          hint: "First Name",
          asset: "null",
          icon: LineIcons.user,
        ),
        textInputField(
          controller: lNameController,
          focusNode: lNameFocus,
          title: "",
          hint: "Last Name",
          asset: "null",
          icon: LineIcons.user,
        ),
        addSpace(30),
        Container(
          padding: EdgeInsets.only(left: 15, right: 15),
          child: FlatButton(
            onPressed: () {
              String ssNumber = ssnController.text;
              String fName = fNameController.text;
              String lName = lNameController.text;

              if (documentPath.isEmpty) {
                showError("Please add your Verification Document");
                return;
              }
              if (ssNumber.isEmpty) {
                showError(
                    "Please enter your Social Security or Insurance Number");
                return;
              }

              if (fName.isEmpty) {
                showError("Please enter your First Name");
                return;
              }

              if (lName.isEmpty) {
                showError("Please enter your Last Name");
                return;
              }

              String personId = userModel.getString(STRIPE_PERSON_ID);
              showProgress(true, context, msg: "Uploadind Document...");
              StripeService.createStripePerson(
                  bDay: birthDate.split('-')[2],
                  bMonth: birthDate.split('-')[1],
                  bYear: birthDate.split('-')[0],
                  path: documentPath,
                  personId: personId,
                  ssNumber: ssNumber,
                  email: emailController.text,
                  firstName: fName,
                  lastName: lName,
                  onResponse: (resp) {
                    if (!resp.success) {
                      showProgress(false, context);
                      showMessage(context, Icons.error_outline, red, "Error",
                          resp.message,
                          delayInMilli: 1200);
                      return;
                    }
                    showProgress(false, context);
                    Future.delayed(Duration(milliseconds: 800), () {
                      vp.jumpToPage(1);
                    });
                  });
            },
            padding: EdgeInsets.all(16),
            color: AppConfig.appColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Center(
                child: Text(
              "UPLOAD",
              style: textStyle(true, 18, white),
            )),
          ),
        ),
        addSpace(50),
      ],
    );
  }

  page2() {
    return ListView(
      padding: EdgeInsets.all(0),
      children: [
        textInputField(
          controller: routingController,
          focusNode: routeFocus,
          title: "",
          hint: "Routing Number",
          asset: "null",
          isPhone: true,
          icon: LineIcons.sort_numeric_asc,
        ),
        textInputField(
          controller: acctNumberController,
          focusNode: acctNumFocus,
          title: "",
          hint: "Account Number",
          asset: "null",
          isPhone: true,
          icon: LineIcons.sort_numeric_asc,
        ),
        textInputField(
          controller: acctNameController,
          focusNode: acctNameFocus,
          title: "",
          hint: "Account Name",
          asset: "null",
          icon: LineIcons.user,
        ),
        textInputField(
          controller: bankNameController,
          focusNode: bankNameFocus,
          title: "",
          hint: "Bank Name",
          asset: "null",
          icon: LineIcons.bank,
        ),
        addSpace(30),
        Container(
          padding: EdgeInsets.only(left: 15, right: 15),
          child: FlatButton(
            onPressed: () {
              String routNum = routingController.text;
              String acctNum = acctNumberController.text;
              String acctName = acctNameController.text;
              String bankName = bankNameController.text;

//              StripeService.deleteStripeAccount(
//                  accountId: 'acct_1HC4uRAsuh7EcJIt',
//                  onResponse: (r) {
//                    print(r.body);
//                  });

              if (routNum.isEmpty) {
                showError('Enter Routing number');
                return;
              }

              if (acctNum.isEmpty) {
                showError('Enter Account number');
                return;
              }

              if (acctName.isEmpty) {
                showError('Enter Account Name');
                return;
              }

              if (bankName.isEmpty) {
                showError('Enter Bank Name');
                return;
              }

//              StripeService.updateStripeAccount(
//                  body: {
//                    'legal_entity[type]': 'individual',
//                  },
//                  onResponse: (r) {
//                    print(r.body['verification']);
//                  });
//              return;
              showProgress(true, context, msg: "Linking Account...");
              StripeService.createStripeBankToken(
                  bankName: bankName,
                  accountName: acctName,
                  routingNumber: routNum,
                  accountNumber: acctNum,
                  onResponse: (resp) {
                    showProgress(false, context);
                    if (!resp.success) {
                      showProgress(false, context);
                      showMessage(context, Icons.error_outline, red, "Error",
                          resp.message,
                          delayInMilli: 1200);
                      return;
                    }
                    showProgress(false, context);
                    showMessage(context, Icons.check, green, 'Successfull',
                        resp.message,
                        delayInMilli: 1200,
                        cancellable: false,
                        clickYesText: 'Go Back', onClicked: (_) {
                      Navigator.pop(context);
                    });
                  });
            },
            padding: EdgeInsets.all(16),
            color: AppConfig.appColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Center(
                child: Text(
              "SAVE",
              style: textStyle(true, 18, white),
            )),
          ),
        ),
        addSpace(50),
      ],
    );
  }

  String formatTimeChosen(int time) {
    final date = DateTime.fromMillisecondsSinceEpoch(time);
    return new DateFormat("MMMM d y").format(date);
  }

  textFieldBox(TextEditingController controller, String hint, setstate(v),
      {focusNode,
      int maxLength,
      int maxLines,
      bool number = false,
      Color fillColor}) {
    if (fillColor == null) fillColor = black.withOpacity(.05);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: TextFormField(
        focusNode: focusNode,
        maxLength: maxLength,
        maxLines: maxLines,
        //maxLengthEnforced: false,
        controller: controller,
        decoration: InputDecoration(
            fillColor: fillColor,
            filled: true,
            labelText: hint,
            counter: Container(),
            border: InputBorder.none),
        onChanged: setstate,
//        onEditingComplete: setstate,
        keyboardType: number ? TextInputType.number : null,
      ),
    );
  }

  validateFields() async {
    String name = acctNameController.text;
    String number = acctNumberController.text;
    String bank = bankNameController.text;

    var result = await (Connectivity().checkConnectivity());
    if (result == ConnectivityResult.none) {
      snack("No internet connectivity");
      return;
    }

    if (name.isEmpty) {
      snack("Add Account Name");
      return;
    }

    if (number.isEmpty) {
      snack("Add Account Number");
      return;
    }

    if (bank.isEmpty) {
      snack("Add Bank Name");
      return;
    }

    BaseModel model = BaseModel();
    model
      ..put(ACCOUNT_NAME, name)
      ..put(ACCOUNT_NUMBER, number)
      ..put(BANK_NAME, bank);
    userModel
      ..put(PAYOUT_INFO, model.items)
      ..updateItems();
    showMessage(context, Icons.check, green, "Successful",
        "You have successfully updated your Payout Information",
        onClicked: (_) {
      Navigator.pop(context, "");
    });
  }

  snack(String text) {
    Future.delayed(Duration(milliseconds: 500), () {
      showSnack(scaffoldKey, text, useWife: true);
    });
  }

  String errorText = "";
  showError(String text, {bool wasLoading = false}) {
    if (wasLoading) showProgress(false, context);
    errorText = text;
    setState(() {});
    Future.delayed(Duration(seconds: 3), () {
      errorText = "";
      setState(() {});
    });
  }
}
