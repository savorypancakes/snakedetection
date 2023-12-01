import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fridgetotable/camera_screen_controller.dart';
import 'package:get/get.dart';

class CameraScreen extends StatelessWidget {
  final controller = Get.put(CameraScreenController());
  CameraScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Camera App')),
      resizeToAvoidBottomInset: false, // Prevents bottom overflow
      body: 
      Obx(() => controller.isCameraReady.value ? SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Align(
                        alignment: Alignment.center,
                        child: CameraPreview(controller.controller)),
                  ) : const CircularProgressIndicator()
                  ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.takePicture,
        child: const Icon(Icons.photo_camera),
      ),
    );
  }
}
