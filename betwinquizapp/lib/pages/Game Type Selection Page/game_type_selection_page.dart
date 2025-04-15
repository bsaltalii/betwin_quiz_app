import 'package:flutter/material.dart';
import 'package:betwinquizapp/pages/Game%20Type%20Selection%20Page/Components/GameTypeSelectionCardWidget.dart';

class GameTypeSelectionPage extends StatefulWidget {
  const GameTypeSelectionPage({super.key});

  @override
  State<GameTypeSelectionPage> createState() => _GameTypeSelectionPageState();
}

class _GameTypeSelectionPageState extends State<GameTypeSelectionPage> {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    final categoryEndpoint = ModalRoute.of(context)!.settings.arguments;

    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(
                top: screenSize.height * 0.05,
                left: screenSize.width * 0.03,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.black,
                iconSize: screenSize.width * 0.07,
              ),
            ),
          ),
          Center(
            child: GameTypeSelectionCardWidget(category: categoryEndpoint.toString()),
          ),
        ],
      ),
    );
  }
}
