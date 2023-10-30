// ignore_for_file: depend_on_referenced_packages

import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path/path.dart';

Future<void> uploadImage(File imageFile) async {
  // Replace with your server's API endpoint for image upload
  String apiUrl = "http://192.168.1.19:5000/detect_image";

  try {
    var request = http.MultipartRequest("POST", Uri.parse(apiUrl));
    request.files.add(
      http.MultipartFile.fromBytes(
        'file', // Field name for the file
        await imageFile.readAsBytes(), // Read the file content as bytes
        filename:
            basename(imageFile.path), // You can set the desired filename here
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // Image uploaded and processed successfully
      print("Image processed successfully.");
      // Handle success, e.g., show a success message to the user.
    } else {
      // Handle errors, e.g., show an error message to the user.
      print("Image processing failed. Status Code: ${response.statusCode}");
    }
  } catch (e) {
    // Handle exceptions, e.g., network errors.
    print("Exception occurred: $e");
  }
}

Future<String?> getProcessedImage(String imagePath) async {
  // Replace with your server's API endpoint for getting processed images
  String apiUrl = "http://192.168.1.19:5000/get_image?image_path=$imagePath";

  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // Process the response, e.g., display the retrieved image.
      // You can use response.body to access the image data.
    } else {
      // Handle errors, e.g., show an error message to the user.
      print("Image retrieval failed. Status Code: ${response.statusCode}");
    }
  } catch (e) {
    // Handle exceptions, e.g., network errors.
    print("Exception occurred: $e");
  }
  return null;
}
