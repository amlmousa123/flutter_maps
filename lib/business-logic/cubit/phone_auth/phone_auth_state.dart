class PhoneAuthState {}

class PhonAuthInitial extends PhoneAuthState{}

class Loading extends PhoneAuthState{}

class ErrorOccured extends PhoneAuthState{
  final String errorMsg ;

  ErrorOccured({required this.errorMsg});
}

class PhoneNumberSubmitted extends PhoneAuthState{}

class PhoneOtpVerified extends PhoneAuthState{}
