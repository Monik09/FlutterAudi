import 'dart:io';

import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';

import 'package:file_picker/file_picker.dart';

class EditProfile extends StatefulWidget {
  static const routeName = "/editing";

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();

  List<File> files = [];

  final TextEditingController _nameField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      floatingActionButton: IconButton(
        icon: Icon(
          Icons.arrow_back,
          size: 40,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlertDialog(
                actions: [
                  TextButton(
                    onPressed: () {
                      // Navigator.of(context).pushNamed(routeName);
                    },
                    child: Text("Yes"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("No"),
                  ),
                ],
                content: Text(
                  "Your changes will be discarded!",
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body:SingleChildScrollView(
        child: Column(children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          InkWell(
            onTap: () async {
              FilePickerResult result = await FilePicker.platform.pickFiles(
                type: FileType.image,
                allowMultiple: false,
              );
              if (result != null) {
                setState(() {
                  files = result.paths.map((path) => File(path)).toList();
                });
                print(files);
              }
            },
            child: CircleAvatar(
              backgroundImage: files.length == 0
                  ? AssetImage("assets/music.png")
                  : FileImage(files[0]),
              radius: 75,
            ),
          ),
          SizedBox(
            height: 100,
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
                  return (val.length < 6) ? "Give username greater than 6" : null;
                },
              ),
            ),
          ),
          SizedBox(height: 200),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState.validate()) {
                print(_nameField.value.text);
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
    );
  }
}
