import 'package:chat_app/screens/auth_screen.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _fAapp = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Colors.pink,
                  secondary: Colors.deepPurple,
                ),
            primarySwatch: Colors.pink,
            backgroundColor: Colors.pink,
            buttonTheme: ButtonTheme.of(context).copyWith(
              buttonColor: Colors.pink,
              textTheme: ButtonTextTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            textTheme: Theme.of(context)
                .textTheme
                .copyWith(titleLarge: const TextStyle(color: Colors.white))),
        home: FutureBuilder(
          future: _fAapp,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("Something went wrong!");
            } else if (snapshot.hasData) {
              return StreamBuilder(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SplashScreen();
                    }
                    if (snapshot.connectionState == ConnectionState.active) {
                      User? user = snapshot.data as User?;
                      if (user == null) {
                        return const AuthScreen();
                      }
                      return const ChatScreen();
                    }
                    return const CircularProgressIndicator();
                  });
            } else {
              return const CircularProgressIndicator();
            }
          },
        ));
  }
}
