import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class LabelImage {

  final String apiKey = '3hl0ORnAaIR1Bk0yDcO2';
  
  Future<String> getLabeledImage(String imagePath) async {

    // Load image as base64 string
    List<int> imageBytes = await File(imagePath).readAsBytes();  
    String base64Image = base64Encode(imageBytes);

    // Call API 
    String url = "https://detect.roboflow.com/snakedetection-krhf0/9?api_key=$apiKey";
    var response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: base64Image,
    );


  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Failed to labeling image');
  }

  }

}