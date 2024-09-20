import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';

//The 2 imports below are previous imports I tried to use for my project to be able to integrate my pytorch model to flutter
//But they are either imports which havent been mantained for many years making it incompatible or uses up multiple conversions which lead to errors in between which was hard to debug
//This is also why I spent multiple days tryng to integrate my model into flutter

//import 'package:tflite/tflite.dart';
//import 'package:tflite_flutter/tflite_flutter.dart';

//Thought of using the import below which might help my model, but it is discontinued

//import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter_pytorch/flutter_pytorch.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Food_Vision",
      home: HelloFlutter()
      
    );
  }
}
class HelloFlutter extends StatefulWidget {
  const HelloFlutter({super.key});

  @override
  _HelloFlutterState createState() => _HelloFlutterState();
}

class _HelloFlutterState extends State<HelloFlutter>{
  int selectedindex=0;
  File? _image;

  File? imageFile;

  late ClassificationModel _model;
  List<String>? labels;
  String? outputLabel;
  List<double?>? predictionListProbabilities;
  
  



  loadModels() async {
    _model = await FlutterPytorch.loadClassificationModel(

      //Integrating this .pt file was such a pain.
      //Spent hours realizing my torchscript model was made while running on 'CUDA' instead of 'CPU'
      "assets/pre_model_7_script_cpu.pt",  
      270, 
      270,labelPath: "assets/labels.txt"//270*270 as effnet_b2 prefers images at 260*260 thus 270 makes more details be visible
    );
    labels = await _loadLabelsFromAssets('assets/labels.txt');
   }
   // Helper function to load labels from the assets
  Future<List<String>> _loadLabelsFromAssets(String assetPath) async {
    String labelData = await rootBundle.loadString(assetPath);
    return labelData.split('\n').where((element) => element.isNotEmpty).toList();
  }

   Future<void> _loadImageFromAssets() async {
    // Load image from assets as bytes
    ByteData byteData = await rootBundle.load('assets/pizza-img.jpg');
    Uint8List imageBytes = byteData.buffer.asUint8List();

   // Decode and resize the image
    img.Image? decodedImage = img.decodeImage(imageBytes);
    img.Image resizedImage = img.copyResize(decodedImage!, width: 270, height: 270);

    // Convert the resized image back to bytes
    Uint8List resizedImageBytes = Uint8List.fromList(img.encodeJpg(resizedImage));

    // Pass the resized image to the model
    predictionListProbabilities =
        await _model.getImagePredictionListProbabilities(resizedImageBytes);

        // Find the index of the highest probability
    int maxIndex = predictionListProbabilities!.indexOf(predictionListProbabilities?.reduce((a, b) => a! > b! ? a : b));
    

    // Set the result to display
    setState(() {
      _image = File('assets/pizza-img.jpg'); // Display the image from assets
      outputLabel = labels![maxIndex]; // Set prediction result
    });

   }

   

  @override
  void dispose() {
    //This function disposes and clears our memory
    super.dispose();
    
  }
  @override
  void initState() {
    //initState is the first function that is executed by default when this class is called
    super.initState();
    loadModels().then((_) {
      _loadImageFromAssets();
    });
    
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food_Vision')),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('food2-bg.png'),fit: BoxFit.fill,
          
          
          ),
          color: Colors.cyan
        ),


      
      child: Center(
        child:_image==null?
         const Text('FoodVision',

        style: TextStyle(
            color: Colors.yellow,
            fontSize: 80.0,
            fontWeight: FontWeight.w700,
          )
         )
          : Column(
        children: [
          Image.asset('assets/pizza-img.jpg'), // Show the loaded image
          //Image.file(_image!),
          const SizedBox(height: 20),
          outputLabel != null
           ? Text(
                  'Prediction: $outputLabel', // Adjust to match output format
                  //'Probabilitiesss: $predictionListProbabilities',

                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 50.0,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : Container(),
        ],
      ),
        ),
      ),

//For the future when I want to implement a bottom navigation bar

/*
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedindex,
          fixedColor: Colors.green,
          items: const [
            BottomNavigationBarItem(
              label: "Gallery",
              icon: Icon(Icons.photo),
            ),
            BottomNavigationBarItem(
              label: "Camera",
              icon: Icon(Icons.camera_alt),
            ),
          ],
          onTap: _onItemTapped,
          ),
      */
    );

    
  }


}