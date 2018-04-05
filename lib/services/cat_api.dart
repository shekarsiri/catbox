import 'dart:async';

import 'package:catbox/models/cat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class CatApi {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static GoogleSignIn _googleSignIn = new GoogleSignIn();

  FirebaseUser firebaseUser;

  CatApi(FirebaseUser user) {
    this.firebaseUser = user;
  }

  static Future<CatApi> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return new CatApi(user);
  }

  Future likeCat(catId) async {
    await Firestore.instance
        .collection('likes')
        .document('$catId:${this.firebaseUser.uid}')
        .setData({});
  }

  Future unlikeCat(catId) async {
    await Firestore.instance
      .collection('likes')
      .document('$catId:${this.firebaseUser.uid}')
      .delete();
  }

  Future<List<Cat>> getAllCats() async {
    final documentList = await Firestore.instance.collection('cats').getDocuments();

    return documentList.documents.map((cat) {
      final data = cat.data;
      return new Cat(
          documentId: cat.documentID,
          catId: data['id'],
          name: data['name'],
          description: data['description'],
          avatar: data['image_url'],
          location: data['location'],
          stars: data['stars'],
          adopted: data['adopted'],
          pictures: data['pictures']?.toList(),
          cattributes: data['cattributes']?.toList());
    }).toList();
  }
}
