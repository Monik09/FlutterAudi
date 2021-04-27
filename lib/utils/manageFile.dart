import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ManageFiles {
  final firestoreInstance = FirebaseFirestore.instance;

  Future<void> pickFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path)).toList();
      //print(files);
      uploadToCloudStorage(files);
    }
  }

  uploadToCloudStorage(List<File> files) {
    Reference storageRef;
    files.forEach((element) async {
      List info = element.toString().split("/");
      String name = info.last;
      name = name.substring(0, name.length - 1);
      //print(name);
      String fileExtension = name.split(".")[name.split(".").length - 1];
      //print(fileExtension);
      // element[0]
      storageRef = FirebaseStorage.instance.ref().child("songs/$name");
      final UploadTask uploadTask = storageRef.putFile(
        element,
        SettableMetadata(
          contentType: "audio" + '/' + fileExtension,
        ),
      );
      TaskSnapshot downloadUrl = await uploadTask;
      final String url = (await downloadUrl.ref.getDownloadURL());
      //print('URL Is $url');
      uploadToFirestore(url, name);
    });
  }

  uploadToFirestore(String url, String name) {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    //print(_firebaseAuth.currentUser.displayName);
    final firestoreInstance = FirebaseFirestore.instance;
    firestoreInstance.collection("Songs Data").add({
      "name": name,
      "downloadUrl": url,
      "timeStamp": DateTime.now().toUtc().toString(),
      "uploadedBy": _firebaseAuth.currentUser.email,
      "likes": 0,
      "listened": 0,
      "likedBy": [],
    });
  }

  Future<int> getLength() async {
    var q = await firestoreInstance
        .collection("Songs Data")
        .orderBy("timeStamp", descending: true)
        .get();
    return q.docs.length;
  }

  Future<List> getSongs() async {
    List songresult = [];
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance
        .collection("Songs Data")
        // .orderBy("timeStamp", descending: true)
        .orderBy("timeStamp")
        .limit(15)
        .get()
        .then<List>((querySnapshot) {
      querySnapshot.docs.forEach((e) {
        // //print("{{{{{{{{{{{{{{{{{{{{" + e.reference.id);
        //print(e.data());
        Map r = e.data();
        r["id"] = e.reference.id;
        songresult.add(r);
      });
      return songresult;
    });
  }

  Future<void> manageFavorite(List likedby, String id, bool isFav) async {
    final firestoreInstance = FirebaseFirestore.instance;
    await firestoreInstance.collection("Songs Data").doc(id).update({
      "likes": isFav ? FieldValue.increment(1) : FieldValue.increment(-1),
      "likedBy": likedby
    }).then((_) {
      //print("success!");
    });
  }

  Future<List> getSongsUser(String userEmail) async {
    final firestoreInstance = FirebaseFirestore.instance;
    List result = [];
    return await firestoreInstance
        .collection("Songs Data")
        .where("uploadedBy", isEqualTo: userEmail)
        .get()
        .then<List>((querySnapshot) {
      querySnapshot.docs.forEach((e) {
        // //print("{{{{{{{{{{{{{{{{{{{{" + e.reference.id);
        //print(e.data());
        Map r = e.data();
        r["id"] = e.reference.id;
        result.add(r);
      });
      return result;
    });
  }

  Future<bool> updateUserData(File file, username) async {
    if (file != null) {
      print("toStor");
      Reference storageRef;
      List info = file.toString().split("/");
      String name = info.last;
      name = name.substring(0, name.length - 1);
      //print(name);
      String fileExtension = name.split(".")[name.split(".").length - 1];
      //print(fileExtension);
      // element[0]
      storageRef = FirebaseStorage.instance.ref().child("userPhotos/$username");
      final UploadTask uploadTask = storageRef.putFile(
        file,
        SettableMetadata(
          contentType: "photo" + '/' + fileExtension,
        ),
      );
      TaskSnapshot downloadUrl = await uploadTask;
      final String url = (await downloadUrl.ref.getDownloadURL());
      //print('URL Is $url');
      return await updateAccountInfo(username, url);
    } else {
      print("toaccc");
      return await updateAccountInfo(username, "");
    }
  }

  Future<bool> updateAccountInfo(String username, String url) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User user = auth.currentUser;
    bool result = false;
    try {
      if (url != "" || url.length != 0) {
        print("acc");
        await user
            .updateProfile(displayName: username, photoURL: url)
            .then((value) async {
          print("1");
          await user.reload();
          print("2");
          print(user.displayName);
          result = true;
        });
      } else {
        user.updateProfile(displayName: username);
        print("3");
        await user.reload();
        print("4");
        print(user.displayName);
        result = true;
      }
      print("#$result");
      return result;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
