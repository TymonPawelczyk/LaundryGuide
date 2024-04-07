import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({Key? key, required this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraApp(camera: camera),
    );
  }
}

class CameraApp extends StatefulWidget {
  final CameraDescription camera;

  const CameraApp({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraAppState createState() {
    return _CameraAppState();
  }
}

class _CameraAppState extends State<CameraApp> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendImageToAPI(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64.encode(bytes);

      final apiUrl = 'https://detect.roboflow.com';
      final apiKey = 'yb6nqytNwYlGzTcZjzvn';

      final request = http.MultipartRequest('POST', Uri.parse('$apiUrl/data1-bbgfd/2?api_key=$apiKey'));
      request.fields['image'] = base64Image;

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        // Handle successful response
        print(responseBody);
      } else {
        // Handle error response
        print('Error sending image to API: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      print('Error sending image to API: $e');
    }
  }

  Future<void> _sendAssetImageToAPI() async {
    try {
      final image = await rootBundle.load('assets/photo.jpg');
      final bytes = image.buffer.asUint8List();
      final base64Image = base64.encode(bytes);

      final apiUrl = 'https://detect.roboflow.com';
      final apiKey = 'yb6nqytNwYlGzTcZjzvn';

      final request = http.MultipartRequest('POST', Uri.parse('$apiUrl/data1-bbgfd/2?api_key=$apiKey'));
      request.fields['image'] = base64Image;

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        // Handle successful response
        print(responseBody);
      } else {
        // Handle error response
        print('Error sending image to API: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      print('Error sending image to API: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WashedApp'),
      ),
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0, left: 35.0),
              child: FloatingActionButton(
                onPressed: () async {
                  try {
                    await _initializeControllerFuture;
                    final XFile imageFile = await _controller.takePicture();
                    await _sendImageToAPI(imageFile);
                  } catch (e) {
                    print(e);
                  }
                },
                backgroundColor: Colors.transparent,
                child: Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4.0,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt,
                      size: 32.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0, left: 35.0),
              child: FloatingActionButton(
                onPressed: () async {
                  await _sendAssetImageToAPI();
                },
                backgroundColor: Colors.transparent,
                child: Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4.0,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.photo_library,
                      size: 32.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
