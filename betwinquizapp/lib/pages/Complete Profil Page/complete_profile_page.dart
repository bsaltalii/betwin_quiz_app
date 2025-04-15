import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:betwinquizapp/components/background.dart';
import 'package:betwinquizapp/pages/Login%20Page/Components/AnimatedTextFieldWidget.dart';
import 'package:betwinquizapp/pages/Profile%20Page/Components/CustomButtonWidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:betwinquizapp/components/Theme.dart';
import 'package:betwinquizapp/pages/Complete%20Profil%20Page/Components/AvatarSelectionWidget.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  String selectedAvatar = '';
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  List<String> avatars = [
    'assets/avatars/avatar1.png',
    'assets/avatars/avatar2.png',
    'assets/avatars/avatar3.png',
    'assets/avatars/avatar4.png',
    'assets/avatars/avatar5.png',
    'assets/avatars/avatar6.png',
    'assets/avatars/avatar7.png',
    'assets/avatars/avatar8.png'
  ];

  void _onAvatarSelected(String selectedAvatar) {
    setState(() {
      this.selectedAvatar = selectedAvatar;
    });
  }

  Future<void> _updateUserProfile() async {
    String username = _usernameController.text.trim();
    String fullName = _nameController.text.trim();

    if (username.isEmpty || selectedAvatar.isEmpty || fullName.isEmpty) {
      _showMessage("You must enter full name , username and select an avatar",
          isSuccess: false);
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        await firestore.collection('users').doc(user.uid).update({
          'name': fullName,
          'username': username,
          'avatar': selectedAvatar,
          'isCompleted': true,
        });
        Navigator.pushNamed(context, '/home');
      }
    } catch (e) {
      _showMessage("Something went wrong: $e", isSuccess: false);
    }
  }

  void _showMessage(String message, {required bool isSuccess}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            isSuccess ? 'Success' : 'Error',
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Okay',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _usernameController
        .dispose(); // Dispose of the controller to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Background(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Text(
                "Almost done..",
                style: GoogleFonts.quicksand(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryColor,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
              AvatarSelectionWidget(
                  avatarImages: avatars, onAvatarSelected: _onAvatarSelected),
              AnimatedTextField(
                  label: "Full Name",
                  suffix: null,
                  obscureText: false,
                  controller: _nameController),
              const SizedBox(height: 15),
              AnimatedTextField(
                  label: "Username",
                  suffix: null,
                  obscureText: false,
                  controller: _usernameController),
              const SizedBox(height: 15),
              CustomButton(
                  size: size, text: "Complete", onTap: _updateUserProfile),
              _buildBackButton(context)
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
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/login',(Route<dynamic> route) => false);
            },
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
