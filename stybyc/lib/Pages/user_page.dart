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
import 'package:stybyc/model/authService.dart';
import 'package:stybyc/model/databaseService.dart';
import 'package:emojis/emojis.dart';

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

  var profileFile;
  var backgroundFile;

  var currUserUID;
  var username;
  var email;
  var profilePath;
  var backgroundPath;
  var birthday;
  var anniversary;
  var couple;
  var allowConnection;
  var en;

  @override
  initState() {
    super.initState();
    initInfo();
  }

  initInfo() async {
    Map<String, dynamic> data =
        await AuthService().getUserData() as Map<String, dynamic>;
    currUserUID = data['uid'];
    username = data['username'];
    email = data['email'];
    profilePath = data['profilePath'];
    backgroundPath = data['background'];
    birthday = data['birthday'].toDate();
    origBirthday = birthday;
    anniversary = data['anniversary'].toDate();
    couple = data['couple'];
    allowConnection = data['allowConnection'];
    en = data['language'] == 'en-US';

    _usernameController = TextEditingController(text: username);

    setState(() {});
  }

  Future connect(String coupleEmail, BuildContext context) async {
    // search for partner
    FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: coupleEmail)
        .snapshots()
        .listen((coupleData) async {
      String couple = coupleData.docs[0]['uid'];

      if (coupleData.docs[0]['couple'] != 'NA') {
        // alert this person has a partner already
        Navigator.of(context).pop();
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(
                    en ? 'Something Went Wrong :(' : '出错啦 :(',
                    style: TextStyle(color: Colors.green),
                  ),
                  content: Text(
                    en ? 'This person has a partner already' : '这个人已经有伴啦',
                    style: TextStyle(color: Colors.green),
                  ),
                  actions: [
                    TextButton(
                      child: Text(
                        en ? 'Fine' : '好吧',
                        style: TextStyle(color: Colors.green),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ));
      } else if (coupleData.docs[0]['allowConnection'] == false) {
        // alert this person don't want to be connected
        Navigator.of(context).pop();
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(en ? 'Something Went Wrong :(' : '出错啦 :('),
                  content: Text(en
                      ? 'This person doesn\'t allow any connection'
                      : '这个人不允许来自任何人的配对哦'),
                  actions: [
                    TextButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ));
      } else {
        await DatabaseService(uid: couple).connect(currUserUID);
        await DatabaseService(uid: currUserUID).connect(couple);
        setState(() {});
      }
    });
  }

  Future disconnect() async {
    await DatabaseService(uid: currUserUID).disconnect();
    await DatabaseService(uid: couple).disconnect();

    setState(() {});
  }

  chooseProfile() async {
    XFile? xfile = await ImagePicker().pickImage(source: ImageSource.gallery);
    profileFile = File(xfile!.path);
    setState(() {});
  }

  updateProfile() async {
    if (profileFile != null) {
      String url = await uploadProfileImage();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'profilePath': url});
    }
  }

  Future<String> uploadProfileImage() async {
    TaskSnapshot uploadSnapshot = await FirebaseStorage.instance
        .ref()
        .child('profile')
        .child(FirebaseAuth.instance.currentUser!.uid +
            "_" +
            basename(profileFile.path))
        .putFile(profileFile);

    return uploadSnapshot.ref.getDownloadURL();
  }

  chooseBackground() async {
    XFile? xfile = await ImagePicker().pickImage(source: ImageSource.gallery);
    profileFile = File(xfile!.path);
    setState(() {});
  }

  updateBackground() async {
    if (backgroundFile != null) {
      String url = await uploadProfileImage();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'background': url});
    }
  }

  Future<String> uploadBackgroundImage() async {
    TaskSnapshot uploadSnapshot = await FirebaseStorage.instance
        .ref()
        .child('background')
        .child(FirebaseAuth.instance.currentUser!.uid +
            "_" +
            basename(backgroundFile.path))
        .putFile(backgroundFile);

    return uploadSnapshot.ref.getDownloadURL();
  }

  updateInfo() async {
    final currUser = await FirebaseAuth.instance.currentUser;
    await DatabaseService(uid: currUser!.uid)
        .updateInfo(_usernameController.text.trim(), birthday, allowConnection);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final _coupleEmailController = TextEditingController();

    return Scaffold(
      // back navigation bar
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: CupertinoNavigationBarBackButton(
              //color: Colors.white,
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => TabPage()))),
          actions: [
            PopupMenuButton(
              icon: Icon(Icons.settings, color: Colors.grey[600], size: 30),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0))),
              onSelected: (value) {
                if (value == 0) {
                  // set picture uploader
                  chooseBackground();
                } else if (value == 1) {
                  // TODO: change back to default theme
                } else if (value == 2) {
                  // switch language
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text(en
                                ? 'Are you sure to switch language?'
                                : '你确定要换英文界面吗？'),
                            actions: [
                              TextButton(
                                child: Text(en ? 'Yep' : '确定'),
                                onPressed: () async {
                                  await DatabaseService(uid: currUserUID)
                                      .switchLanguage();
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => UserPage(),
                                  ));
                                },
                              ),
                              TextButton(
                                child: Text(en ? 'Nevermind' : '算了'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ));
                  setState(() {});
                } else {
                  if (couple == 'NA') {
                    // connect menu
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text(en ? 'Connecting with...' : '配对中...'),
                              content: TextField(
                                controller: _coupleEmailController,
                                decoration: InputDecoration(
                                    hintText: en
                                        ? 'Enter your partener\'s email'
                                        : '请输入你想配对的email'),
                              ),
                              actions: [
                                TextButton(
                                  child: Text(en ? 'Confirm' : '确认'),
                                  onPressed: () {
                                    connect(_coupleEmailController.text.trim(),
                                        context);
                                  },
                                )
                              ],
                            ));
                  } else {
                    // disconnect
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text(en ? 'Break Up?' : '分手？'),
                              content: Text(en
                                  ? 'Are you sure you want to break up with your partner?'
                                  : '你确定要和TA分手吗？'),
                              actions: [
                                TextButton(
                                  child: Text(en ? 'Yes :(' : '确定 :('),
                                  onPressed: () {
                                    disconnect();
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => UserPage(),
                                    ));
                                  },
                                ),
                                TextButton(
                                    child: Text(en ? 'Nevermind' : '算了'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    })
                              ],
                            ));
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 0,
                  child: Text(en ? "Change Your Background" : '换背景'),
                ),
                PopupMenuItem(
                  value: 1,
                  child: Text(en ? "Restore Theme Settings" : '恢复默认主题'),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Text(en ? 'Switch to Chinese' : '换英文界面'),
                ),
                PopupMenuItem(
                  value: 3,
                  child: couple == 'NA'
                      ? Text(en ? "Connect to Your Partner" : '配对')
                      : Text(
                          en
                              ? "Break Up ${Emojis.brokenHeart}"
                              : '分手${Emojis.brokenHeart}',
                          style: TextStyle(color: Colors.red),
                        ),
                )
              ],
            ),
          ]),

      //content
      body: Column(children: <Widget>[
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
                    chooseProfile(),
                  },
                  child: buildEidtIcon(Colors.blue),
                )),
          ]),
        ),
        const SizedBox(height: 35),
        // user name
        Container(
          color: Colors.grey.withOpacity(0.1),
          child: Padding(
            padding: EdgeInsets.only(top: 5, left: 25, bottom: 5),
            child: Row(
              children: <Widget>[
                Text(
                  en ? 'User Name' : '用户名',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: TextDecoration.none,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: en ? 194 : 244),
                Flexible(
                  child: CupertinoTextField.borderless(
                    controller: _usernameController,
                  ),
                ),
              ],
            ),
          ),
        ),
        // birthday picker
        Padding(
          padding: EdgeInsets.only(top: 5, left: 25, bottom: 5),
          child: Row(
            children: <Widget>[
              Text(
                en ? 'Birthday' : '生日',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  decoration: TextDecoration.none,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: en ? 185 : 232),
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
                                    en ? 'Confirm' : '确认',
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 28),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    birthday = origBirthday;
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => UserPage()));
                                  },
                                  child: Text(
                                    en ? 'Nevermind' : '取消',
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 20),
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
        Container(
          color: Colors.grey.withOpacity(0.1),
          child: Padding(
            padding: EdgeInsets.only(top: 5, left: 25, bottom: 5),
            child: Row(
              children: [
                Text(
                  en ? 'Allow Connection' : '允许配对',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: TextDecoration.none,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: en ? 150 : 230),
                CupertinoSwitch(
                    value: allowConnection,
                    onChanged: (value) {
                      allowConnection = value;
                      setState(() {});
                    })
              ],
            ),
          ),
        ),
        const SizedBox(height: 25),
        CupertinoButton.filled(
          child: Text(en ? 'Save' : '保存'),
          onPressed: () async {
            updateProfile();
            updateBackground();
            updateInfo();
          },
        ),
        const SizedBox(height: 10),
        CupertinoButton(
          child: Text(en ? 'Sign Out' : '退出登录'),
          onPressed: () async {
            await AuthService().logOut();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => DecisionTree()),
            );
          },
        ),
        const SizedBox(height: 10),
        CupertinoButton(
          child: Text(en ? 'Delete Account' : '删除账号',
              style: TextStyle(color: Colors.red)),
          onPressed: () {
            final _passwordController = TextEditingController();

            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: Text(en
                          ? 'Enter Your Password to Delete Account'
                          : '输入密码来删除账号'),
                      content: TextField(
                        controller: _passwordController,
                        decoration:
                            InputDecoration(hintText: en ? 'Password' : '密码'),
                      ),
                      actions: [
                        TextButton(
                          child: Text(en ? 'Confirm' : '确定'),
                          onPressed: () {
                            try {
                              AuthService().deleteUser(
                                  email, _passwordController.text.trim());
                            } catch (e) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Something Went Wrong!"),
                                    content: Text(e.toString()),
                                    actions: [
                                      TextButton(
                                        child: Text("OK"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                        ),
                        TextButton(
                          child: Text(en ? 'Nevermind' : '算啦'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ));
          },
        ),
      ]),
    );
  }

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
