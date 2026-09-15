import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart' as p;

/// A versatile Neumorphic container powered by flutter_neumorphic_plus.
/// Supports extruded elevations, concave insets, custom depth, and neon glow highlights.
class NeumorphicBox extends StatelessWidget {
  final Widget? child;
  final double borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool isPressed;
  final bool isHighlighted;
  final Color? highlightColor;
  final VoidCallback? onTap;
  final double depth;
  final Color baseColor;

  const NeumorphicBox({
    super.key,
    this.child,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
    this.isPressed = false,
    this.isHighlighted = false,
    this.highlightColor,
    this.onTap,
    this.depth = 4.0,
    this.baseColor = const Color(0xFF161920),
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHighlightColor = highlightColor ?? const Color(0xFF39D353);
    final calculatedDepth = isPressed ? -depth.abs() : depth.abs();

    final style = p.NeumorphicStyle(
      shape: isPressed ? p.NeumorphicShape.concave : p.NeumorphicShape.flat,
      boxShape: p.NeumorphicBoxShape.roundRect(BorderRadius.circular(borderRadius)),
      depth: calculatedDepth,
      intensity: 0.65,
      lightSource: p.LightSource.topLeft,
      color: baseColor,
      border: isHighlighted
          ? p.NeumorphicBorder(
              color: effectiveHighlightColor.withValues(alpha: 0.6),
              width: 1.5,
            )
          : p.NeumorphicBorder(
              color: Colors.white.withValues(alpha: 0.04),
              width: 0.8,
            ),
      shadowLightColor: Colors.white.withValues(alpha: isPressed ? 0.03 : 0.08),
      shadowDarkColor: Colors.black.withValues(alpha: isPressed ? 0.85 : 0.65),
    );

    Widget content;
    if (onTap != null) {
      content = p.NeumorphicButton(
        onPressed: onTap,
        margin: margin,
        padding: padding ?? EdgeInsets.zero,
        style: style,
        child: child,
      );
    } else {
      content = p.Neumorphic(
        margin: margin ?? EdgeInsets.zero,
        padding: padding ?? EdgeInsets.zero,
        style: style,
        child: child,
      );
    }

    if (isHighlighted) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: effectiveHighlightColor.withValues(alpha: 0.18),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: content,
      );
    }

    return content;
  }
}
