import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> uploadImage(String base64Image) async {
  final url = Uri.parse('https://detect.roboflow.com/data1-bbgfd/2?api_key=Oy4J8qJPnxyXm73F9Ukc&name=YOUR_IMAGE.jpg');
  final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
  final body = {'image': base64Image};

  final response = await http.post(url, headers: headers, body: jsonEncode(body));

  if (response.statusCode == 200) {
    print(response.body);
  } else {
    print('Error: ${response.statusCode}');
  }
}
