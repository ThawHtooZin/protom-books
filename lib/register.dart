import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:protom_books/login.dart';
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  Map<String, dynamic>? _errors;
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errors = null;
    });

    final response = await http.post(
      Uri.parse('https://protombook.protechmm.com/api/register'),
      headers: {'Content-Type': 'application/json'}, // Send JSON
      body: json.encode({
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'password_confirmation': _confirmPasswordController.text,
      }),
    );
    final data = json.decode(response.body);

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 201) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else if (response.statusCode == 422) {
      // Laravel validation errors
      setState(() {
        _errors = data['errors'];
      });
    } else {
      setState(() {
        _errors = {
          'general': ['Something went wrong. Please try again.']
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            if (_errors != null)
              ..._errors!.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "${entry.key}: ${entry.value.join(', ')}",
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  )),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Blueberry theme
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0), // Increase button height
                  ),
                  child: const Text('Register'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
