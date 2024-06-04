import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:torch_light/torch_light.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? imageSelected;
  bool isTorchOn = false;

  /// Select image from gallery
  Future<void> selectImageFromGallery() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      imageSelected = image;
    });
  }

  /// Check if torchlight is available
  Future<bool> isTorchAvailable() async {
    try {
      return await TorchLight.isTorchAvailable();
    } on Exception catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Error checking torch availability"),
      ));
      return false;
    }
  }

  /// Turn torch off or on
  Future<void> activateTorch() async {
    try {
      if (await isTorchAvailable()) {
        //enable or disable torch based on it's current state
        if (isTorchOn) {
          await TorchLight.disableTorch();
        } else {
          await TorchLight.enableTorch();
        }

        // update state of torch variable
        setState(() {
          isTorchOn = !isTorchOn;
        });
      }
    } on Exception catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Could not manipulate torch"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("LocalApp"),
          elevation: 0,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // spacing
            const SizedBox(height: 20),

            // Action button to pick image
            ElevatedButton(
              onPressed: () => selectImageFromGallery(),
              child: (imageSelected == null)
                  ? const Text("Select Image")
                  : const Text("Change Image"),
            ),

            // spacing
            const SizedBox(height: 10),

            // Image display
            Center(
              child: (imageSelected == null)
                  ? const Text("No image")
                  : Image.file(File(imageSelected!.path)),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => activateTorch(),
          child: const Icon(Icons.highlight),
        ),
      ),
    );
  }
}
