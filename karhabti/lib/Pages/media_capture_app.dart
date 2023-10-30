// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:karhabti/usedMethods/model.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path/path.dart';

class MediaCaptureApp extends StatefulWidget {
  const MediaCaptureApp({Key? key}) : super(key: key);

  @override
  State<MediaCaptureApp> createState() => _MediaCaptureAppState();
}

class _MediaCaptureAppState extends State<MediaCaptureApp> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  File? _treatedImageFile;

  Future<void> _capturePhoto() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        _treatedImageFile =
            null; // Reset treated image when a new image is captured.
      });
    } else {
      // The user canceled the capture.
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        _treatedImageFile =
            null; // Reset treated image when a new image is picked.
      });
    } else {
      // The user canceled the capture.
    }
  }

  Future<void> _applyTreatment() async {
    if (_imageFile != null) {
      String imagePath = _imageFile!.path;
      File imageFile = File(imagePath);

      // Use imageFile for any file operations, e.g., passing it to uploadImage.
      uploadImage(imageFile);

      String? res = getProcessedImage(
              'D:\\WafaMefteh\\resultdeployement\\${basename(imagePath)}')
          as String?;

      // Decode the base64 string to binary data
      Uint8List binaryData = base64.decode(res!.split(',').last);

      // Decoding binary data to an image
      Image image = Image.memory(binaryData);

      setState(() {
        _treatedImageFile = image as File?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          if (_imageFile != null)
            Image.file(File(_imageFile!.path)), // Display the original image
          if (_treatedImageFile != null)
            Image.file(
                File(_treatedImageFile!.path)), // Display the treated image
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.lightGreen,
            onPressed: _capturePhoto,
            child: const Icon(Icons.camera_alt),
          ),
          FloatingActionButton(
            backgroundColor: Colors.lightGreen,
            onPressed: _pickImageFromGallery,
            child: const Icon(Icons.photo),
          ),
          FloatingActionButton(
            backgroundColor: Colors.lightGreen, // Change the color as needed
            onPressed: _applyTreatment,
            child: const Icon(Icons.auto_awesome), // Change the icon as needed
          ),
        ],
      ),
    );
  }
}
