import 'package:flutter/material.dart';

class PressAnimationButton extends StatefulWidget {
  final Widget label;
  final VoidCallback onPressed;
  final ButtonStyle style;

  const PressAnimationButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.style,
  });

  @override
  State<PressAnimationButton> createState() => _PressAnimationButtonState();
}

class _PressAnimationButtonState extends State<PressAnimationButton> {
  double _scale = 1.0;

  void _onTapDown(_) => setState(() => _scale = 0.96);
  void _onTapCancel() => setState(() => _scale = 1.0);
  void _onTapUp(_) => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onTapDown,
      onPointerUp: _onTapUp,
      onPointerCancel: (_) => _onTapCancel(),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: widget.style,
          child: widget.label,
        ),
      ),
    );
  }
}
