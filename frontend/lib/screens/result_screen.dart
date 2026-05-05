// result_screen.dart
// Output screen — glassmorphism style
// Bangla toggle lives inside the Bangla tab, re-calls API when toggled on
// Place this in: frontend/lib/screens/result_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/theme.dart';
import '../models/result_model.dart';
import '../services/tts_service.dart';
import '../services/api_service.dart';

class ResultScreen extends StatefulWidget {
  final SimplifyResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TtsService _tts = TtsService();
  bool _isSpeaking = false;

  // Bangla tab state
  bool _banglaEnabled = false;
  bool _banglaLoading = false;
  String? _banglaTranslation;

  // Checkbox states for steps tab
  late List<bool> _stepChecked;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _stepChecked = List.filled(widget.result.tasks.length, false);
    _banglaTranslation = widget.result.banglaTranslation;
    if (_banglaTranslation != null) _banglaEnabled = true;
    _tts.init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tts.dispose();
    super.dispose();
  }

  // ── VOICE ─────────────────────────────────────
  Future<void> _toggleSpeech() async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      await _tts.speakFullResult(
        simpleExplanation: widget.result.simpleExplanation,
        summary: widget.result.summaryPoints,
        steps: widget.result.tasks,
      );
      setState(() => _isSpeaking = false);
    }
  }

  // ── BANGLA RE-CALL ────────────────────────────
  Future<void> _fetchBanglaTranslation() async {
    // Use extracted text if available, otherwise use simple explanation
    final sourceText = widget.result.extractedText?.isNotEmpty == true
        ? widget.result.extractedText!
        : widget.result.simpleExplanation;

    setState(() => _banglaLoading = true);

    try {
      final result = await ApiService.simplifyText(sourceText, true);
      setState(() {
        _banglaTranslation = result.banglaTranslation;
        _banglaLoading = false;
      });
    } catch (e) {
      setState(() => _banglaLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to fetch Bangla translation'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _onBanglaToggle(bool value) async {
    setState(() => _banglaEnabled = value);
    if (value && _banglaTranslation == null) {
      await _fetchBanglaTranslation();
    }
  }

  // ── BUILD ─────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildGlassAppBar(),
      body: GradientBackground(
        child: Column(
          children: [
            // Space for app bar
            const SizedBox(height: kToolbarHeight + 32),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildExplanationTab(),
                  _buildSummaryTab(),
                  _buildStepsTab(),
                  _buildBanglaTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── GLASS APP BAR ─────────────────────────────
  PreferredSizeWidget _buildGlassAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AppBar(
            backgroundColor: Colors.white.withOpacity(0.25),
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            title: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_stories_rounded,
                      size: 16, color: AppColors.accent),
                ),
                const SizedBox(width: 10),
                const Text('Results', style: AppTextStyles.headingMedium),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: _toggleSpeech,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isSpeaking
                              ? AppColors.accent.withOpacity(0.25)
                              : Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.glassBorder,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          _isSpeaking
                              ? Icons.stop_circle_rounded
                              : Icons.volume_up_rounded,
                          color: _isSpeaking
                              ? AppColors.accent
                              : AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.glassBorder),
            ),
          ),
        ),
      ),
    );
  }

  // ── TAB BAR ───────────────────────────────────
  Widget _buildTabBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            border: Border(
              bottom: BorderSide(color: AppColors.glassBorder, width: 1),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.accent,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textHint,
            labelStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
            tabs: const [
              Tab(icon: Icon(Icons.lightbulb_outline, size: 18), text: 'Explain'),
              Tab(icon: Icon(Icons.push_pin_outlined, size: 18), text: 'Summary'),
              Tab(icon: Icon(Icons.checklist_rounded, size: 18), text: 'Steps'),
              Tab(icon: Icon(Icons.translate_rounded, size: 18), text: 'Bangla'),
            ],
          ),
        ),
      ),
    );
  }

  // ── TAB HEADER ────────────────────────────────
  Widget _buildTabHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.headingMedium),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }

  // ── TAB 1: EXPLANATION ────────────────────────
  Widget _buildExplanationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabHeader(
            icon: Icons.lightbulb_rounded,
            iconColor: AppColors.tabExplanation,
            title: 'Simple Explanation',
            subtitle: 'Explained in plain language',
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Text(
              widget.result.simpleExplanation,
              style: AppTextStyles.bodyLarge,
            ),
          ),
          const SizedBox(height: 14),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            borderRadius: 14,
            child: Row(
              children: [
                const Icon(Icons.swipe_rounded,
                    size: 16, color: AppColors.accentLight),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Swipe left for key points, steps, and Bangla translation',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TAB 2: SUMMARY ────────────────────────────
  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabHeader(
            icon: Icons.push_pin_rounded,
            iconColor: AppColors.tabSummary,
            title: 'Key Points',
            subtitle:
                '${widget.result.summaryPoints.length} important points extracted',
          ),
          const SizedBox(height: 16),
          ...widget.result.summaryPoints.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.tabSummary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            color: AppColors.tabSummary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(entry.value, style: AppTextStyles.bodyMedium),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── TAB 3: STEPS ─────────────────────────────
  Widget _buildStepsTab() {
    final completed = _stepChecked.where((c) => c).length;
    final total = widget.result.tasks.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabHeader(
            icon: Icons.checklist_rounded,
            iconColor: AppColors.tabSteps,
            title: 'Action Steps',
            subtitle: '$completed of $total completed',
          ),
          const SizedBox(height: 12),
          // Progress bar inside glass card
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            borderRadius: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Progress', style: AppTextStyles.label),
                    Text(
                      total == 0 ? '0%' : '${((completed / total) * 100).round()}%',
                      style: AppTextStyles.label,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : completed / total,
                    backgroundColor: AppColors.glassBorder,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.tabSteps),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...widget.result.tasks.asMap().entries.map((entry) {
            return _buildStepItem(entry.key, entry.value);
          }),
        ],
      ),
    );
  }

  Widget _buildStepItem(int index, String text) {
    final isChecked = _stepChecked[index];

    return GestureDetector(
      onTap: () => setState(() => _stepChecked[index] = !_stepChecked[index]),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isChecked
                      ? [
                          AppColors.tabSteps.withOpacity(0.15),
                          AppColors.tabSteps.withOpacity(0.08),
                        ]
                      : [
                          Colors.white.withOpacity(0.85),
                          Colors.white.withOpacity(0.65),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isChecked
                      ? AppColors.tabSteps.withOpacity(0.4)
                      : AppColors.glassBorder,
                  width: 1.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isChecked
                          ? AppColors.tabSteps
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isChecked
                            ? AppColors.tabSteps
                            : AppColors.textHint,
                        width: 2,
                      ),
                    ),
                    child: isChecked
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 15)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Step ${index + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isChecked
                                ? AppColors.tabSteps
                                : AppColors.accent,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          text,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: isChecked
                                ? AppColors.textHint
                                : AppColors.textPrimary,
                            decoration: isChecked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── TAB 4: BANGLA ─────────────────────────────
  Widget _buildBanglaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabHeader(
            icon: Icons.translate_rounded,
            iconColor: AppColors.tabBangla,
            title: 'বাংলা অনুবাদ',
            subtitle: 'Bangla translation of the content',
          ),
          const SizedBox(height: 16),

          // Toggle card — always visible
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            borderRadius: 16,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.tabBangla.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('🇧🇩', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bangla Translation',
                          style: AppTextStyles.headingMedium),
                      const SizedBox(height: 2),
                      Text(
                        _banglaEnabled
                            ? 'Translation enabled'
                            : 'Tap to enable',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _banglaEnabled,
                  onChanged: _banglaLoading ? null : _onBanglaToggle,
                  activeColor: AppColors.tabBangla,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Content area
          if (_banglaLoading)
            GlassCard(
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.tabBangla),
                      SizedBox(height: 16),
                      Text('Fetching Bangla translation...',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ),
            )
          else if (_banglaEnabled && _banglaTranslation != null)
            GlassCard(
              borderColor: AppColors.tabBangla.withOpacity(0.25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🇧🇩',
                          style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Text(
                        'অনুবাদ',
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.tabBangla),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _banglaTranslation!,
                    style: AppTextStyles.bodyLarge,
                  ),
                ],
              ),
            )
          else if (!_banglaEnabled)
            GlassCard(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Icon(Icons.translate_rounded,
                          size: 36, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      Text(
                        'Toggle the switch above\nto load Bangla translation',
                        style: AppTextStyles.caption
                            .copyWith(fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}