import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:office_of_the_dean/screens/home.dart';
import 'package:office_of_the_dean/screens/signin.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

class AuthService {
  //handles Auth
  handleAuth() {
    return StreamBuilder(
        stream: auth.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            return MyHomePage();
          } else {
            return SignIn();
          }
        });
  }

  signInWithEmailAndPassword(String email, String password) async {
    try {
      await auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((userCreds) {
        User? user = userCreds.user;
        firestore.collection('users').doc(user!.uid).set({
          'email': user.email,
          'uid': user.uid,
        });
      });
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
          msg: e.message!,
          gravity: ToastGravity.TOP,
          toastLength: Toast.LENGTH_LONG);
      return null;
    }
  }

  signUpWithEmailAndPassword(email, password) async {
    try {
      await auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((userCreds) {
        User? user = userCreds.user;
        firestore.collection('users').doc(user!.uid).set({
          'email': user.email,
          'uid': user.uid,
        });
      });
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
          msg: e.message!,
          gravity: ToastGravity.TOP,
          toastLength: Toast.LENGTH_LONG);
      return null;
    }
  }

  signOut() {
    auth.signOut();
  }
}
