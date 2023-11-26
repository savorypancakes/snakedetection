import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:fridgetotable/labelled_image.dart';
import 'package:fridgetotable/bounding_box.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: CameraScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera App')),
      resizeToAvoidBottomInset: false, // Prevents bottom overflow
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Align(
                  alignment: Alignment.center,
                  child: CameraPreview(_controller)),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.photo_camera),
        onPressed: () async {
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            if (!mounted) return;

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            log(e.toString());
          }
        },
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Show original image
          // Expanded(child: Image.file(File(imagePath))),

          // Get labeled image
          FutureBuilder(
            future: LabelImage().getLabeledImage(imagePath),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final response = jsonDecode(snapshot.data!);
                // Display predictions
                log(response['predictedImage']);
                
                return Column(children: [
                  Image.memory(
                    base64Decode(response['predictedImage']),
                    fit: BoxFit.fill,
                  ),

                  Text(response['predictions'].toString()),

                  // BoundingBox(results, height, width, screenHeight, screenWidth);
                ]);
              } else {
                return const CircularProgressIndicator();
              }
            },
          )
        ],
      ),
    );
  }
}
