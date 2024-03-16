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
    final bytes = await imageFile.readAsBytes();
    final String base64Image = base64Encode(bytes);

    // Replace 'YOUR_API_URL' with the actual URL of your API
    final apiUrl = 'https://detect.roboflow.com';
    final apiKey = 'lKrd6w3ZzKhPQOGNdKfQ';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
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

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DisplayInfoScreen(
                      itemsText: [
                        "Prać w 40 stopniach z wirowaniem. ",
                        "Można suszyć w suszarce mechanicznej w temperaturze 50 stopni.",
                        "Prasować przy użyciu niskiej temperatury.",
                      ],
                    ),
                  ),
                );
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

class DisplayInfoScreen extends StatelessWidget {
  final List<String> itemsText; // Lista tekstów

  const DisplayInfoScreen({Key? key, required this.itemsText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Washing instructions')),
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: itemsText.map((text) => ItemWidget(text: text)).toList(),
              // Tworzenie ItemWidget dla każdego tekstu
            ),
          ),
        );
      }),
    );
  }
}

class ItemWidget extends StatelessWidget {
  final String text;

  const ItemWidget({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 150,
        child: Center(child: Text(text)),
      ),
    );
  }
}
