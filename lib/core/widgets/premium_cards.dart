import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:paypulse/core/theme/app_colors.dart';
import 'package:paypulse/core/theme/app_theme.dart';

/// Premium glassmorphism card widget
/// Use for elevated UI elements that need a modern, frosted glass effect
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? borderColor;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = AppTheme.radiusXL,
    this.blur = 20,
    this.borderColor,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppTheme.spacingMD),
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null
                ? (isDark ? AppColors.glassDark : AppColors.glassLight)
                : null,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ??
                  (isDark
                      ? AppColors.glassBorderDark
                      : AppColors.glassBorderLight),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }
}

/// Premium card with gradient background
class GradientCard extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const GradientCard({
    super.key,
    required this.child,
    this.gradient = AppColors.premiumGradient,
    this.padding,
    this.margin,
    this.borderRadius = AppTheme.radiusXL,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingLG),
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? AppColors.cardShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }
}

/// Premium surface card with subtle elevation
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final bool showBorder;
  final bool showShadow;
  final VoidCallback? onTap;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = AppTheme.radiusXL,
    this.backgroundColor,
    this.showBorder = true,
    this.showShadow = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingMD),
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: isDark
                    ? AppColors.borderDark.withOpacity(0.5)
                    : AppColors.borderLight.withOpacity(0.5),
                width: 1,
              )
            : null,
        boxShadow: showShadow ? AppColors.softShadow : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }
}

/// Animated stat card with value and label
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final Color? backgroundColor;
  final bool showTrendIndicator;
  final bool isPositive;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.backgroundColor,
    this.showTrendIndicator = false,
    this.isPositive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.primary;

    return SurfaceCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                  child: Icon(icon, color: cardColor, size: 16),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (showTrendIndicator)
                Icon(
                  isPositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: isPositive ? AppColors.income : AppColors.expense,
                  size: 16,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: backgroundColor != null ? Colors.white : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium shimmer loading effect
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF2D2D2D),
                      const Color(0xFF3D3D3D),
                      const Color(0xFF2D2D2D),
                    ]
                  : [
                      const Color(0xFFE2E8F0),
                      const Color(0xFFF8FAFC),
                      const Color(0xFFE2E8F0),
                    ],
              stops: const [0.0, 0.5, 1.0],
              begin: const Alignment(-1.0, 0.0),
              end: const Alignment(1.0, 0.0),
              transform: _SlidingGradientTransform(_controller.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
        bounds.width * (slidePercent * 2 - 1), 0, 0);
  }
}

/// Pulsing dot indicator for live/syncing states
class PulsingDot extends StatefulWidget {
  final Color? color;
  final double size;

  const PulsingDot({
    super.key,
    this.color,
    this.size = 8,
  });

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = widget.color ?? AppColors.accent;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor.withOpacity(_animation.value),
            boxShadow: [
              BoxShadow(
                color: dotColor.withOpacity(_animation.value * 0.5),
                blurRadius: widget.size,
                spreadRadius: widget.size * 0.25,
              ),
            ],
          ),
        );
      },
    );
  }
}
