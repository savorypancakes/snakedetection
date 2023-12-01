import 'package:camera/camera.dart';
import 'package:get/get.dart';

class AllController extends GetxController {
  Rx<XFile?> image = Rx<XFile?>(null);

  static AllController get instance => Get.find();

  void setImage(XFile? image) {
    this.image(image);
  }
}