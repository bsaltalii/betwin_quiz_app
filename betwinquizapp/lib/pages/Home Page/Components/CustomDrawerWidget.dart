import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDrawerWidget extends StatelessWidget {
  final int? rank;

  const CustomDrawerWidget({
    super.key,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(size.width * 0.05),
              child: Column(
                children: [
                  Image.asset('assets/icons/logo.png',width: size.width*0.35),
                  const SizedBox(height: 8),
                  Container(
                    width: size.width,
                    height: 1,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                    ),
                  )
                ],
              )
              ),
            ListTile(
              leading: Image.asset(
                'assets/icons/user.png',
                width: size.width * 0.09,
              ),
              title: Text(
                'Profile',
                style: GoogleFonts.quicksand(fontSize: 18),
              ),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/profile',
                      (Route<dynamic> route) => false,
                  arguments: {'ranking': rank},
                );
              },
            ),
            ListTile(
              leading: Image.asset(
                'assets/icons/top-three.png',
                width: size.width * 0.09,
              ),
              title: Text(
                'Rankings',
                style: GoogleFonts.quicksand(fontSize: 18),
              ),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/rankings',
                      (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
