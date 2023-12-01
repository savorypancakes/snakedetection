import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:fridgetotable/all_pages_state.dart';
import 'package:fridgetotable/labelled_image.dart';
import 'package:fridgetotable/main.dart';
import 'package:get/get.dart';

class DisplayImageController extends GetxController {
  Rx<XFile?> image = AllController.instance.image;
  final wikiResults = [].obs;
  Rx<Uint8List> predictedImage = base64Decode("").obs;
  // final predictions = "".obs;
  Rx<bool> isPredicting = true.obs;
  RxList<Prediction> predictions = <Prediction>[].obs;

  @override
  void onReady() {
    if (image.value != null) {
      fetchPredictedImage();
    }
    super.onReady();
  }

  void fetchPredictedImage() async {
    await LabelImage().getLabeledImage(image.value!).then((value) {
      final response = jsonDecode(value);
      predictedImage(base64Decode(response['predictedImage']));
      getPredicitonsObject(response);
      getWikipediaData(response['predictions']).then((res) {
        wikiResults(res);
      });
      isPredicting(false);
    });
  }

  void getPredicitonsObject(response) {
    for (int i = 0; i < response['predictions'].length; i++) {
      log(response['predictions'].toString());
      predictions.add(Prediction(
          className: response['predictions'][i]["class_name"],
          confidence: response['predictions'][i]["confidence"]));
    }
  }
}

class Prediction {
  String? className;
  double? confidence;
  Prediction({this.className, this.confidence});
}
