import 'package:chhabrain_task_songslistener/screens/home.dart';
import 'package:chhabrain_task_songslistener/screens/login_screen.dart';
import 'package:chhabrain_task_songslistener/screens/profile_screen.dart';
import 'package:chhabrain_task_songslistener/utils/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget drawer(BuildContext context) {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Authentication _authentication = Authentication();
  String emailname = _firebaseAuth.currentUser.email.split("@")[0];
  return Drawer(
    child: Container(
      color: Colors.blue[900],
      child: Column(
        children: [
          // SizedBox(
          //   height: 50,
          // ),
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.white),
            accountName: Text(
              _firebaseAuth.currentUser.displayName == null
                  ? emailname
                  : _firebaseAuth.currentUser.displayName,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900]),
            ),
            accountEmail: Text(
              _firebaseAuth.currentUser.email,
              style: TextStyle(fontSize: 16, color: Colors.black45),
            ),
            currentAccountPicture: _firebaseAuth.currentUser.photoURL != null
                ? CircleAvatar(
                    backgroundImage:
                        NetworkImage(_firebaseAuth.currentUser.photoURL))
                : CircleAvatar(backgroundImage: AssetImage("assets/user.png")),
          ),
          Container(
            height: 50,
            padding: EdgeInsets.only(top: 10),
            child: Text(
              "Chhabrain Task",
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                  fontSize: 25,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Divider(
            color: Colors.white30,
            thickness: 2.3,
          ),
          ListTile(
            leading: Icon(
              Icons.home,
              color: Colors.white,
              size: 25,
            ),
            title: Text('Home',
                style: GoogleFonts.roboto(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.of(context).pushNamed(Home.routeName);
            },
          ),
          Divider(
            color: Colors.white30,
            thickness: 1.3,
          ),
          ListTile(
            leading: Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 20,
            ),
            title: Text('Profile',
                style: GoogleFonts.roboto(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.of(context).pushNamed(ProfileScreen.routeName);
            },
          ),
          Divider(
            color: Colors.white30,
            thickness: 1.3,
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 25,
                ),
                title: Text('Logout',
                    style:
                        GoogleFonts.roboto(fontSize: 25, color: Colors.white)),
                onTap: () {
                  _authentication.signOut();
                  Navigator.popAndPushNamed(context, LoginScreen.routeName);
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
