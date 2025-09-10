import 'package:flutter/material.dart';

class BouncyOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;
  final double scale;

  const BouncyOnTap({
    super.key,
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 100),
    this.scale = 0.9,
  });

  @override
  State<BouncyOnTap> createState() => _BouncyOnTapState();
}

class _BouncyOnTapState extends State<BouncyOnTap>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(_) {
    setState(() => _scale = widget.scale);
  }

  void _onTapUp(_) {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
