import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();
      if (mounted && userDoc.exists) {
        setState(() => userData = userDoc.data());
      }
    } catch (e) {
      debugPrint('Error getting user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: [
          _buildBackButton(size),
          if (userData != null) ...[
            SizedBox(height: size.height * 0.02),
            _buildAvatar(size),
            SizedBox(height: size.height * 0.02),
            _buildUserHeader(),
            SizedBox(height: size.height * 0.02),
            _buildUserInfoCards(size, arguments!['ranking'].toString()),
            SizedBox(height: size.height * 0.02),
            _buildUserDetailsCard(size),
            SizedBox(height: size.height * 0.02),
            _buildLogOutButton()
          ] else
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  ElevatedButton _buildLogOutButton() {
    return ElevatedButton(
      onPressed: () {
        FirebaseAuth.instance.signOut();
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
              (Route<dynamic> route) => false,
        );
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
      child: const Text('Log out'),
    );
  }

  CircleAvatar _buildAvatar(Size size) {
    return CircleAvatar(
      radius: size.width * 0.15,
      backgroundImage: AssetImage(userData?['avatar'] ?? 'assets/default.png'),
    );
  }

  Widget _buildUserHeader() {
    return Column(
      children: [
        Text(
          userData?['username'] ?? 'Anonymous',
          style: GoogleFonts.quicksand(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          userData?['name'] ?? 'Anonymous',
          style: GoogleFonts.quicksand(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildUserDetailsCard(Size size) {
    return SizedBox(
      width: size.width * 0.85,
      child: Card(
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDetailRow(
                'user.png', 'Username', userData?['username'] ?? '-', size),
            _buildDetailRow(
                'gmail.png', 'E-mail', userData?['email'] ?? '-', size),
            _buildDetailRow(
                'id-card.png', 'Name', userData?['name'] ?? '-', size),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      String icon, String label, String value, Size size,
      {double iconWidth = 0.1}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.1, vertical: 8),
      child: Row(
        children: [
          Image.asset('assets/icons/$icon', width: size.width * iconWidth),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Row _buildUserInfoCards(Size size, String rank) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildInfoCard('coin.png', userData?['coins'].toString() ?? '0',
            'Coins', size),
        _buildInfoCard('top-three.png', rank, 'Ranking', size),
      ],
    );
  }

  Widget _buildInfoCard(
      String icon, String value, String label, Size size) {
    return SizedBox(
      height: size.height * 0.2,
      width: size.width * 0.4,
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/icons/$icon', width: size.width * 0.15),
              Text(
                value,
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w500,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(Size size) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(
          top: size.height * 0.05,
          left: size.width * 0.03,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (route) => false),
          color: Colors.black,
          iconSize: size.width * 0.07,
        ),
      ),
    );
  }
}
