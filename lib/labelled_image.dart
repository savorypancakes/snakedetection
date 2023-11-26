import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class LabelImage {

  final String apiKey = '3hl0ORnAaIR1Bk0yDcO2';
  
  Future<String> getLabeledImage(XFile imagePath) async {

    // Load image as base64 string
    final img.Image capturedImage = img.decodeImage(await imagePath.readAsBytes())!;  
    // Rotate the image based on the EXIF metadata
    final img.Image orientedImage = img.bakeOrientation(capturedImage);
    // Convert the image to base64
    final String base64Image = base64Encode(img.encodeJpg(orientedImage));

    // Call API 
    String url = "https://khush2003-snake-deployment-docker.hf.space/predict";
    var response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "imageBase64": base64Image,
        "confThreshold": 0.5,
        "iouThreshold": 0.6
      })
    );


  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Failed to labeling image');
  }

  }

}