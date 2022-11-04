import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/business-logic/cubit/phone_auth/phone_auth_cubit.dart';
import 'package:flutter_maps/business-logic/cubit/phone_auth/phone_auth_state.dart';
import 'package:flutter_maps/constants/my_colors.dart';
import 'package:flutter_maps/constants/strings.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);
  String? phoneNumber;
  String countryFlag = '';
  String countryCode = '';

  final GlobalKey<FormState> phoneFormKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: phoneFormKey,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 88, horizontal: 32),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildIntroTexts(),
                  SizedBox(
                    height: 110,
                  ),
                  buildPhoneFormField(context),
                  SizedBox(
                    height: 70,
                  ),
                  buildNextButton(context),
                  buildPhoneNumberSubmittedBloc()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildIntroTexts() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        'What is your phone number ?',
        style: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.black, fontSize: 24),
      ),
      SizedBox(
        height: 30,
      ),
      Text(
        'Please enter your phone number to verify your account .',
        style: TextStyle(color: Colors.black, fontSize: 18),
      ),
    ]);
  }

  buildPhoneFormField(BuildContext context) {
    return Row(
      children: [
        Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                showCountryPicker(
                  context: context,
                  onSelect: (Country country) {
                    countryFlag = country.flagEmoji;
                    countryCode = country.phoneCode;
                  },
                );
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                      border: Border.all(color: MyColors.lightGrey),
                      borderRadius: BorderRadius.all(Radius.circular(6))),
                  child: countryFlag == ''
                      ? Text(
                          '+20',
                          style: TextStyle(color: Colors.black),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                              Text(countryFlag),
                              Text('+' + countryCode)
                            ])),
            )),
        SizedBox(
          width: 16,
        ),
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
                border: Border.all(color: MyColors.blue),
                borderRadius: BorderRadius.all(Radius.circular(6))),
            child: TextFormField(
              autofocus: true,
              decoration: InputDecoration(border: InputBorder.none),
              cursorColor: Colors.black,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'please enter your phone number';
                } else if (value.length < 11) {
                  return 'Too short for a phone number';
                }
                return null;
              },
              onSaved: (value) {
                phoneNumber = value;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget buildNextButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () {
          showProgressIndicator(context);
          register(context);
        },
        child: Text(
          'Next',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
            primary: Colors.black,
            minimumSize: Size(110, 50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
      ),
    );
  }

  Future<void> register(BuildContext context) async {
    if (!phoneFormKey.currentState!.validate()) {
      Navigator.pop(context);
      return;
    } else {
      Navigator.pop(context);
      phoneFormKey.currentState!.save();
      BlocProvider.of<PhoneAuthCubit>(context).submitePhoneNumber(phoneNumber!);
    }
  }

  void showProgressIndicator(BuildContext context) {
    AlertDialog alertDialog = AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        ),
      ),
    );
    showDialog(
        barrierColor: Colors.white.withOpacity(0),
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return alertDialog;
        });
  }

  Widget buildPhoneNumberSubmittedBloc() {
    return BlocListener<PhoneAuthCubit, PhoneAuthState>(
      listenWhen: (previous, current) {
        return (previous != current);
      },
      listener: (context, state) {
        if (state is Loading) {
          return showProgressIndicator(context);
        }
        if (state is PhoneNumberSubmitted) {
          Navigator.pop(context);
          Navigator.of(context).pushNamed(otpScreen, arguments: phoneNumber);
        }
        if (state is ErrorOccured) {
          String errorMsg = (state).errorMsg;
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.black,
            duration: Duration(seconds: 3),
          ));
        }
      },
      child: Container(),
    );
  }
}
