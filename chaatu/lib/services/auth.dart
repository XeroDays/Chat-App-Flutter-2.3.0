import 'package:chaatu/helpers/sharedPref.dart';
import 'package:chaatu/services/database.dart';
import 'package:chaatu/views/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return await auth.currentUser;
  }

  signInWithCredentials(BuildContext context) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googneAccount = await _googleSignIn.signIn();

    final GoogleSignInAuthentication googleAuth =
        await googneAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    UserCredential userObj =
        await _firebaseAuth.signInWithCredential(credential);

    User? userDetail = userObj.user;
    if (userDetail != null) {
      SharedPrefController().saveUserID(userDetail.uid);
      SharedPrefController().saveEmail(userDetail.email.toString());
      SharedPrefController().saveDisplayName(userDetail.displayName.toString());
      SharedPrefController().saveProfilePic(userDetail.photoURL.toString());
      SharedPrefController().saveUserName(
          userDetail.email!.replaceAll("@gmail.com", "").toString());

      Map<String, dynamic> data = {
        "email": userDetail.email,
        "name": userDetail.displayName,
        "username": userDetail.email!.replaceAll("@gmail.com", ""),
        "photoURL": userDetail.photoURL
      };

      FireDatabase().AddUserToDatabase(userDetail.uid, data).then((value) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => const Home()));
      });
    }
  }

  Future SignOut() async {
    SharedPrefController().ClearAll();
    return await auth.signOut();
  }
}
