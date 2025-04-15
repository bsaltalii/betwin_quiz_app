import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OptimizedRowWidget extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final String ranking;
  final String gold;

  const OptimizedRowWidget({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.ranking,
    required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    final verticalPadding = screenHeight * 0.02;
    final horizontalPadding = screenWidth * 0.04;
    final dividerHeight = screenHeight * 0.05;
    final dividerMargin = screenWidth * 0.02;
    final iconSize = Size(screenWidth * 0.10, screenHeight * 0.05);
    final labelTextStyle = GoogleFonts.quicksand(
      fontSize: screenWidth * 0.035,
      fontWeight: FontWeight.bold,
    );
    final valueTextStyle = TextStyle(
      fontSize: screenWidth * 0.03,
      color: Colors.grey[700],
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.01,
          horizontal: horizontalPadding,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildInfoItem(
                iconPath: 'assets/icons/top-three.png',
                label: "Rankings",
                value: ranking,
                iconSize: iconSize,
                labelStyle: labelTextStyle,
                valueStyle: valueTextStyle,
              ),
            ),
            Container(
              width: 1.5,
              height: dividerHeight,
              color: Colors.black12,
              margin: EdgeInsets.symmetric(horizontal: dividerMargin),
            ),
            Expanded(
              flex: 1,
              child: _buildInfoItem(
                iconPath: 'assets/icons/coin.png',
                label: "Gold",
                value: gold,
                iconSize: iconSize,
                labelStyle: labelTextStyle,
                valueStyle: valueTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String iconPath,
    required String label,
    required String value,
    required Size iconSize,
    required TextStyle labelStyle,
    required TextStyle valueStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: iconSize.width,
            maxHeight: iconSize.height,
          ),
          child: Image.asset(
            iconPath,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: labelStyle,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: valueStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

