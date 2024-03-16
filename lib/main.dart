import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
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
      final String base64Image = base64.encode(bytes);

      final apiUrl = 'https://detect.roboflow.com';
      final apiKey = 'yb6nqytNwYlGzTcZjzvn';

      final response = await http.post(
        Uri.parse('$apiUrl/data1-bbgfd/2?api_key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'image': base64Image}),
      );

      // Handle response from API if needed
      print(response.statusCode);
      print(response.body);
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
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 35.0),
          child: FloatingActionButton(
            onPressed: () async {
              try {
                await _initializeControllerFuture;

                final XFile imageFile = await _controller.takePicture();

                // Send the taken picture to the API
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
    );
  }
}
