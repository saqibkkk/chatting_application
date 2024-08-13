import 'package:get/get.dart';

class ReplyingController extends GetxController {
  var isReplying = false;

  void setReplying(bool value) {
    isReplying = value;
    update(["0"]);
  }
}
