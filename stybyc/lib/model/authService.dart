import 'package:firebase_auth/firebase_auth.dart';
import 'package:stybyc/model/databaseService.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future logOut() async {
    _auth.signOut();
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
