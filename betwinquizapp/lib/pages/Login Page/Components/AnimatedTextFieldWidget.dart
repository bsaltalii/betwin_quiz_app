import 'package:flutter/material.dart';
import '../../../components/constants.dart';

class AnimatedTextField extends StatefulWidget {
  final String label;
  final Widget? suffix;
  final bool obscureText;
  final TextEditingController controller;
  final FocusNode? focusNode;

  const AnimatedTextField({
    Key? key,
    required this.label,
    required this.suffix,
    required this.obscureText,
    required this.controller,
    this.focusNode,
  }) : super(key: key);

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField> {
  late final FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() => _hasFocus = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _hasFocus ? Constants.labelColor! : Colors.grey;
    final labelStyle = TextStyle(
      color: _hasFocus ? Constants.labelColor : Colors.grey[700],
      fontSize: _hasFocus ? 16 : 14,
      fontWeight: _hasFocus ? FontWeight.bold : FontWeight.normal,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.obscureText,
        focusNode: _focusNode,
        decoration: InputDecoration(
          label: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: labelStyle,
            child: Text(widget.label),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: widget.suffix,
        ),
      ),
    );
  }
}
