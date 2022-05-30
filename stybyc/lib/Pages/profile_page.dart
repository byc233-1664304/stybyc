import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stybyc/Pages/partnerProfile_page.dart';
import 'package:stybyc/Pages/tab_page.dart';
import 'package:stybyc/Widgets/profile_widget.dart';
import 'package:stybyc/Pages/user_page.dart';
import 'package:stybyc/model/authService.dart';
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
  var en;

  @override
  initState() {
    super.initState();
    initInfo();
  }

  initInfo() async {
    Map<String, dynamic> data =
        await AuthService().getUserData() as Map<String, dynamic>;
    profilePath = data['profilePath'];
    couple = data['couple'];
    anniversary = data['anniversary'].toDate();
    background = data['background'];
    en = data['language'] == 'en-US';

    if (couple != 'NA') {
      getCoupleProfile();
    }
    setState(() {});
  }

  getCoupleProfile() async {
    Map<String, dynamic> coupleData =
        await AuthService().getCoupleData() as Map<String, dynamic>;
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
        FirebaseAuth.instance.authStateChanges().listen((currUser) async {
          final currUser = await FirebaseAuth.instance.currentUser;

          await DatabaseService(uid: couple).connect(currUser!.uid);
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
                          path: profilePath,
                          onClicked: () async {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => UserPage()),
                            );
                          },
                        ),
                        ProfileWidget(
                          path: coupleProfile,
                          onClicked: () async {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: ((context) => PartnerProfilePage())));
                          },
                        ),
                      ]),
                  getIntroWidget(),
                ]),
          ),
        ));
  }

  Widget getIntroWidget() {
    if (couple != 'NA') {
      final difference = DateTime.now().difference(anniversary).inDays;
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          en ? 'We\'ve been together' : '我们已经在一起',
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
                                    en ? 'Confirm' : '确认',
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 28),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    en ? 'Nevermind' : '取消',
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
          Text(en ? 'days!' : '天啦！',
              style: GoogleFonts.indieFlower(fontSize: 28)),
        ]),
      ]);
    } else {
      return Column(children: [
        Text(en ? 'Your partner is on the way...' : '你的伴侣在路上啦...',
            style: GoogleFonts.indieFlower(fontSize: 20)),
        getConnectIntro(),
      ]);
    }
  }

  Widget getConnectIntro() {
    final _coupleEmailController = TextEditingController();
    if (en) {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        GestureDetector(
          onTap: () => {
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
                            connect(_coupleEmailController.text.trim());
                          },
                        )
                      ],
                    )),
          },
          child: Text(
            'Connect ',
            style: GoogleFonts.indieFlower(
                fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
        Text("to your partner right now!",
            style: GoogleFonts.indieFlower(fontSize: 20)),
      ]);
    } else {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('现在就去和TA', style: TextStyle(fontSize: 20)),
        GestureDetector(
          onTap: () => {
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
                            connect(_coupleEmailController.text.trim());
                          },
                        )
                      ],
                    )),
          },
          child: Text(
            ' 配对 ',
            style: TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Text('吧！', style: TextStyle(fontSize: 20)),
      ]);
    }
  }
}
