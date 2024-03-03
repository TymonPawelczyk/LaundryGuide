import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraApp(camera: camera),
    );
  }
}

class CameraApp extends StatefulWidget {
  final CameraDescription camera;

  const CameraApp({super.key, required this.camera});

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

                await _controller.takePicture();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DisplayInfoScreen(),
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

  const DisplayInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = 4;
    return Scaffold(
      appBar: AppBar(title: const Text('Washing instructions')),
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(
                  items, (index) => ItemWidget(text: 'Item $index')),
            ),
          ),
        );
      }),
    );
  }
}
class ItemWidget extends StatelessWidget {
  const ItemWidget({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 100,
        child: Center(child: Text(text)),
      ),
    );
  }
}