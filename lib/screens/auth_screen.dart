import 'dart:io';

import 'package:chat_app/widgets/auth_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  void _submitAuthForm(
      {required String email,
      required String password,
      required String userName,
      required File? image,
      required bool isLogin,
      required BuildContext context}) async {
    try {
      setState(() {
        _isLoading = true;
      });
      UserCredential authResult;
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        final ref = FirebaseStorage.instance
            .ref('user_images')
            .child('${authResult.user!.uid}.jpg');

        await ref.putFile(image!).whenComplete(() {});
        String url = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user?.uid)
            .set({
          'userName': userName,
          'email': email,
          'image_url': url,
        });
      }
    } on FirebaseException catch (error) {
      String errormessage = "An error occured: please check your credentials";

      if (error.message != null) {
        errormessage = error.message!;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errormessage),
        backgroundColor: Theme.of(context).errorColor,
        duration: const Duration(seconds: 2),
      ));
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.toString()),
        backgroundColor: Theme.of(context).errorColor,
        duration: const Duration(seconds: 2),
      ));

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: AuthForm(
        onSubmit: _submitAuthForm,
        isLoading: _isLoading,
      ),
    );
  }
}
