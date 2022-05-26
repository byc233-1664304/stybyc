import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stybyc/Widgets/intro_widget.dart';
import 'package:stybyc/Widgets/profile_widget.dart';
import 'package:stybyc/Pages/user_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key? key,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var profilePath;
  var couple;
  var coupleProfile =
      'https://isobarscience.com/wp-content/uploads/2020/09/default-profile-picture1.jpg';
  var coupleName;
  var anniversary;

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
        profilePath = data['profilePath'];
        couple = data['couple'];
        anniversary = data['anniversary'].toDate();
        if (couple != null) {
          getCoupleInfo();
        }
        setState(() {});
      }
    });
  }

  getCoupleInfo() async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(couple).get();

    Map<String, dynamic> coupleData = snapshot.data()! as Map<String, dynamic>;
    coupleProfile = coupleData['ProfilePath'];
    coupleName = coupleData['username'];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ProfileWidget(
                      path: profilePath ??
                          'https://isobarscience.com/wp-content/uploads/2020/09/default-profile-picture1.jpg',
                      onClicked: () async {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => UserPage()),
                        );
                      },
                    ),
                    ProfileWidget(
                      path: coupleProfile,
                      onClicked: () async {},
                    ),
                  ]),
              IntroWidget(anniversary: anniversary, hasCouple: couple != null),
            ]),
      ),
    );
  }
}
