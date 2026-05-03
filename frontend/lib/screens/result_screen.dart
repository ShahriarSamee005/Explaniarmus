import 'package:flutter/material.dart';
import '../models/result_model.dart';

class ResultScreen extends StatelessWidget {
  final SimplifyResult result;
  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    if (result.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: ${result.error}')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simple Explanation
            _SectionCard(
              title: '💡 Simple Explanation',
              color: Colors.blue.shade50,
              child: Text(result.simpleExplanation,
                  style: const TextStyle(fontSize: 15, height: 1.5)),
            ),
            const SizedBox(height: 16),

            // Summary Points
            _SectionCard(
              title: '📌 Key Points',
              color: Colors.green.shade50,
              child: Column(
                children: result.summaryPoints
                    .map((p) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Expanded(child: Text(p)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Tasks
            if (result.tasks.isNotEmpty)
              _SectionCard(
                title: '✅ Tasks / Action Items',
                color: Colors.orange.shade50,
                child: Column(
                  children: result.tasks
                      .map((t) => CheckboxListTile(
                            title: Text(t),
                            value: false,
                            onChanged: (_) {},
                            controlAffinity: ListTileControlAffinity.leading,
                          ))
                      .toList(),
                ),
              ),
            const SizedBox(height: 16),

            // Bangla
            if (result.banglaTranslation != null)
              _SectionCard(
                title: '🇧🇩 বাংলা অনুবাদ',
                color: Colors.red.shade50,
                child: Text(result.banglaTranslation!,
                    style: const TextStyle(fontSize: 15, height: 1.6)),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Color color;

  const _SectionCard(
      {required this.title, required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}