import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class RankingsPage extends StatefulWidget {
  const RankingsPage({super.key});

  @override
  State<RankingsPage> createState() => _RankingsPageState();
}

class _RankingsPageState extends State<RankingsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: size.height,
          child: Column(
            children: [
              _buildBackButton(size, context),
              Image.asset(
                'assets/icons/top-three.png',
                height: size.height * 0.1,
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('Rankings Table',style: GoogleFonts.quicksand(fontSize: 32,fontWeight: FontWeight.w500))),
              SizedBox(height: size.height * 0.02),
              Expanded(
                child: _buildUsersCard(size),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(Size size, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: size.width * 0.03,
        bottom: size.height * 0.02,
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/home', (Route<dynamic> route) => false);
          },
          color: Colors.black,
          iconSize: size.width * 0.07,
        ),
      ),
    );
  }

  Widget _buildUsersCard(Size size) {
    return SingleChildScrollView(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .orderBy('coins', descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var userData =
              snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child:  Row(
                    children: [
                      SizedBox(width: 8),
                      Text(
                          '${index+1}',
                          style: GoogleFonts.quicksand(fontSize: 24)
                      ),
                      SizedBox(width: 16),
                      CircleAvatar(
                        child: Image.asset(userData['avatar']),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData['username'] ?? 'Anonymous',
                                style: GoogleFonts.quicksand(fontWeight: FontWeight.w600,fontSize: 16),
                              ),
                              Text(
                                userData['name'] ?? 'Anonymous',
                                style: GoogleFonts.quicksand(fontWeight: FontWeight.w600,fontSize: 12,color: Colors.grey[600]),
                              ),
                            ]
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/icons/coin.png',width: size.width*0.05,),
                          const SizedBox(width: 4),
                          Text(
                            '${userData['coins']}',
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
