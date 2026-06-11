import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../utils/debug_print.dart';

abstract class BaseController extends GetxController {
  final RxBool isBusy = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> runBusy(Future<void> Function() task) async {
    isBusy.value = true;
    errorMessage.value = '';
    try {
      await task();
    } catch (e) {
      errorMessage.value = '$e';
      dPrint('runBusy error: $e');
    } finally {
      isBusy.value = false;
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(msg: message);
  }
}
