import 'dart:io';

import 'package:chhabrain_task_songslistener/screens/playMusic.dart';
import 'package:chhabrain_task_songslistener/utils/manageFile.dart';
import 'package:chhabrain_task_songslistener/widgets/drawer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = "/profile";

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  ManageFiles _manageFiles = ManageFiles();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  List<File> files = [];
  final TextEditingController _nameField = TextEditingController();
  bool isDetailed = false;
  FilePickerResult filePicked;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String emailname = _firebaseAuth.currentUser.email.split("@")[0];
    return Scaffold(
      key: _scaffoldKey,
      drawer: drawer(context),
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              _scaffoldKey.currentState.showBottomSheet((context) {
                return StatefulBuilder(
                  builder: (context, setState) => Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: SingleChildScrollView(
                      child: Column(children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        InkWell(
                          onTap: () async {
                            filePicked = await FilePicker.platform.pickFiles(
                              type: FileType.image,
                              allowMultiple: false,
                            );
                            if (filePicked != null) {
                              setState(() {
                                files = filePicked.paths
                                    .map((path) => File(path))
                                    .toList();
                              });
                              print(files);
                            }
                          },
                          child: Stack(
                            children: [
                              CircleAvatar(
                                backgroundImage: files.length == 0
                                    ? AssetImage("assets/user.png")
                                    : FileImage(files[0]),
                                radius: 75,
                                backgroundColor: Colors.white,
                              ),
                              Positioned(
                                  top: 13,
                                  left:
                                      MediaQuery.of(context).size.width * 0.07,
                                  child: Container(
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.grey[600],
                                      size: 100,
                                    ),
                                  ))
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 18.0),
                              child: Text(
                                "Enter New name",
                                style: GoogleFonts.openSans(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                              ),
                            )),
                        Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.all(28.0),
                            child: TextFormField(
                              controller: _nameField,
                              decoration: InputDecoration(
                                hintText: 'Name',
                                suffixIcon: Icon(Icons.person),
                              ),
                              validator: (val) {
                                return (val.length < 6)
                                    ? "Give username greater than 6"
                                    : null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              bool result;

                              print(_nameField.value.text);
                              if (files.length == 0) {
                                result = await _manageFiles.updateUserData(
                                    null,
                                    _nameField.value.text == null
                                        ? emailname
                                        : _nameField.value.text);
                                print("1$result");
                              } else {
                                result = await _manageFiles.updateUserData(
                                    files[0],
                                    _nameField.value.text == null
                                        ? emailname
                                        : _nameField.value.text);
                                print("2$result");
                              }
                              print(result);
                              Future.delayed(Duration(seconds: 5), () {
                                print(result);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result == true
                                      ? "Profile Updated"
                                      : "Error while updating"),
                                ),
                              );
                              Navigator.of(context).pop();
                            }
                          },
                          child: Container(
                              height: 30,
                              child: Text(
                                "Submit",
                                style: GoogleFonts.openSans(fontSize: 20),
                              )),
                        ),
                      ]),
                    ),
                  ),
                );
              });
              // Navigator.pushNamed(context,EditProfile.routeName);
            },
            icon: Icon(Icons.edit),
          ),
        ],
      ),
      body: FutureBuilder(
          future: _manageFiles.getSongsUser(_firebaseAuth.currentUser.email),
          builder: (context, snapshot) {
            print(emailname);
            if (!snapshot.hasData)
              return Center(
                child: CircularProgressIndicator(),
              );
            print(snapshot.data);
            List res = snapshot.data;
            int totalLikes = 0, totalUploads = res.length;
            List songTileData = [];
            res.forEach((element) {
              totalLikes += element["likes"];
              songTileData
                  .add({"name": element["name"], "likes": element["likes"]});
            });
            print(songTileData);
            print(totalLikes);
            print(_firebaseAuth.currentUser.displayName);
            return Container(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage:
                              _firebaseAuth.currentUser.photoURL == null
                                  ? AssetImage(
                                      "assets/user.png",
                                    )
                                  : NetworkImage(
                                      _firebaseAuth.currentUser.photoURL),
                        ),
                      ),
                      // if (snapshot.data.length != 0)
                      Expanded(
                          child: Text(
                        _firebaseAuth.currentUser.displayName == null ||
                                _firebaseAuth.currentUser.displayName.length ==
                                    0
                            ? emailname
                            : _firebaseAuth.currentUser.displayName,
                        style: GoogleFonts.openSans(
                            fontSize: 30, color: Colors.white),
                      )),
                      SizedBox(height: 100),
                    ],
                  ),
                  SizedBox(height: 25),
                  Divider(
                    thickness: 2,
                    color: Colors.white,
                  ),
                  Container(
                    height: 100,
                    width: double.maxFinite,
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Total likes",
                              style: GoogleFonts.openSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600]),
                            ),
                            Icon(
                              Icons.favorite,
                              color: Colors.pink,
                              size: 30,
                            ),
                            Text("$totalLikes",
                                style: GoogleFonts.acme(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                ))
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "Total Uploads",
                              style: GoogleFonts.openSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600]),
                            ),
                            Icon(
                              Icons.upload_file,
                              color: Colors.pink,
                              size: 30,
                            ),
                            Text("$totalUploads",
                                style: GoogleFonts.acme(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                ))
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 2,
                    color: Colors.white,
                  ),
                  SizedBox(height: 15),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 18.0),
                        child: Text(
                          "Your All Songs!",
                          style: GoogleFonts.openSans(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                  SizedBox(height: 5),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.45,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                        itemExtent: 80,
                        itemCount: songTileData.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, PlayMusic.routeName,
                                  arguments: res[index]);
                            },
                            child: Card(
                              child: ListTile(
                                title: Text(
                                  songTileData[index]["name"],
                                  style: GoogleFonts.acme(fontSize: 25),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.favorite_sharp,
                                      color: Colors.pink,
                                      size: 30,
                                    ),
                                    Text(
                                      songTileData[index]["likes"].toString(),
                                      style: GoogleFonts.roboto(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  )
                ],
              ),
            );
            // }
            // return Text("no");
          }),
    );
  }
}
