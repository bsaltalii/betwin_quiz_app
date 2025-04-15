import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../components/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizCompletionBottomSheet extends StatefulWidget {
  final int correctCount;
  final int wrongCount;
  final int coinsEarned;
  final bool gameMode;
  final int? prediction;

  const QuizCompletionBottomSheet({
    super.key,
    required this.correctCount,
    required this.wrongCount,
    required this.coinsEarned,
    required this.gameMode,
    this.prediction,
  });

  @override
  State<QuizCompletionBottomSheet> createState() =>
      _QuizCompletionBottomSheetState();
}

class _QuizCompletionBottomSheetState extends State<QuizCompletionBottomSheet> {
  late int earnedCoins;
  late int unansweredQuestions;

  @override
  void initState() {
    super.initState();
    earnedCoins = _calculateEarnedCoins();
    unansweredQuestions = widget.gameMode
        ? 5 - (widget.correctCount + widget.wrongCount)
        : 10 - (widget.correctCount + widget.wrongCount);
  }

  String? _getCurrentUserUid() => FirebaseAuth.instance.currentUser?.uid;

  Future<void> _updateUserCoins(String userId, int earnedCoins) async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final userDoc = await userRef.get();

      if (userDoc.exists && mounted) {
        final currentCoins = userDoc['coins'] ?? 1000;
        await userRef.update({'coins': currentCoins + earnedCoins});
      }
    } catch (e) {
      throw Exception("An error occurred while updating coins: $e");
    }
  }

  int _calculateEarnedCoins() {
    if (!widget.gameMode) {
      if (widget.prediction != widget.correctCount) {
        return widget.correctCount * 5;
      }

      final multipliers = {5: 3, 6: 4, 7: 5, 8: 6, 9: 7, 10: 8};

      if (multipliers.containsKey(widget.correctCount) &&
          widget.correctCount == widget.prediction) {
        return widget.correctCount * 5 * multipliers[widget.correctCount]!;
      }
    }

    return widget.correctCount == 5
        ? widget.correctCount * 5 * 3
        : widget.correctCount * 5;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final userUid = _getCurrentUserUid();

    if (userUid != null) {
      _updateUserCoins(userUid, earnedCoins);
    } else {
      throw Exception("User not found!");
    }

    final isCongrats = (widget.gameMode && widget.correctCount == 5) ||
        (!widget.gameMode && widget.correctCount == widget.prediction);

    return WillPopScope(
      onWillPop: () async => false,
      child: SizedBox(
        width: double.infinity,
        height: size.height * 0.6,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                  isCongrats
                      ? "assets/icons/happiness.png"
                      : "assets/icons/indifferent.png",
                  width: size.width * 0.4),
              Text(
                isCongrats ? 'Congratulations!' : 'Good try!',
                style: GoogleFonts.quicksand(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isCongrats ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(
                child: Column(
                  children: [
                    _buildInfoText('Correct Answers: ${widget.correctCount}'),
                    _buildInfoText('Wrong Answers: ${widget.wrongCount}'),
                    _buildInfoText('Coins Earned: $earnedCoins'),
                    if(widget.prediction != null)...[
                      _buildInfoText('Prediction: ${widget.prediction}'),
                    ]
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/home', (Route<dynamic> route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.secondaryColor,
                ),
                child: const Text('Main Menu'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Text(
      text,
      style: GoogleFonts.quicksand(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
