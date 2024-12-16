import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_image_classification/shared_components/custom_button.dart';
import 'package:flutter_image_classification/shared_components/images.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImageClassification(),
    );
  }
}

class ImageClassification extends StatefulWidget {
  const ImageClassification({super.key});

  @override
  State<ImageClassification> createState() => _ImageClassificationState();
}

class _ImageClassificationState extends State<ImageClassification> {
  bool image = true;
  bool isModelThinking = false;
  String img = 'assets/image/image.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Classification'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.black12.withOpacity(0.05),
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Image
                  image
                      ? Image.asset(
                    img,
                    fit: BoxFit.contain,
                  )
                      : Image.asset(
                    ImageAssets.uploadImg,
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                  if (isModelThinking)
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(),
                      ),
                    ),
                  if (isModelThinking)
                    Positioned(
                      child: ClipOval(
                        child: Image.asset(ImageAssets.thinking, width: 100,),
                      )
                    ),
                ],
              ),
            ),
          ),
          if(true)
            Text(
              'Model is thinking...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          if(!isModelThinking) ...[
            Text(
              'Line 1',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
            Text(
              'Line 2',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.amber,
              ),
            ),
            Text(
              'Line 3',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Color(0xFFF44336),
              ),
            ),
          ],
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: PickImageButton(
              onPressed: () {},
              isloading: false,
            ),
          ),
        ],
      ),
    );
  }
}
