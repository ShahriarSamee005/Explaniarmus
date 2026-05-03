// result_screen.dart
// Main output screen — shows AI results in 4 tabs with voice playback
// Place this in: frontend/lib/screens/result_screen.dart

import 'package:flutter/material.dart';
import '../models/result_model.dart';
import '../services/tts_service.dart';

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

  // Checkbox states for steps tab
  late List<bool> _stepChecked;

  // Blue academic color palette
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color lightBlue = Color(0xFF1E88E5);
  static const Color surfaceBlue = Color(0xFFE3F2FD);
  static const Color accentBlue = Color(0xFF42A5F5);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _stepChecked = List.filled(widget.result.tasks.length, false);
    _tts.init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tts.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------
  // Voice button handler
  // -------------------------------------------------------------------
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

  // -------------------------------------------------------------------
  // Load dummy data for testing (Option B)
  // -------------------------------------------------------------------
  void _loadDummyData() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(result: SimplifyResult.dummy()),
      ),
    );
  }

  // -------------------------------------------------------------------
  // BUILD
  // -------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      appBar: _buildAppBar(),
      body: Column(
        children: [
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
      // Option B: floating test button
      floatingActionButton: FloatingActionButton.small(
        onPressed: _loadDummyData,
        backgroundColor: Colors.grey.shade400,
        tooltip: 'Load test data',
        child: const Icon(Icons.science_outlined, color: Colors.white),
      ),
    );
  }

  // -------------------------------------------------------------------
  // APP BAR
  // -------------------------------------------------------------------
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_stories, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 10),
          const Text(
            'Results',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        // Voice playback button
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _isSpeaking
                  ? Colors.white.withOpacity(0.3)
                  : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(
                _isSpeaking ? Icons.stop_circle : Icons.volume_up_rounded,
                color: Colors.white,
              ),
              tooltip: _isSpeaking ? 'Stop' : 'Read aloud',
              onPressed: _toggleSpeech,
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------
  // TAB BAR
  // -------------------------------------------------------------------
  Widget _buildTabBar() {
    return Container(
      color: primaryBlue,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
        tabs: const [
          Tab(icon: Icon(Icons.lightbulb_outline, size: 18), text: 'Explanation'),
          Tab(icon: Icon(Icons.push_pin_outlined, size: 18), text: 'Summary'),
          Tab(icon: Icon(Icons.checklist_rounded, size: 18), text: 'Steps'),
          Tab(icon: Icon(Icons.translate_rounded, size: 18), text: 'Bangla'),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // TAB 1: EXPLANATION
  // -------------------------------------------------------------------
  Widget _buildExplanationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabHeader(
            icon: Icons.lightbulb_rounded,
            iconColor: const Color(0xFFFFA726),
            title: 'Simple Explanation',
            subtitle: 'The academic content explained in plain language',
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: surfaceBlue, width: 2),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              widget.result.simpleExplanation,
              style: const TextStyle(
                fontSize: 15,
                height: 1.7,
                color: Color(0xFF1A1A2E),
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Hint to check other tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: surfaceBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.swipe_rounded, size: 18, color: lightBlue),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Swipe left to see key points, tasks, and Bangla translation',
                    style: TextStyle(fontSize: 12, color: Color(0xFF1565C0)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // TAB 2: SUMMARY
  // -------------------------------------------------------------------
  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabHeader(
            icon: Icons.push_pin_rounded,
            iconColor: const Color(0xFF26C6DA),
            title: 'Key Points',
            subtitle: '${widget.result.summaryPoints.length} important points extracted',
          ),
          const SizedBox(height: 16),
          ...widget.result.summaryPoints.asMap().entries.map((entry) {
            final index = entry.key;
            final point = entry.value;
            return _buildSummaryPoint(index + 1, point);
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryPoint(int number, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: surfaceBlue, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // TAB 3: STEPS (interactive checkboxes)
  // -------------------------------------------------------------------
  Widget _buildStepsTab() {
    final completed = _stepChecked.where((c) => c).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabHeader(
            icon: Icons.checklist_rounded,
            iconColor: const Color(0xFF66BB6A),
            title: 'Action Steps',
            subtitle: '$completed of ${widget.result.tasks.length} completed',
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: widget.result.tasks.isEmpty
                  ? 0
                  : completed / widget.result.tasks.length,
              backgroundColor: surfaceBlue,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF66BB6A)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.result.tasks.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            return _buildStepItem(index, step);
          }),
        ],
      ),
    );
  }

  Widget _buildStepItem(int index, String text) {
    final isChecked = _stepChecked[index];

    return GestureDetector(
      onTap: () {
        setState(() {
          _stepChecked[index] = !_stepChecked[index];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isChecked ? const Color(0xFFF1F8F1) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isChecked ? const Color(0xFF66BB6A) : surfaceBlue,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isChecked ? const Color(0xFF66BB6A) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isChecked
                      ? const Color(0xFF66BB6A)
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
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
                      fontWeight: FontWeight.bold,
                      color: isChecked
                          ? const Color(0xFF66BB6A)
                          : lightBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isChecked
                          ? Colors.grey.shade500
                          : const Color(0xFF1A1A2E),
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
    );
  }

  // -------------------------------------------------------------------
  // TAB 4: BANGLA
  // -------------------------------------------------------------------
  Widget _buildBanglaTab() {
    if (widget.result.banglaTranslation == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: surfaceBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text('🇧🇩', style: TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Bangla Translation Not Requested',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Go back to the input screen and toggle\n"Include Bangla Translation" before submitting.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabHeader(
            icon: Icons.translate_rounded,
            iconColor: const Color(0xFFEF5350),
            title: 'বাংলা অনুবাদ',
            subtitle: 'Bangla translation of the content',
          ),
          const SizedBox(height: 16),
          _buildBanglaSection(
            label: '🇧🇩 অনুবাদ',
            child: Text(
              widget.result.banglaTranslation!,
              style: const TextStyle(fontSize: 15, height: 1.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanglaSection({required String label, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCDD2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEF5350),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // SHARED: Tab header widget
  // -------------------------------------------------------------------
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}