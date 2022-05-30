import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stybyc/Pages/tab_page.dart';
import 'package:stybyc/Widgets/profile_widget.dart';
import 'package:stybyc/Pages/user_page.dart';
import 'package:stybyc/model/databaseService.dart';

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
      'https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg';
  var anniversary;
  var background;

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
        background = data['background'];
        if (couple != '') {
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
    setState(() {});
  }

  Future connect(String coupleEmail) async {
    // search for partner
    FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: coupleEmail)
        .snapshots()
        .listen((coupleData) {
      String couple = coupleData.docs[0]['uid'];

      if (coupleData.docs[0]['couple'] != '') {
        // alert this person has a partner already
        Navigator.of(context).pop();
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(
                    'Something Went Wrong :(',
                    style: TextStyle(color: Colors.green),
                  ),
                  content: Text(
                    'This person has a partner already',
                    style: TextStyle(color: Colors.green),
                  ),
                  actions: [
                    TextButton(
                      child: Text(
                        'Fine',
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
                  title: Text('Something Went Wrong :('),
                  content: Text('This person doesn\'t allow any connection'),
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
        FirebaseAuth.instance.authStateChanges().listen((currUser) async {
          final currUser = await FirebaseAuth.instance.currentUser;

          // update partner's side of information about user
          DocumentSnapshot snapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(currUser!.uid)
              .get();

          Map<String, dynamic> userData =
              snapshot.data()! as Map<String, dynamic>;

          await DatabaseService(uid: couple).connect(currUser.uid);
          await DatabaseService(uid: currUser.uid).connect(couple);

          setState(() {});
        });
      }
    });
  }

  updateAnniversary() async {
    final currUser = await FirebaseAuth.instance.currentUser;
    // update user
    await DatabaseService(uid: currUser!.uid).updateAnniversary(anniversary);

    //update partner
    await DatabaseService(uid: couple).updateAnniversary(anniversary);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints.expand(),
        //decoration: BoxDecoration(
        //image: DecorationImage(
        //image: NetworkImage(background),
        //fit: BoxFit.cover,
        //)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ProfileWidget(
                          path: profilePath ??
                              'https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg',
                          onClicked: () async {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => UserPage()),
                            );
                          },
                        ),
                        ProfileWidget(
                          path: coupleProfile,
                          onClicked: () async {},
                        ),
                      ]),
                  getIntroWidget(),
                ]),
          ),
        ));
  }

  Widget getIntroWidget() {
    final _coupleEmailController = TextEditingController();
    if (couple != 'NA') {
      final difference = DateTime.now().difference(anniversary).inDays;
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          'We\'ve been together',
          style: GoogleFonts.indieFlower(fontSize: 28),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          GestureDetector(
            onTap: () => {
              showCupertinoModalPopup(
                  context: context,
                  builder: (_) => Container(
                        height: 500,
                        color: Colors.white,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 300,
                              child: CupertinoDatePicker(
                                initialDateTime: anniversary,
                                mode: CupertinoDatePickerMode.date,
                                onDateTimeChanged: (val) {
                                  setState(() {
                                    anniversary = val;
                                  });
                                },
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    // update anniversary
                                    updateAnniversary();
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => TabPage()));
                                  },
                                  child: Text(
                                    'Confirm',
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 28),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Nevermind',
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 20),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
            },
            child: Text(
              ' $difference ',
              style: GoogleFonts.indieFlower(
                  fontSize: 28,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Text('days!', style: GoogleFonts.indieFlower(fontSize: 28)),
        ]),
      ]);
    } else {
      return Column(children: [
        Text('Your partner is on the way...',
            style: GoogleFonts.indieFlower(fontSize: 20)),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          GestureDetector(
            onTap: () => {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text('Connecting with...'),
                        content: TextField(
                          controller: _coupleEmailController,
                          decoration: InputDecoration(
                              hintText: 'Enter your partener\'s email'),
                        ),
                        actions: [
                          TextButton(
                            child: Text('Confirm'),
                            onPressed: () {
                              connect(_coupleEmailController.text.trim());
                            },
                          )
                        ],
                      )),
            },
            child: Text(
              'Connect ',
              style: GoogleFonts.indieFlower(
                  fontSize: 20,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Text("to your partner right now!",
              style: GoogleFonts.indieFlower(fontSize: 20)),
        ])
      ]);
    }
  }
}
