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

class Tappable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const Tappable({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  State<Tappable> createState() => _TappableState();
}

class _TappableState extends State<Tappable> {
  double _scale = 1;

  void _onPointerDown(PointerDownEvent event) => setState(() => _scale = 0.98);
  void _onTapCancel() => setState(() => _scale = 1);
  void _onPointerUp(PointerUpEvent event) => setState(() => _scale = 1);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: (event) => _onTapCancel(),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          borderRadius: widget.borderRadius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: widget.borderRadius,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _PressAnimationButtonState extends State<PressAnimationButton> {
  double _scale = 1.0;

  void _onTapDown(PointerDownEvent event) => setState(() => _scale = 0.96);
  void _onTapCancel() => setState(() => _scale = 1.0);
  void _onTapUp(PointerUpEvent event) => setState(() => _scale = 1.0);

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
