import 'package:chhabrain_task_songslistener/screens/editScreen.dart';
import 'package:chhabrain_task_songslistener/screens/home.dart';
import 'package:chhabrain_task_songslistener/screens/login_screen.dart';
import 'package:chhabrain_task_songslistener/screens/playMusic.dart';
import 'package:chhabrain_task_songslistener/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chhabrain-Music',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _firebaseAuth.currentUser != null ? Home() : LoginScreen(),
      routes: {
        LoginScreen.routeName: (_) => LoginScreen(),
        Home.routeName: (_) => Home(),
        PlayMusic.routeName: (_) => PlayMusic(),
        ProfileScreen.routeName: (_) => ProfileScreen(),
        EditProfile.routeName: (_) => EditProfile()
      },
    );
  }
}
