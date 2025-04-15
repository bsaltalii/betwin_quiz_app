import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:betwinquizapp/pages/Home%20Page/Components/SubHeaderWidget.dart';
import 'package:betwinquizapp/pages/Game%20Type%20Selection%20Page/Components/CategoryGridWidget.dart';
import 'package:betwinquizapp/pages/Home%20Page/Components/CustomDrawerWidget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = '';
  String avatarUrl = '';
  int coins = 0;
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  int? currentUserRank;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final userDocFuture = _firestore.collection('users').doc(user.uid).get();
        final rankingFuture = _getCurrentUserRanking(user.uid);

        final results = await Future.wait([userDocFuture, rankingFuture]);
        final userDoc = results[0] as DocumentSnapshot;

        if (userDoc.exists && mounted) {
          setState(() {
            userName = userDoc.get('name') as String;
            avatarUrl = userDoc.get('avatar') as String;
            coins = userDoc.get('coins') as int;
            isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => isLoading = false);
          _showMessage(e.toString(), isSuccess: false);
        }
      }
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
              onPressed: () => Navigator.of(context).pop(),
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

  Future<void> _getCurrentUserRanking(String userId) async {
    try {
      var usersSnapshot = await _firestore
          .collection('users')
          .orderBy('coins', descending: true)
          .get();

      int rank = usersSnapshot.docs.indexWhere((doc) => doc.id == userId) + 1;
      setState(() {
        currentUserRank = rank;
      });
    } catch (e) {
      throw Exception('Error getting user ranking: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 80,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: screenWidth * 0.07,
          right: screenWidth * 0.07,
        ),
        child: Column(
          children: [
            _buildHeader(screenWidth, screenHeight),
            OptimizedRowWidget(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              ranking: currentUserRank.toString(),
              gold: coins.toString(),
            ),
            _buildTitleWidget(screenWidth),
            const SizedBox(height: 5),
            const Flexible(child: CategoryGrid()),
          ],
        ),
      ),
      drawer: CustomDrawerWidget(
        rank: currentUserRank,
      ),
    );
  }

  Widget _buildTitleWidget(double screenWidth) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            "Let's Play",
            style: GoogleFonts.quicksand(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(double screenWidth, double screenHeight) {
    final titleStyle = GoogleFonts.quicksand(
      fontSize: screenWidth * 0.045,
      fontWeight: FontWeight.w600,
    );
    final subtitleStyle = GoogleFonts.quicksand(
      fontSize: screenWidth * 0.03,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hi, $userName", style: titleStyle),
                Text("Let's make this day productive", style: subtitleStyle),
              ],
            ),
            if (avatarUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  avatarUrl,
                  width: screenWidth * 0.11,
                  height: screenHeight * 0.05,
                  fit: BoxFit.cover,
                ),
              )
            else
              const CircularProgressIndicator(),
          ],
        ),
      ],
    );
  }
}
