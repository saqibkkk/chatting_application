import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ourchat/Screens/home_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ourchat/utils.dart';
import '../../API/api.dart';
import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(microseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleBtnClick(BuildContext context) {
    Utils.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      print("User: ${user?.user}");
      print("UserAdditionalInfo: ${user?.additionalUserInfo}");

      if(await APIs.userExists()){
        Navigator.pop(context);
        if(user != null){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
        }
      }else{
        APIs.createUser().then((value){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
        });
      }



    });
  }



  Future<UserCredential?> _signInWithGoogle() async {
    try{
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    }catch(e){
      print('_signInWithGoogle: $e');
      Utils.showSnackbar(context, "Check your internet connection!");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Welcome to Family Chat'),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
              top: mq.height * .15,
              right: _isAnimate ? mq.width * .25 : -mq.width * .5,
              width: mq.width * .5,
              duration: Duration(seconds: 1),
              child: Image.asset('images/icon.png')),
          Positioned(
              bottom: mq.height * .15,
              left: mq.width * .15,
              width: mq.width * .7,
              height: mq.height * .05,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                      shape: StadiumBorder(),
                      elevation: 2),
                  onPressed: () {
                    _handleGoogleBtnClick(context);

                  },
                  icon: Image.asset(
                    'images/google.png',
                    height: mq.height * .025,
                  ),
                  label: RichText(
                    text: TextSpan(
                        style: TextStyle(fontSize: 16, color: Colors.black),
                        children: [
                          TextSpan(text: 'Sign In with '),
                          TextSpan(
                              text: 'Google',
                              style: TextStyle(fontWeight: FontWeight.bold))
                        ]),
                  )))
        ],
      ),
    );
  }
}
