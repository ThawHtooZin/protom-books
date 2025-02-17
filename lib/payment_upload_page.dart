import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart';

class PaymentUploadPage extends StatefulWidget {
  final String planType;

  const PaymentUploadPage({super.key, required this.planType});

  @override
  _PaymentUploadPageState createState() => _PaymentUploadPageState();
}

class _PaymentUploadPageState extends State<PaymentUploadPage> {
  File? _image;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    // Request permissions
    await _requestPermissions();

    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        debugPrint('Image selected: ${_image!.path}');
      } else {
        debugPrint('No image selected.');
      }
    });
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.photos.request();
    if (status.isDenied) {
      // Handle the case when the user denies the permission
      debugPrint('Permission denied.');
    } else {
      debugPrint('Permission granted.');
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) {
      debugPrint('No image to upload.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://protombook.protechmm.com/api/payments'),
      );
      request.fields['user_id'] = '1'; // Replace with actual user ID
      request.fields['plan_type'] =
          widget.planType; // Include planType in the request
      request.files.add(await http.MultipartFile.fromPath(
        'payment_image',
        _image!.path,
        filename: basename(_image!.path),
      ));

      final response = await request.send();

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 201) {
        debugPrint('Upload successful.');
        _showMessage('Payment request created successfully.', Colors.green);
      } else {
        final responseBody = await response.stream.bytesToString();
        debugPrint('Upload failed with status code: ${response.statusCode}');
        debugPrint('Response body: $responseBody');

        final responseData = json.decode(responseBody);
        if (responseData['errors'] != null) {
          final errors = responseData['errors'];
          String errorMessage = 'Failed to upload payment proof:\n';
          errors.forEach((key, value) {
            errorMessage += '$key: ${value.join(', ')}\n';
          });
          _showMessage(errorMessage, Colors.red);
        } else {
          _showMessage('Failed to upload payment proof.', Colors.red);
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Upload failed with error: $e');
      _showMessage('Failed to upload payment proof.', Colors.red);
    }
  }

  void _showMessage(String message, Color color) {
    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Payment Proof'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Payment Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please transfer the payment to the following account and upload the screenshot proof.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'PayPal: yourpaypal@example.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Bank Account: 1234567890 (Your Bank Name)',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Upload Payment Proof',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: _image == null
                  ? const Text('No image selected.')
                  : Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 20.0,
                  ),
                ),
                child: const Text(
                  'Select Image',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _uploadImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 20.0,
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text(
                        'Upload Image',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
