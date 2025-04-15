import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameTypeSelectionCardWidget extends StatefulWidget {
  final String category;

  const GameTypeSelectionCardWidget({
    super.key,
    required this.category,
  });

  @override
  State<GameTypeSelectionCardWidget> createState() => _GameTypeSelectionCardWidgetState();
}

class _GameTypeSelectionCardWidgetState extends State<GameTypeSelectionCardWidget> {
  static const int _minPrediction = 5;
  static const int _maxPrediction = 10;
  int _selectedPrediction = _minPrediction;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.1,
          horizontal: screenWidth * 0.1,
        ),
        child: Column(
          children: [
            Expanded(
              child: _buildSelectionCard(
                context: context,
                iconPath: 'assets/gameSelection/bet.png',
                gameMode: true,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Expanded(
              child: _buildSelectionCard(
                context: context,
                iconPath: 'assets/gameSelection/play.png',
                gameMode: false,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required BuildContext context,
    required String iconPath,
    required bool gameMode,
    required double screenWidth,
    required double screenHeight,
  }) {
    final cardWidth = screenWidth * 0.7;
    final imageSize = Size(screenWidth * 0.2, screenHeight * 0.11);

    void navigateToQuiz({String? prediction}) {
      final args = {
        "category": widget.category,
        "limit": gameMode ? "10" : "5",
        if (prediction != null) "prediction": prediction,
      };
      Navigator.pushNamed(context, '/quiz_page', arguments: args);
    }

    return GestureDetector(
      onTap: gameMode ? null : () => navigateToQuiz(),
      child: SizedBox(
        width: cardWidth,
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(
                  iconPath,
                  width: imageSize.width,
                  height: imageSize.height,
                  fit: BoxFit.contain,
                ),
                Text(
                  gameMode ? "Betting Mode" : "Normal Mode",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    gameMode
                        ? "Predict how many questions you'll answer correctly out of 10. Accurate predictions earn extra rewards!"
                        : "Answer 5 questions. Get all correct answers to win!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      fontSize: screenWidth * 0.03,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (gameMode) ...[
                  _buildPredictionDropdown(screenWidth),
                  _buildStartButton(
                    screenWidth,
                        () => navigateToQuiz(prediction: _selectedPrediction.toString()),
                  ),
                ] else ...[
                  const SizedBox(height: 10),
                  _buildStartButton(screenWidth, () => navigateToQuiz()),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionDropdown(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButton<int>(
        value: _selectedPrediction,
        onChanged: (value) => setState(() => _selectedPrediction = value!),
        items: List.generate(
          _maxPrediction - _minPrediction + 1,
              (index) {
            final value = index + _minPrediction;
            return DropdownMenuItem<int>(
              value: value,
              child: Text(
                value.toString(),
                style: GoogleFonts.quicksand(fontSize: screenWidth * 0.05),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStartButton(double screenWidth, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        "Start",
        style: GoogleFonts.quicksand(fontSize: screenWidth * 0.035),
      ),
    );
  }
}
