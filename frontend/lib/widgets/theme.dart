// theme.dart
// Central design system for Explaniarmus — Glassmorphism + Light Blue
// Place this in: frontend/lib/theme.dart

import 'package:flutter/material.dart';
import 'dart:ui';

// ─────────────────────────────────────────────
// COLOR PALETTE
// ─────────────────────────────────────────────
class AppColors {
  // Background gradient
  static const Color gradientTop    = Color(0xFFB8D9F8);   // sky blue
  static const Color gradientMid    = Color(0xFFD6EEFF);   // pale blue
  static const Color gradientBottom = Color(0xFFF0F8FF);   // almost white

  // Accent
  static const Color accent         = Color(0xFF1A73E8);   // Google-blue
  static const Color accentLight    = Color(0xFF4FA3F7);
  static const Color accentDark     = Color(0xFF0D47A1);

  // Glass
  static const Color glassWhite     = Color(0xCCFFFFFF);   // 80% white
  static const Color glassBorder    = Color(0x66FFFFFF);   // 40% white
  static const Color glassShimmer   = Color(0x33FFFFFF);   // 20% white

  // Text
  static const Color textPrimary    = Color(0xFF0D1B2A);
  static const Color textSecondary  = Color(0xFF3D5A73);
  static const Color textHint       = Color(0xFF7A99B0);
  static const Color textOnAccent   = Colors.white;

  // Semantic
  static const Color success        = Color(0xFF2ECC71);
  static const Color warning        = Color(0xFFF39C12);
  static const Color error          = Color(0xFFE74C3C);
  static const Color bangla         = Color(0xFFE53935);

  // Tab colors
  static const Color tabExplanation = Color(0xFFFFA726);
  static const Color tabSummary     = Color(0xFF26C6DA);
  static const Color tabSteps       = Color(0xFF66BB6A);
  static const Color tabBangla      = Color(0xFFEF5350);
}

// ─────────────────────────────────────────────
// BACKGROUND GRADIENT
// ─────────────────────────────────────────────
class AppGradients {
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.gradientTop,
      AppColors.gradientMid,
      AppColors.gradientBottom,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient accentButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accentLight, AppColors.accent],
  );

  static const LinearGradient glassCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xE6FFFFFF), Color(0xB3FFFFFF)],  // 90% → 70%
  );
}

// ─────────────────────────────────────────────
// TEXT STYLES
// ─────────────────────────────────────────────
class AppTextStyles {
  static const TextStyle displayLarge = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.15,
  );

  static const TextStyle headingLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.7,
    letterSpacing: 0.1,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    letterSpacing: 0.2,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.accent,
    letterSpacing: 0.8,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.3,
  );
}

// ─────────────────────────────────────────────
// GLASS CARD WIDGET
// ─────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blur;
  final Color? borderColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.blur = 12,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: AppGradients.glassCard,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? AppColors.glassBorder,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.6),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// GRADIENT BACKGROUND WRAPPER
// ─────────────────────────────────────────────
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────
// ACCENT BUTTON
// ─────────────────────────────────────────────
class AccentButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double verticalPadding;

  const AccentButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.verticalPadding = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        decoration: BoxDecoration(
          gradient: AppGradients.accentButton,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(label, style: AppTextStyles.buttonText),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// GLASS APP BAR — use as preferredSizeWidget
// ─────────────────────────────────────────────
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;

  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AppBar(
          backgroundColor: Colors.white.withOpacity(0.25),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: showBack,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          title: Text(
            title,
            style: AppTextStyles.headingMedium,
          ),
          actions: actions,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: AppColors.glassBorder,
            ),
          ),
        ),
      ),
    );
  }
}