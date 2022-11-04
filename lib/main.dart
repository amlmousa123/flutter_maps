import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/app_router.dart';
import 'package:flutter_maps/constants/strings.dart';

late String initialRoute;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase .initializeApp();

FirebaseAuth.instance.authStateChanges().listen((user) {
  if (user ==null){
    initialRoute = loginScreen;
  }else{
    initialRoute = mapScreen ;
  }
});

  runApp( MyApp(appRouter: AppRouter(),));
}

class MyApp extends StatelessWidget {

  final AppRouter appRouter ;
   MyApp({Key? key, required this.appRouter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: appRouter.generateRoute,
      initialRoute: initialRoute,
    );
  }
}

