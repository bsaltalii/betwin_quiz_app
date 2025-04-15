import 'package:betwinquizapp/components/constants.dart';
import 'package:betwinquizapp/pages/Login%20Page/Components/AnimatedTextFieldWidget.dart';
import 'package:betwinquizapp/pages/Profile%20Page/Components/CustomButtonWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:betwinquizapp/services/auth_service.dart';
import 'package:betwinquizapp/components/background.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _auth = AuthService();
  final _firestore = FirebaseFirestore.instance;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showMessage("Email and password cannot be empty.", isSuccess: false);
      return;
    }

    try {
      final userCredential = await _auth.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await _checkUserProfileCompletion(userCredential.user?.uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        _showMessage("The email address is not valid.", isSuccess: false);
      } else if (e.code == 'user-not-found') {
        _showMessage("No account found with this email.", isSuccess: false);
      } else if (e.code == 'wrong-password') {
        _showMessage("Incorrect password. Please try again.", isSuccess: false);
      } else if (e.code == 'user-disabled') {
        _showMessage("This account has been disabled. Contact support.",
            isSuccess: false);
      } else {
        _showMessage("Login failed. Please check your email and password.",
            isSuccess: false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final user = await _auth.signInWithGoogle();
      if (user != null) {
        await _checkUserProfileCompletion(user.uid);
      } else {
        _showMessage("Login failed. Please try again.", isSuccess: false);
      }
    } catch (e) {
      _showMessage(e.toString(), isSuccess: false);
    }
  }

  Future<void> _checkUserProfileCompletion(String? uid) async {
    if (uid == null || !mounted) return;

    final userDoc = await _firestore.collection('users').doc(uid).get();

    if (!mounted) return;

    if (userDoc.exists && userDoc.data()?['isCompleted'] == true) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/complete_profile_page');
    }
  }

  void _showMessage(String message, {required bool isSuccess}) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        final textStyle = GoogleFonts.quicksand(fontSize: 16);
        return AlertDialog(
          title: Text(
            isSuccess ? 'Success' : 'Error',
            style: textStyle.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: Text(message, style: textStyle),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Okay',
                style: textStyle.copyWith(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Background(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeader(size),
                _buildTextFields(size, context),
                _buildButtonSection(size),
              ],
            ),
          ),
        ),
      ),
    );
  }


  SizedBox _buildTextFields(Size size,BuildContext context) {
    return SizedBox(
      height: size.height*0.25,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AnimatedTextField(
            label: "Email",
            suffix: null,
            obscureText: false,
            controller: _emailController,
            focusNode: _emailFocusNode,
          ),
          AnimatedTextField(
            label: "Password",
            suffix: null,
            obscureText: true,
            controller: _passwordController,
            focusNode: _passwordFocusNode,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/register'),
              child: Text(
                "Don't have an account?",
                style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SizedBox _buildButtonSection(Size size) {
    return SizedBox(
      height: size.height * 0.25,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CustomButton(
            size: size,
            text: 'Login',
            onTap: _signIn,
          ),
          _buildDivider(),
          _authOptionsButton(size),
        ],
      ),
    );
  }

  Row _buildDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: Color(0xFF777777),
            thickness: 1,
          ),
        ),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text('or sign with',
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                ))),
        const Expanded(
          child: Divider(
            color: Color(0xFF777777),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(Size size) {
    return SizedBox(
      height: size.height*0.25,
      child: Image.asset(
        'assets/icons/logo.png',
        fit: BoxFit.fitHeight,
      ),
    );
  }

  Widget _authOptionsButton(Size size) {
    return Container(
      width: size.width * 0.7,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF777777)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _signInWithGoogle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/google.png',
                  width: 30,
                  height: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  'Google',
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
