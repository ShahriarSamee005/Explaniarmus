// input_screen.dart
// Input screen — glassmorphism style, Bangla toggle removed (moved to result screen)
// Place this in: frontend/lib/screens/input_screen.dart

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/theme.dart';
import '../services/api_service.dart';
import '../models/result_model.dart';
import 'result_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  String _loadingMessage = 'Processing...';

  // ── HELPERS ──────────────────────────────────
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _goToResult(SimplifyResult result) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
    );
  }

  void _setLoading(bool value, [String msg = 'Processing...']) {
    setState(() {
      _isLoading = value;
      _loadingMessage = msg;
    });
  }

  // ── ACTIONS ──────────────────────────────────
  Future<void> _submitText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      _showError('Please enter some text first.');
      return;
    }
    _setLoading(true, 'Simplifying your text...');
    try {
      final result = await ApiService.simplifyText(text, false);
      _goToResult(result);
    } catch (e) {
      _showError('Error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;

    _setLoading(true, 'Reading image with AI vision...');
    try {
      final file = result.files.single;
      final simplifyResult = await ApiService.simplifyImageBytes(
        file.bytes!,
        file.name,
        false,
      );
      _goToResult(simplifyResult);
    } catch (e) {
      _showError('Error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;

    _setLoading(true, 'Extracting text from PDF...');
    try {
      final file = result.files.single;
      final simplifyResult = await ApiService.simplifyPdfBytes(
        file.bytes!,
        file.name,
        false,
      );
      _goToResult(simplifyResult);
    } catch (e) {
      _showError('Error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ── BUILD ─────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(title: 'Explaniarmus'),
      body: GradientBackground(
        child: _isLoading ? _buildLoading() : _buildContent(),
      ),
    );
  }

  // ── LOADING STATE ─────────────────────────────
  Widget _buildLoading() {
    return Center(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        borderRadius: 28,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _loadingMessage,
              style: AppTextStyles.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'This may take a few seconds',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  // ── MAIN CONTENT ──────────────────────────────
  Widget _buildContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionLabel('Upload a File'),
            const SizedBox(height: 12),
            _buildUploadButtons(),
            const SizedBox(height: 28),
            _buildDivider(),
            const SizedBox(height: 28),
            _buildSectionLabel('Or Paste Text'),
            const SizedBox(height: 12),
            _buildTextField(),
            const SizedBox(height: 20),
            AccentButton(
              label: 'Simplify Text',
              icon: Icons.auto_fix_high_rounded,
              onPressed: _submitText,
            ),
          ],
        ),
      ),
    );
  }

  // ── SECTION LABEL ─────────────────────────────
  Widget _buildSectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.label,
    );
  }

  // ── UPLOAD BUTTONS ────────────────────────────
  Widget _buildUploadButtons() {
    return Row(
      children: [
        Expanded(
          child: _UploadCard(
            icon: Icons.image_rounded,
            label: 'Image',
            color: AppColors.accentLight,
            onTap: _pickImage,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _UploadCard(
            icon: Icons.picture_as_pdf_rounded,
            label: 'PDF',
            color: AppColors.error,
            onTap: _pickPdf,
          ),
        ),
      ],
    );
  }

  // ── DIVIDER ───────────────────────────────────
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.glassBorder, thickness: 1.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('or', style: AppTextStyles.caption),
        ),
        Expanded(child: Divider(color: AppColors.glassBorder, thickness: 1.5)),
      ],
    );
  }

  // ── TEXT FIELD ────────────────────────────────
  Widget _buildTextField() {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 18,
      child: TextField(
        controller: _textController,
        maxLines: 7,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Paste your assignment or academic text here...',
          hintStyle: AppTextStyles.caption.copyWith(fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }
}

// ── UPLOAD CARD ───────────────────────────────
class _UploadCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _UploadCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 24),
      borderRadius: 20,
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 10),
          Text(label, style: AppTextStyles.headingMedium),
          const SizedBox(height: 2),
          Text('Tap to upload', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}