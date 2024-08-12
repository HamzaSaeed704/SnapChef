import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/gestures.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('Building MyApp');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SnapChef',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Use MaterialColor here
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedFeature = '';
  Position? _currentPosition;
  String _country = '';

  @override
  void initState() {
    super.initState();
    print('HomePage initState called');
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    print('Getting current location');
    final status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        print('Position obtained: $position');
        setState(() {
          _currentPosition = position;
        });
        _determineCountry(position.latitude, position.longitude);
      } catch (e) {
        print('Error getting location: $e');
      }
    } else {
      print('Location permission denied');
    }
  }

  Future<void> _determineCountry(double latitude, double longitude) async {
    print('Determining country for lat: $latitude, long: $longitude');
    if (latitude >= 6.75 &&
        latitude <= 35.5 &&
        longitude >= 68.0 &&
        longitude <= 97.0) {
      setState(() {
        _country = 'India';
      });
    } else if (latitude >= 23.5 &&
        latitude <= 37.0 &&
        longitude >= 60.5 &&
        longitude <= 77.0) {
      setState(() {
        _country = 'Pakistan';
      });
    } else {
      setState(() {
        _country = 'Other';
      });
    }
    print('Country determined: $_country');
  }

  void _selectFeature(String feature) {
    print('Feature selected: $feature');
    setState(() {
      _selectedFeature = feature;
    });
    _showImageSelectionDialog();
  }

  Future<void> _showImageSelectionDialog() async {
    print('Showing image selection dialog');
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text('Take a picture'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImage(ImageSource.camera);
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text('Select from gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    print('Getting image from $source');
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      File image = File(pickedFile.path);
      print('Image picked: ${image.path}');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LoadingScreen(
            image: image,
            selectedFeature: _selectedFeature,
            country: _country,
            latitude: _currentPosition?.latitude,
            longitude: _currentPosition?.longitude,
          ),
        ),
      );
    } else {
      print('No image selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building HomePage');
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRect(
                child: Transform.translate(
                  offset: Offset(0, 0),
                  child: Container(
                    height: MediaQuery.sizeOf(context).height,
                    width: MediaQuery.sizeOf(context).width + 190,
                    child: Image.asset(
                      "assets/image/IMG_3571.JPG",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 56,
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    color: Colors.white10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'SnapChef',
                          style: TextStyle(
                            fontSize: 30,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Your AI Kitchen Assistant',
                          style: TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Expanded(
                  //   child: GridView.count(
                  //     crossAxisCount: 2,
                  //     padding: EdgeInsets.all(16),
                  //     mainAxisSpacing: 16,
                  //     crossAxisSpacing: 16,
                  //     children: [
                  //       FeatureButton(
                  //         title: 'Recipe Diagnostics',
                  //         icon: Icons.restaurant_menu,
                  //         color: Colors.orange,
                  //         onPressed: () => _selectFeature('Recipe Diagnostics'),
                  //       ),
                  //       FeatureButton(
                  //         title: 'Protein Calculator',
                  //         icon: Icons.fitness_center,
                  //         color: Colors.green,
                  //         onPressed: () => _selectFeature('Protein Calculator'),
                  //       ),
                  //       FeatureButton(
                  //         title: 'Magic Dish',
                  //         icon: Icons.auto_awesome,
                  //         color: Colors.purple,
                  //         onPressed: () => _selectFeature('Magic Dish'),
                  //       ),
                  //       FeatureButton(
                  //         title: 'Price Calculator',
                  //         icon: Icons.attach_money,
                  //         color: Colors.red,
                  //         onPressed: () => _selectFeature('Price Calculator'),
                  //       ),
                  //       FeatureButton(
                  //         title: 'Food Finder',
                  //         icon: Icons.location_on,
                  //         color: Colors.blue,
                  //         onPressed: () => _selectFeature('Food Finder'),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => _selectFeature('Recipe Diagnostics'),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white70,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.restaurant_menu),
                                Text('Recipe Diagnostics'),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                        GestureDetector(
                          onTap: () => _selectFeature('Protein Calculator'),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white70,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.fitness_center),
                                Text('Protien calculator'),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                        GestureDetector(
                          onTap: () => _selectFeature('Magic Dish'),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white70,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome),
                                Text('Magic Dish'),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                        GestureDetector(
                          onTap: () => _selectFeature('Price Calculator'),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white70,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.attach_money),
                                Text('Price Calculator'),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                        GestureDetector(
                          onTap: () => _selectFeature('Food Finder'),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white70,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on),
                                Text('Food Finder'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ]),
          ],
        ),
      ),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  final File image;
  final String selectedFeature;
  final String country;
  final double? latitude;
  final double? longitude;

  LoadingScreen({
    required this.image,
    required this.selectedFeature,
    required this.country,
    this.latitude,
    this.longitude,
  });

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _isTimedOut = false;

  @override
  void initState() {
    super.initState();
    print('LoadingScreen initState called');
    _processImage();
  }

  Future<void> _processImage() async {
    print('Processing image');
    var uri = Uri.parse('https://snapcheftest-7b087a96c30b.herokuapp.com/');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', widget.image.path))
      ..fields['menu_type'] = widget.selectedFeature
      ..fields['country'] = widget.country;

    if (widget.latitude != null && widget.longitude != null) {
      request.fields['latitude'] = widget.latitude.toString();
      request.fields['longitude'] = widget.longitude.toString();
    }

    try {
      print('Sending request');
      var response = await request
          .send()
          .timeout(Duration(seconds: 120)); // 2 minute timeout
      if (response.statusCode == 200) {
        print('Request successful');
        String responseBody = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseBody);
        _navigateToResult(jsonResponse['recipe']);
      } else {
        print('Request failed with status: ${response.statusCode}');
        _handleError(
            'Failed to process image. Status code: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      print('Request timed out');
      setState(() {
        _isTimedOut = true;
      });
      _handleError('Request timed out. Please try again.');
    } catch (e) {
      print('Error processing image: $e');
      _handleError('Error: $e');
    }
  }

  void _handleError(String errorMessage) {
    print('Handling error: $errorMessage');
    if (!mounted) return;
    _navigateToResult(errorMessage);
  }

  void _navigateToResult(String result) {
    print('Navigating to result screen');
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          result: result,
          selectedFeature: widget.selectedFeature,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Building LoadingScreen');
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isTimedOut) CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(_isTimedOut
                ? 'Request timed out. Please try again.'
                : 'Processing your image...'),
            if (_isTimedOut)
              ElevatedButton(
                onPressed: () {
                  print('Retrying image processing');
                  setState(() {
                    _isTimedOut = false;
                  });
                  _processImage();
                },
                child: Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final String result;
  final String selectedFeature;

  ResultScreen({required this.result, required this.selectedFeature});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedFeature),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: RichText(
          text: TextSpan(
            children: _buildTextSpans(result),
            style: TextStyle(color: Colors.black), // Default text style
          ),
        ),
      ),
    );
  }

  List<TextSpan> _buildTextSpans(String text) {
    // Example: Parsing simple markdown-like text
    // You can expand this parsing logic to handle different cases.
    List<TextSpan> spans = [];
    final parts = text.split(RegExp(r'(\\|\*)')); // Split by bold markers

    for (int i = 0; i < parts.length; i++) {
      if (parts[i] == '' || parts[i] == '*') {
        spans.add(
          TextSpan(
            text: parts[i + 1],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
        i++; // Skip the next part as it's already used
      } else {
        spans.add(TextSpan(text: parts[i]));
      }
    }

    return spans;
  }
}



class FeatureButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const FeatureButton({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Building FeatureButton: $title');
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}