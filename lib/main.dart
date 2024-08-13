import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ourchat/Models/messages_model.dart';
import 'package:ourchat/Screens/splashscreen.dart';
import 'Controllers/ThemeController.dart';
import 'Controllers/chatreplycontroller.dart';
import 'firebase_options.dart';

late Size mq;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await _initializeFirebase();

  await GetStorage.init();

  // Initialize ThemeController
  final themeController = Get.put(ThemeController());
  Get.put(ReplyingController());
  await themeController.getTheme();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Family Time',
      theme: ThemeData.light().copyWith(
        primaryColor: Get.find<ThemeController>().primaryColor,
         buttonTheme: ButtonThemeData(
          buttonColor: Get.find<ThemeController>().buttonColor,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Get.find<ThemeController>().primaryColor,
          buttonTheme: ButtonThemeData(
          buttonColor: Get.find<ThemeController>().buttonColor,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      themeMode: Get.find<ThemeController>().theme == "0" ? ThemeMode.light : ThemeMode.dark,
      home: SplashScreen(),
    );
  }
}

_initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var result = await FlutterNotificationChannel().registerNotificationChannel(
    description: 'For showing notifications',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );
  print(result);
}
