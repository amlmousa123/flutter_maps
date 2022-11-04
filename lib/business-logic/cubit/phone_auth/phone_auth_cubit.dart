import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/business-logic/cubit/phone_auth/phone_auth_state.dart';

class PhoneAuthCubit extends Cubit<PhoneAuthState> {
  late String verificationId ;
  PhoneAuthCubit():super(PhonAuthInitial());

  Future<void> submitePhoneNumber(String phoneNumber) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+2$phoneNumber',
      timeout: const Duration(seconds: 14),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  void verificationCompleted(PhoneAuthCredential credential) async{
    print('verification completed');
    await signIn (credential);
  }

  void verificationFailed(FirebaseAuthException e) {
    print('verification error : ${e.toString()}');
    emit(ErrorOccured(errorMsg: e.toString()));
  }

  void codeSent(String verificationId, int? resendToken) {
    print('code sent');
    this.verificationId = verificationId ;
    emit(PhoneNumberSubmitted());
  }

  void codeAutoRetrievalTimeout(String verificationId) {
    print('codeAutoRetrievalTimeout');
  }

  Future<void> submittedOtpCode (String otpCode) async{
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: this.verificationId, smsCode: otpCode);
    await signIn (credential);
  }

  Future<void> signIn (PhoneAuthCredential credential) async{
    try{
      FirebaseAuth.instance.signInWithCredential(credential);
      emit(PhoneOtpVerified());
    }catch(error){
      print(error.toString());
      emit(ErrorOccured(errorMsg: error.toString()));
    }
  }

  Future<void> logOut () async{
    await FirebaseAuth.instance.signOut();
  }

  User getLoggedInUser(){
    User firebaseUser = FirebaseAuth.instance.currentUser!;
    return firebaseUser ;
  }
}
