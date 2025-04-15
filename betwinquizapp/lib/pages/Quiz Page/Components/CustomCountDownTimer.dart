import 'package:flutter/material.dart';
import 'dart:async';

class CustomCountDownTimer extends StatefulWidget {
  final double width;
  final double height;
  final int duration;
  final double strokeWidth;
  final TextStyle textStyle;
  final Color fillColor;
  final Color ringColor;
  final bool isReverseAnimation;
  final VoidCallback onComplete;
  final CustomCountDownTimerController? controller;

  const CustomCountDownTimer({
    Key? key,
    required this.width,
    required this.height,
    required this.duration,
    required this.strokeWidth,
    required this.textStyle,
    required this.fillColor,
    required this.ringColor,
    required this.isReverseAnimation,
    required this.onComplete,
    this.controller,
  }) : super(key: key);

  @override
  CustomCountDownTimerState createState() => CustomCountDownTimerState();
}

class CustomCountDownTimerController {
  late VoidCallback restart;
  late VoidCallback pause;
  late VoidCallback resume;
}

class CustomCountDownTimerState extends State<CustomCountDownTimer> {
  late double _remainingTime;
  Timer? _timer;
  late double _progress;
  static const _updateInterval = Duration(milliseconds: 16);
  static const _updateValue = 0.016;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
    _bindController();
    _startTimer();
  }

  void _initializeTimer() {
    _remainingTime = widget.duration.toDouble();
    _progress = 1.0;
  }

  void _bindController() {
    if (widget.controller != null) {
      widget.controller!.restart = _restartTimer;
      widget.controller!.pause = _pauseTimer;
      widget.controller!.resume = _resumeTimer;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_updateInterval, _updateTimer);
  }

  void _updateTimer(Timer timer) {
    setState(() {
      _remainingTime -= _updateValue;
      _progress = _remainingTime / widget.duration;

      if (_remainingTime <= 0) {
        _timer?.cancel();
        widget.onComplete();
      }
    });
  }

  void _restartTimer() {
    _timer?.cancel();
    setState(() {
      _initializeTimer();
    });
    _startTimer();
  }

  void _pauseTimer() {
    _timer?.cancel();
  }

  void _resumeTimer() {
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: widget.width,
            height: widget.height,
            child: CircularProgressIndicator(
              value: widget.isReverseAnimation ? 1.0 - _progress : _progress,
              strokeWidth: widget.strokeWidth,
              backgroundColor: widget.fillColor,
              valueColor: AlwaysStoppedAnimation(widget.ringColor),
            ),
          ),
          Text(
            _remainingTime.ceil().toString(),
            style: widget.textStyle,
          ),
        ],
      ),
    );
  }
}

