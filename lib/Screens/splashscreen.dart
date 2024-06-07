import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ourchat/API/api.dart';
import 'package:ourchat/Screens/Auth/login_screen.dart';
import 'package:ourchat/Screens/home_screen.dart';

import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 1500), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(systemNavigationBarColor: Colors.white, statusBarColor: Colors.white,)
      );
      if(APIs.auth.currentUser != null){
        print("User: ${APIs.auth.currentUser}");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeScreen()));

      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LoginScreen()));

      }
    });
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
          Positioned(
              top: mq.height * .15,
              right: mq.width * .25,
              width: mq.width * .5,
              child: Image.asset('images/icon.png')),
          Positioned(
              bottom: mq.height * .15,
              width: mq.width ,
              child: Text('MADE   FOR   FAMILY,   WITH ❤️',textAlign: TextAlign.center, style: TextStyle(fontSize: 22,color: Colors.black87, letterSpacing: 3, fontWeight: FontWeight.w700),))
        ],
      ),
    );
  }
}
