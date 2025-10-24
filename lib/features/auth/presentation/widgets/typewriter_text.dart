import 'package:flutter/material.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final Duration duration;
  final TextStyle? style;
  final TextAlign textAlign;
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    this.duration = const Duration(milliseconds: 50),
    this.style,
    this.textAlign = TextAlign.left,
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  String _displayText = '';
  String _previousText = '';
  int _startIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    // Find common prefix with previous text
    _startIndex = _findCommonPrefixLength(_previousText, widget.text);

    final charactersToType = widget.text.length - _startIndex;

    _controller = AnimationController(
      duration: Duration(
        milliseconds: charactersToType * widget.duration.inMilliseconds,
      ),
      vsync: this,
    );

    _animation = IntTween(
      begin: _startIndex,
      end: widget.text.length,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _animation.addListener(() {
      setState(() {
        _displayText = widget.text.substring(0, _animation.value);
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    // Start with the common prefix already displayed
    _displayText = widget.text.substring(0, _startIndex);
    _controller.forward();
  }

  int _findCommonPrefixLength(String oldText, String newText) {
    int minLength = oldText.length < newText.length
        ? oldText.length
        : newText.length;

    for (int i = 0; i < minLength; i++) {
      if (oldText[i] != newText[i]) {
        return i;
      }
    }

    return minLength;
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.text != widget.text) {
      _previousText = oldWidget.text;
      _controller.dispose();
      _initializeAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_displayText, style: widget.style, textAlign: widget.textAlign);
  }
}
