import 'dart:developer';
import 'dart:convert';
import 'package:fridgetotable/labelled_image.dart';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:wikipedia/wikipedia.dart';

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
      ResolutionPreset.medium,
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
                  image: image,
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

class DisplayPictureScreen extends StatefulWidget {
  final XFile image;

  const DisplayPictureScreen({super.key, required this.image});

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  List<WikipediaSearch> _data = [];
  var response = {};

  @override
  void initState() {
    initVar();
    
            
    super.initState();
  }

  void initVar() async {
    final results = await LabelImage().getLabeledImage(widget.image);
    final newResponse = jsonDecode(results);
    List<String> wikiclass = [];
    for (var pred in newResponse['predictions']) {
        wikiclass.add(pred['class_name']);
    }
    Future.wait(wikiclass.map((species) => getLoadingData(species)))
    .then((List<dynamic> results) {
              setState(() {
                response = newResponse;
                _data = results.cast<WikipediaSearch>();
              });
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body:
          response.isEmpty ? const Center(child: CircularProgressIndicator()) :
             SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.memory(
                      base64Decode(response['predictedImage']),
                      fit: BoxFit.fill,
                    ),
                    Stack(
                      children: [
                        ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: _data.length,
                          padding: const EdgeInsets.all(8),
                          itemBuilder: (context, index) => InkWell(
                            onTap: () async {
                              Wikipedia instance = Wikipedia();
                              var pageData =
                                  await instance.searchSummaryWithPageId(
                                      pageId: _data[index].pageid!);
                              showGeneralDialog(
                                context: context,
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        Scaffold(
                                  appBar: AppBar(
                                    title: Text(_data[index].title!,
                                        style: const TextStyle(
                                            color: Colors.black)),
                                    backgroundColor: Colors.white,
                                    iconTheme: const IconThemeData(
                                        color: Colors.black),
                                  ),
                                  body: ListView(
                                    padding: const EdgeInsets.all(10),
                                    children: [
                                      Text(
                                        pageData!.title!,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        pageData.description!,
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(pageData.extract!)
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 5,
                              margin: const EdgeInsets.all(8),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      _data[index].title!,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(_data[index].snippet!),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
            ));
        }

  Future getLoadingData(species) async {
    Wikipedia instance = Wikipedia();
    var result = await instance.searchQuery(searchQuery: species, limit: 1);
    return result!.query!.search!.first;
  }
}
