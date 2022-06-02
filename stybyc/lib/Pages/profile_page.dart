import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stybyc/Pages/partnerProfile_page.dart';
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
  final userUID = FirebaseAuth.instance.currentUser!.uid;
  final database = FirebaseDatabase.instance.ref();
  final _coupleEmailController = TextEditingController();

  late final partner;
  late final email;
  late final profilePath;
  var partnerProfile =
      'https://i.pinimg.com/474x/fa/54/1b/fa541b60cccf4b85f25d97bf49d1d57c.jpg';
  var anniversary;
  late final background;
  late final en;

  @override
  initState() {
    super.initState();
    initInfo();
  }

  void initInfo() {
    database.child(userUID).onValue.listen((event) {
      final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      setState(() async {
        partner = data['partner'].toString();
        email = data['email'];
        profilePath = data['profilePath'];
        anniversary = data['anniversary'];
        background = data['background'];
        en = data['language'].toString().startsWith('en');

        if (partner != 'NA') {
          final snapshot =
              await database.child(partner).child('profilePath').get();
          partnerProfile = snapshot.value.toString();
        }
      });
    });
  }

  Future connect(String partnerEmail) async {
    if (partnerEmail == email) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(
                  en ? 'Something Went Wrong :(' : '出错啦 :(',
                ),
                content: Text(
                  en
                      ? 'You can\'t connect with yourself :('
                      : '不会吧不会吧，不会真的有人自攻自受的吧',
                ),
                actions: [
                  TextButton(
                    child: Text(
                      en ? 'Enter Someone Else\'s Email' : '输入别的邮箱',
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ));
    } else {
      late final partnerUID;
      final snapshot = await FirebaseDatabase.instance
          .ref()
          .orderByChild('email')
          .equalTo(partnerEmail)
          .get()
          .then((snapshot) {
        Map<dynamic, dynamic> m =
            Map<dynamic, dynamic>.from(snapshot.value as Map);
        partnerUID = m.keys.first;
      });

      // search for partner
      final psnapshot =
          await FirebaseDatabase.instance.ref('$partnerUID/partner').get();
      final partnerPartner = psnapshot.value;

      final asnapshot = await FirebaseDatabase.instance
          .ref('$partnerUID/allowConnection')
          .get();
      final partnerAllow = asnapshot.value;

      if (partnerPartner != 'NA') {
        // alert this person has a partner already
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
      } else if (partnerAllow == false) {
        // alert this person has a partner already
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
        await DatabaseService(uid: partnerUID).connect(userUID);
        setState(() {});
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const ProfilePage()));
      }
    }
  }

  updateAnniversary() async {
    // update user
    await DatabaseService(uid: userUID).updateAnniversary(partner, anniversary);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
          image: DecorationImage(
        image: NetworkImage(background),
        fit: BoxFit.cover,
      )),
      child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    getmyProfile(),
                    getPartnerProfile(),
                  ]),
              getIntroWidget(),
            ]),
      ),
    ));
  }

  Widget getmyProfile() {
    return ProfileWidget(
      path: profilePath,
      onClicked: () async {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => UserPage()),
        );
      },
    );
  }

  Widget getPartnerProfile() {
    return ProfileWidget(
      path: partnerProfile,
      onClicked: () async {
        if (partner != 'NA') {
          Navigator.of(context).push(
              MaterialPageRoute(builder: ((context) => PartnerProfilePage())));
        } else {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text(en ? 'Your partner is lost' : '你的TA迷路了哦'),
                    content: TextField(
                      controller: _coupleEmailController,
                      decoration: InputDecoration(
                          hintText: en
                              ? 'Enter your partner\'s email'
                              : '输入TA的email来配对吧'),
                    ),
                    actions: [
                      TextButton(
                        child: Text(en ? 'Confirm' : '确认'),
                        onPressed: () {
                          connect(_coupleEmailController.text.trim());
                        },
                      )
                    ],
                  ));
        }
      },
    );
  }

  Widget getIntroWidget() {
    if (partner != 'NA') {
      final anniversaryDateTime = DateFormat('yMd').parse(anniversary);
      final difference = DateTime.now().difference(anniversaryDateTime).inDays;
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
                                initialDateTime:
                                    DateFormat('yMd').parse(anniversary),
                                mode: CupertinoDatePickerMode.date,
                                onDateTimeChanged: (val) {
                                  setState(() {
                                    anniversary = DateFormat('yMd').format(val);
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
                        ),
                        TextButton(
                          child: Text(en ? 'Nevermind' : '取消'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
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
