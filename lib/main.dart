import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_classification/shared_components/custom_button.dart';
import 'package:flutter_image_classification/shared_components/enum.dart';
import 'package:flutter_image_classification/shared_components/images.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
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
  File? _image;
  List<Map<String, dynamic>>? _output;
  late Interpreter interpreter;
  List<String>? labels;
  int imgHeight = 224;
  int imgWidth = 224;
  ModelIs modelIs = ModelIs.notReady;
  String command = '';

  String resultOne = '';
  String resultTwo = '';
  String resultThree = '';

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      setState(() {
        modelIs = ModelIs.loading;
        command = 'Model is loading...';
      });
      await Future.delayed(const Duration(seconds: 5));
      interpreter = await Interpreter.fromAsset('assets/model/mobilenet_v1_1.0_224.tflite');
      labels = await _loadLabels('assets/model/labels.txt');
      setState(() {
        modelIs = ModelIs.ready;
        command = 'Pick an Image';
      });
    } catch (e) {
      print("Failed to load model: $e");
      setState(() {
        modelIs = ModelIs.error;
        command = 'Failed to load model';
      });
    }
  }

  Future<List<String>> _loadLabels(String path) async {
    final labelFile = await rootBundle.loadString(path);
    return labelFile.split('\n');
  }

  Future<void> pickImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _image = File(image.path);
    });

    await _classifyImage(_image!);
  }

  Future<void> _classifyImage(File image) async {
    setState(() {
      modelIs = ModelIs.thinking;
      command = 'Processing the image...';
    });

    // Simulate latency
    await Future.delayed(const Duration(seconds: 5));

    try {
      img.Image? inputImage = img.decodeImage(image.readAsBytesSync());
      if (inputImage == null) {
        throw Exception("Failed to decode image");
      }

      // Convert image to Float32List
      var input = imageToArray(inputImage);

      var output = List.filled(1 * 1001, 0.0).reshape([1, 1001]);

      // Run interpreter
      interpreter.run(input, output);

      // Process output
      var probabilities = output[0];
      var prediction = List<Map<String, dynamic>>.generate(
        probabilities.length,
            (i) => {
          'index': i,
          'label': labels![i],
          'confidence': probabilities[i]
        },
      );

      prediction.sort((a, b) => b['confidence'].compareTo(a['confidence']));

      setState(() {
        _output = prediction.sublist(0, 3);
        resultOne = "It's most likely a ${_output![0]['label']} with a confidence of ${formatConfidence(_output![0]['confidence'] * 100)}.";
        resultTwo = "The second guess is ${_output![1]['label']} with ${formatConfidence(_output![1]['confidence'] * 100)}.";
        resultThree = "Lastly, it could be a ${_output![2]['label']} with ${formatConfidence(_output![2]['confidence'] * 100)}.";
        modelIs = ModelIs.done;
      });
    } catch (e) {
      print("Error during classification: $e");
      setState(() {
        modelIs = ModelIs.error;
        command = "An error occurred during classification. Please try again.";
      });
    }
  }

  String formatConfidence(double confidence) {
    if (confidence < 1) {
      return "<1% confidence";
    }
    return "${confidence.toStringAsFixed(2)}% confidence";
  }



  /// https://github.com/tensorflow/flutter-tflite/issues/249
  List<dynamic> imageToArray(img.Image inputImage) {
    img.Image resizedImage = img.copyResize(inputImage, width: imgWidth, height: imgHeight);
    List<double> flattenedList = resizedImage.data!.expand((channel) => [channel.r, channel.g, channel.b]).map((value) => value.toDouble()).toList();
    Float32List float32Array = Float32List.fromList(flattenedList);
    int channels = 3;
    int height = imgHeight;
    int width = imgWidth;
    Float32List reshapedArray = Float32List(1 * height * width * channels);
    for (int c = 0; c < channels; c++) {
      for (int h = 0; h < height; h++) {
        for (int w = 0; w < width; w++) {
          int index = c * height * width + h * width + w;
          reshapedArray[index] =
              (float32Array[c * height * width + h * width + w] - 127.5) /127.5;
        }
      }
    }
    return reshapedArray.reshape([1, imgWidth, imgHeight, 3]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Classification', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.black12.withOpacity(0.05),
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _image != null
                      ? Image.file(
                    _image!,
                    fit: BoxFit.contain,
                  )
                      : Image.asset(
                    ImageAssets.uploadImg,
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                  if (modelIs == ModelIs.thinking)
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(),
                      ),
                    ),
                  if (modelIs == ModelIs.thinking)
                    Positioned(
                      child: ClipOval(
                        child: Image.asset(ImageAssets.thinking, width: 100,),
                      )
                    ),
                ],
              ),
            ),
          ),
          if (modelIs != ModelIs.done)
            Text(
              command,
              style: TextStyle(
                fontSize: 16,
                color: modelIs == ModelIs.error ? Colors.red : Colors.black,
              ),
            ),
          if (modelIs == ModelIs.done) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            resultOne,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.blueGrey.withOpacity(0.4), thickness: 1),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            resultTwo,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[400],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.blueGrey.withOpacity(0.4), thickness: 1),
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            resultThree,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.blue[300],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Disclaimer: The results are predictions and may not be 100% accurate. Please verify if needed.",
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: PickImageButton(
              onPressed: (modelIs == ModelIs.error) ? null : pickImage,
              isLoading: (modelIs == ModelIs.thinking),
            ),
          ),
        ],
      ),
    );
  }
}
