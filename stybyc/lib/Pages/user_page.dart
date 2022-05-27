import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:stybyc/Pages/tab_page.dart';
import 'package:stybyc/auth/decision_tree.dart';

class UserPage extends StatefulWidget {
  const UserPage({
    Key? key,
  }) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late final _usernameController;
  late final origBirthday;

  var file;

  var username;
  var profilePath;
  var birthday;
  var anniversary;
  var couple;

  @override
  initState() {
    super.initState();
    initInfo();
  }

  initInfo() async {
    FirebaseAuth.instance.authStateChanges().listen((currUser) async {
      if (currUser != null) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currUser.uid)
            .get();

        Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;

        username = data['username'];
        profilePath = data['profilePath'];
        birthday = data['birthday'].toDate();
        origBirthday = birthday;
        anniversary = data['anniversary'].toDate();
        couple = data['couple'];
        _usernameController = TextEditingController(text: username);

        setState(() {});
      }
    });
  }

  Future<void> logout() async {
    FirebaseAuth.instance.signOut();
  }

  chooseImage() async {
    XFile? xfile = await ImagePicker().pickImage(source: ImageSource.gallery);
    file = File(xfile!.path);
    setState(() {});
  }

  updateProfile() async {
    if (file != null) {
      String url = await uploadImage();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'profilePath': url});
    }
  }

  Future<String> uploadImage() async {
    TaskSnapshot uploadSnapshot = await FirebaseStorage.instance
        .ref()
        .child('profile')
        .child(
            FirebaseAuth.instance.currentUser!.uid + "_" + basename(file.path))
        .putFile(file);

    return uploadSnapshot.ref.getDownloadURL();
  }

  updateInfo() async {
    final currUser = await FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currUser!.uid)
        .update(
      {
        'username': _usernameController.text,
        'birthday': birthday,
      },
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
        // back navigation bar
        navigationBar: CupertinoNavigationBar(
          //backgroundColor: Colors.deepPurple[200],
          leading: CupertinoNavigationBarBackButton(
              //color: Colors.white,
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => TabPage()))),
        ),

        //content
        child: Column(children: <Widget>[
          const SizedBox(height: 120),
          Center(
            //profile image
            child: Stack(children: [
              buildImage(),
              Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => {
                      chooseImage(),
                    },
                    child: buildEidtIcon(Colors.blue),
                  )),
            ]),
          ),
          const SizedBox(height: 25),
          // user name
          Padding(
            padding: EdgeInsets.only(top: 15, left: 15),
            child: Row(
              children: <Widget>[
                Text(
                  'User Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: TextDecoration.none,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 15),
                Flexible(
                  child: CupertinoTextField.borderless(
                    controller: _usernameController,
                  ),
                ),
              ],
            ),
          ),
          // birthday picker
          Padding(
            padding: EdgeInsets.only(top: 10, left: 15),
            child: Row(
              children: <Widget>[
                Text(
                  'Birthday',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: TextDecoration.none,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 38),
                CupertinoButton(
                  padding: EdgeInsetsDirectional.zero,
                  child: Text(
                    DateFormat('MM/dd/yyyy').format(birthday),
                    style: TextStyle(
                        decoration: TextDecoration.none, color: Colors.black),
                  ),
                  onPressed: () {
                    showCupertinoModalPopup(
                        context: context,
                        builder: (_) => Container(
                              height: 500,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 350,
                                    child: CupertinoDatePicker(
                                      initialDateTime: birthday,
                                      mode: CupertinoDatePickerMode.date,
                                      onDateTimeChanged: (val) {
                                        setState(() {
                                          birthday = val;
                                        });
                                      },
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Confirm',
                                      style: TextStyle(
                                          color: Colors.blue, fontSize: 28),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      birthday = origBirthday;
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  UserPage()));
                                    },
                                    child: Text(
                                      'Nevermind',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          CupertinoButton.filled(
            child: const Text('Save'),
            onPressed: () async {
              updateProfile();
              updateInfo();
            },
          ),
          const SizedBox(height: 10),
          CupertinoButton(
            child: const Text('Sign Out'),
            onPressed: () async {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => DecisionTree()),
              );
            },
          ),
        ]),
      );

  Widget buildImage() {
    String currprofilePath = profilePath ??
        'https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg';
    final image = NetworkImage(currprofilePath);

    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: image,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
        ),
      ),
    );
  }

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );

  Widget buildEidtIcon(Color color) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: color,
          all: 7,
          child: const Icon(
            Icons.edit,
            color: Colors.white,
            size: 15,
          ),
        ),
      );
}
