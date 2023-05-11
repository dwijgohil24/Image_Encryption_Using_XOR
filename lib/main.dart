import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Encryption using XOR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? image1; //taking image - 1 from gallery
  File? image2; //taking image - 2 from gallery
  File? xorImage;

  Future<void> pickImage(ImageSource source, int index) async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: source);
    if (pickedImage != null) {
      setState(() {
        if (index == 1) {
          image1 = File(pickedImage.path);
        } else if (index == 2) {
          image2 = File(pickedImage.path);
        }
      });
    }
  }

  Future<void> performXOR() async {
    if (image1 != null && image2 != null) {
      final bytes1 = await image1!.readAsBytes();
      final bytes2 = await image2!.readAsBytes();

      // Decode the images using the image package
      final decodedImage1 = img.decodeImage(bytes1);
      final decodedImage2 = img.decodeImage(bytes2);

      // Ensure both images have the same dimensions
      if (decodedImage1!.width != decodedImage2!.width ||
          decodedImage1.height != decodedImage2.height) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content:
                  Text('The selected images must have the same dimensions.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      // Perform XOR operation pixel by pixel ( we can do this for all types of images i.e. grayscale as well as color images.)
      final xorImageResult =
          img.Image(decodedImage1.width, decodedImage1.height);
      for (int y = 0; y < decodedImage1.height; y++) {
        for (int x = 0; x < decodedImage1.width; x++) {
          final color1 = decodedImage1.getPixel(x, y);
          final color2 = decodedImage2.getPixel(x, y);

          final xorR = img.getRed(color1) ^ img.getRed(color2);
          final xorG = img.getGreen(color1) ^ img.getGreen(color2);
          final xorB = img.getBlue(color1) ^ img.getBlue(color2);
          final xorA = img.getAlpha(color1) ^ img.getAlpha(color2);

          xorImageResult.setPixelRgba(x, y, xorR, xorG, xorB);
        }
      }

      // Encode the XOR image to bytes
      final xorImageBytes = img.encodePng(xorImageResult);

      // Create a temporary file to store the XOR result
      final tempDir = await Directory.systemTemp.createTemp();
      final xorImageFile = File(
          '${tempDir.path}/xor_image.png'); //file will be stored in temporary directory with name "xor_image"
      await xorImageFile.writeAsBytes(xorImageBytes);

      setState(() {
        xorImage = xorImageFile;
      });
    }
  }

  //i will be completing this two functions for image retrival later on.
  // Future<void> retrieveImage1() async {
  //   if (image1 != null) {
  //     setState(() {

  //     });
  //   }
  // }

  // Future<void> retrieveImage2() async {
  //   if (image2 != null) {
  //     setState(() {
  //       xorImage = image2;
  //     });
  //   }
  // }

  Widget buildImageContainer(File? image) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: image != null
            ? Image.file(
                image,
                fit: BoxFit.cover,
              )
            : Placeholder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Encryption using XOR'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              buildImageContainer(image1),
              buildImageContainer(image2),
            ],
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => pickImage(ImageSource.gallery, 1),
                child: Text('Select Image 1'),
              ),
              ElevatedButton(
                onPressed: () => pickImage(ImageSource.gallery, 2),
                child: Text('Select Image 2'),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: performXOR,
            child: Text('XOR'),
          ),
          SizedBox(height: 16.0),
          xorImage != null
              ? Expanded(
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    child: Image.file(
                      xorImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Container(),
          // Below code is for retrieval method that will be done later on.
          // SizedBox(height: 16.0),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     ElevatedButton(
          //       onPressed: retrieveImage1,
          //       child: Text('Retrieve Image 1'),
          //     ),
          //     ElevatedButton(
          //       onPressed: retrieveImage2,
          //       child: Text('Retrieve Image 2'),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
