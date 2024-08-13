import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:get_storage/get_storage.dart';
import '../../main.dart';
import '../API/api.dart';
import '../Auth/local_auth.dart';
import '../Auth/login_screen.dart';
import '../Controllers/ThemeController.dart';
import 'home_screen.dart';

// Splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool biometricEnabled = false; // Default value
  late GetStorage box;
  bool showRetryButton = false;

  @override
  void initState() {
    super.initState();
    box = GetStorage();
    _initSwitchValues();
    _checkBiometricAndNavigate();
  }

  // Initialize switch values if they are null in GetStorage
  void _initSwitchValues() {
    String key = 'selectedSwitch_1'; // Adjust index if needed
    biometricEnabled = box.read(key) ?? false;
  }

  Future<void> _checkBiometricAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));

    // Exit full-screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      statusBarColor: Colors.white,
    ));

    log('\nUser: ${APIs.auth.currentUser}');

    // Check if biometrics are available and enabled
    bool isBiometricAvailable = await LocalAuth.isBiometricAvailable();
    bool isAuthenticated = false; // Default to false

    if (biometricEnabled && isBiometricAvailable && APIs.auth.currentUser != null) {
      // Try to authenticate using biometrics
      isAuthenticated = await LocalAuth.authenticate();
    }

    // Navigate based on authentication result
    if (isAuthenticated || !biometricEnabled || !isBiometricAvailable) {
      if (APIs.auth.currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      }
    } else {
      setState(() {
        showRetryButton = true;
      });
    }
  }

  Future<void> _retryAuthentication() async {
    bool isAuthenticated = await LocalAuth.authenticate();

    if (isAuthenticated) {
      if (APIs.auth.currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      }
    } else {
      setState(() {
        showRetryButton = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initializing media query (for getting device screen size)
    mq = MediaQuery.sizeOf(context);

    return GetBuilder<ThemeController>(
      id: "0",
      builder: (theme) {
        return Scaffold(
          backgroundColor: theme.backgroundColor2,
          // Body
          body: Stack(
            children: [
              Positioned(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/preview.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // App logo
              Positioned(
                child: Center(
                  child: Text(
                    'Family Time',
                    style: TextStyle(
                      fontSize: 26, // Font size
                      fontWeight: FontWeight.bold, // Font weight (bold)
                      fontStyle: FontStyle.italic, // Font style (italic)
                      color: theme.textColor, // Text color
                      letterSpacing: 1.2, // Spacing between characters
                      decorationStyle: TextDecorationStyle.double, // Decoration style
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
              // Positioned(
              //   top: mq.height * .15,
              //   right: mq.width * .25,
              //   width: mq.width * .5,
              //   child: Image.asset('images/icon.png'),
              // ),
              // Retry button
              if (showRetryButton)
                Positioned(
                  bottom: mq.height * .3,
                  left: mq.width * .3,
                  right: mq.width * .3,
                  child: TextButton(

                    onPressed: _retryAuthentication,
                    child: Text('Unlock', style: TextStyle(color: theme.appbarNeg, fontSize: 18),),
                  ),
                ),
              // Google login button
              Positioned(
                bottom: mq.height * .15,
                width: mq.width,
                child: Text(
                  'MADE FOR FAMILY, WITH ❤️',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: theme.textColor,
                    letterSpacing: .5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
