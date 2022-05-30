import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stybyc/model/databaseService.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future logOut() async {
    _auth.signOut();
  }

  Future<Map<String, dynamic>> getUserData() async {
    final currUser = _auth.currentUser;
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currUser!.uid)
        .get();

    Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;

    return data;
  }

  Future<Map<String, dynamic>> getCoupleData() async {
    late final data;
    Map<String, dynamic> userData = await getUserData() as Map<String, dynamic>;
    String couple = userData['couple'];
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(couple).get();

    data = snapshot.data()! as Map<String, dynamic>;

    return data;
  }

  Future deleteUser(String email, String password) async {
    try {
      User user = await _auth.currentUser!;
      AuthCredential credentials =
          EmailAuthProvider.credential(email: email, password: password);
      print(user);
      final result = await user.reauthenticateWithCredential(credentials);
      await DatabaseService(uid: result.user!.uid)
          .deleteuser(); // called from database class
      await result.user!.delete();
      return true;
    } catch (e) {
      print(e.toString());
    }
  }
}
