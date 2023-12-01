import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:fridgetotable/all_pages_state.dart';
import 'package:fridgetotable/display_image.dart';
import 'package:get/get.dart';

class CameraScreenController extends GetxController {
  late CameraController controller;
  final allcontroller = AllController.instance;
  Rx<bool> isCameraReady = false.obs;

  void takePicture() async {
    try {
      // Attempt to take a picture and get the file `image`
      // where it was saved.
      final image = await controller.takePicture();
      allcontroller.setImage(image);

      Get.to(() => DisplayImage());
    } catch (e) {
      // If an error occurs, log the error to the console.
      log(e.toString());
    }
  }

  @override
  void onInit() async {
    super.onInit();
    final cameras = await availableCameras();
    final firstCamera = cameras[0];
    controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );
    await controller.initialize();
    isCameraReady(true);
  }
}
