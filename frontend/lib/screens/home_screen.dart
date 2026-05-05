// home_screen.dart
// Landing screen with glassmorphism + light blue gradient
// Place this in: frontend/lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../widgets/theme.dart';
import 'input_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 36),
                _buildFeatureCards(),
                const SizedBox(height: 40),
                _buildGetStartedButton(context),
                const SizedBox(height: 24),
                _buildFootnote(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        GlassCard(
          padding: const EdgeInsets.all(14),
          borderRadius: 18,
          child: const Icon(
            Icons.auto_stories_rounded,
            color: AppColors.accent,
            size: 32,
          ),
        ),
        const SizedBox(height: 22),

        // App name
        const Text('Explaniarmus', style: AppTextStyles.displayLarge),
        const SizedBox(height: 10),

        // Tagline
        const Text(
          'Upload any academic text, image,\nor PDF — get instant clarity.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.55,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ── FEATURE CARDS ────────────────────────────
  Widget _buildFeatureCards() {
    final features = [
      _FeatureData(
        icon: Icons.image_outlined,
        color: AppColors.accentLight,
        title: 'Image Upload',
        subtitle: 'Snap or upload a photo of any assignment',
      ),
      _FeatureData(
        icon: Icons.picture_as_pdf_outlined,
        color: AppColors.error,
        title: 'PDF Upload',
        subtitle: 'Upload any PDF document or textbook page',
      ),
      _FeatureData(
        icon: Icons.text_fields_rounded,
        color: AppColors.success,
        title: 'Paste Text',
        subtitle: 'Copy and paste any academic content',
      ),
      _FeatureData(
        icon: Icons.translate_rounded,
        color: AppColors.bangla,
        title: 'Bangla Translation',
        subtitle: 'Get results explained in Bangla too',
      ),
    ];

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      borderRadius: 24,
      child: Column(
        children: features.asMap().entries.map((entry) {
          final isLast = entry.key == features.length - 1;
          return Column(
            children: [
              _FeatureRow(data: entry.value),
              if (!isLast) ...[
                const SizedBox(height: 4),
                Divider(
                  color: AppColors.glassBorder,
                  height: 16,
                  thickness: 1,
                ),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── GET STARTED BUTTON ───────────────────────
  Widget _buildGetStartedButton(BuildContext context) {
    return AccentButton(
      label: 'Get Started',
      icon: Icons.arrow_forward_rounded,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InputScreen()),
        );
      },
    );
  }

  // ── FOOTNOTE ─────────────────────────────────
  Widget _buildFootnote() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, size: 14, color: AppColors.textHint),
          const SizedBox(width: 4),
          const Text(
            'Powered by Groq · LLaMA 3',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

// ── FEATURE DATA MODEL ───────────────────────
class _FeatureData {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _FeatureData({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}

// ── FEATURE ROW WIDGET ────────────────────────
class _FeatureRow extends StatelessWidget {
  final _FeatureData data;

  const _FeatureRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: AppTextStyles.headingMedium),
                const SizedBox(height: 2),
                Text(data.subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textHint,
            size: 18,
          ),
        ],
      ),
    );
  }
}