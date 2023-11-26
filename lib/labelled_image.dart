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