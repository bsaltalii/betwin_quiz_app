import 'package:betwinquizapp/components/Theme.dart';
import 'package:betwinquizapp/pages/Login%20Page/Components/AnimatedTextFieldWidget.dart';
import 'package:betwinquizapp/pages/Profile%20Page/Components/CustomButtonWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/background.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String? errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> createUser() async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final userData = {
        'email': _emailController.text.trim(),
        'createdAt': Timestamp.now(),
        'uid': userCredential.user?.uid,
        'coins': 1000,
      };

      await _firestore
          .collection('users')
          .doc(userCredential.user?.uid)
          .set(userData);

      if (mounted) {
        _showSuccessMessage();
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'An unknown error occurred.');
    } catch (e) {
      _showError('Failed to register. Please try again.');
    }
  }

  void _showSuccessMessage() {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Success',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Your account has been successfully created!',
            style: GoogleFonts.quicksand(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                      (Route<dynamic> route) => false,
                );
              },
              child: Text(
                'Okay',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }


  void _showError(String message) {
    setState(() {
      errorMessage = message;
    });

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Error',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: Text(
            message,
            style: GoogleFonts.quicksand(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Okay',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  bool _validateInputs() {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showError('Please fill in all fields.');
      return false;
    }

    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      _showError("Passwords do not match!");
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const spacing = SizedBox(height: 15);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Background(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  "Just one step left,\n stay calm!",
                  style: GoogleFonts.quicksand(
                    fontSize: 36,
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              spacing,
              AnimatedTextField(
                label: "E-mail",
                suffix: null,
                obscureText: false,
                controller: _emailController,
              ),
              spacing,
              AnimatedTextField(
                label: "Password",
                suffix: null,
                obscureText: true,
                controller: _passwordController,
              ),
              spacing,
              AnimatedTextField(
                label: "Confirm Password",
                suffix: null,
                obscureText: true,
                controller: _confirmPasswordController,
              ),
              spacing,
              CustomButton(
                size: size,
                text: 'Register',
                onTap: () {
                  if (_validateInputs()) {
                    createUser();
                  }
                },
              ),
              _buildBackButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, left: 10),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.secondaryColor,
          shape: BoxShape.circle,
        ),
        child: Align(
          alignment: Alignment.center,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            padding: EdgeInsets.zero,
            iconSize: 28,
          ),
        ),
      ),
    );
  }
}