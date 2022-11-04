import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/business-logic/cubit/phone_auth/phone_auth_cubit.dart';
import 'package:flutter_maps/constants/my_colors.dart';
import 'package:flutter_maps/constants/strings.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../business-logic/cubit/phone_auth/phone_auth_state.dart';

class OtpScreen extends StatelessWidget {
  final phoneNumber;
  OtpScreen({Key? key, required this.phoneNumber}) : super(key: key);
  late String otpCode;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 32, vertical: 88),
        child: Column(
          children: [
            _buildIntroTexts(),
            SizedBox(
              height: 88,
            ),
            _buildPinCodeFields(context),
            SizedBox(
              height: 60,
            ),
            _buildVerifyButton(context),
            buildPhoneVerificationBloc(),
          ],
        ),
      ),
    ));
  }

  Widget _buildIntroTexts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verify your phone number ?',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 24),
        ),
        SizedBox(
          height: 30,
        ),
        RichText(
            text: TextSpan(
                text: 'Enter your 6 digits code sent to ',
                style:
                    TextStyle(color: Colors.black, fontSize: 18, height: 1.4),
                children: [
              TextSpan(
                  text: '$phoneNumber',
                  style: TextStyle(
                    color: MyColors.blue,
                  ))
            ]))
      ],
    );
  }

  Widget _buildPinCodeFields(BuildContext context) {
    return Container(
      child: PinCodeTextField(
        appContext: context,
        length: 6,
        obscureText: false,
        autoFocus: true,
        keyboardType: TextInputType.number,
        animationType: AnimationType.scale,
        cursorColor: Colors.black,
        pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(5),
            fieldHeight: 50,
            fieldWidth: 40,
            borderWidth: 1,
            activeColor: MyColors.blue,
            inactiveColor: MyColors.blue,
            activeFillColor: MyColors.lightBlue,
            inactiveFillColor: Colors.white,
            selectedColor: MyColors.blue,
            selectedFillColor: Colors.white),
        onChanged: (String value) {
          print(value);
        },
        animationDuration: Duration(milliseconds: 300),
        backgroundColor: Colors.white,
        enableActiveFill: true,
        onCompleted: (code) {
          otpCode = code;
          print('compeleted');
        },
      ),
    );
  }

  Widget _buildVerifyButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () {
          showProgressIndicator(context);
          _login(context);
        },
        child: Text(
          'Verify',
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

  void _login(BuildContext context) {
    BlocProvider.of<PhoneAuthCubit>(context).submittedOtpCode(otpCode);
  }

  Widget buildPhoneVerificationBloc() {
    return BlocListener<PhoneAuthCubit, PhoneAuthState>(
      listenWhen: (previous, current) {
        return (previous != current);
      },
      listener: (context, state) {
        if (state is Loading) {
          return showProgressIndicator(context);
        }
        if (state is PhoneOtpVerified) {
          Navigator.pop(context);
          Navigator.of(context).pushNamed(mapScreen);
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
}
