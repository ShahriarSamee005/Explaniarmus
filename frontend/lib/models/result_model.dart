class SimplifyResult {
  final String simpleExplanation;
  final List<String> summaryPoints;
  final List<String> tasks;
  final String? banglaTranslation;
  final String? extractedText;
  final String? error;

  SimplifyResult({
    required this.simpleExplanation,
    required this.summaryPoints,
    required this.tasks,
    this.banglaTranslation,
    this.extractedText,
    this.error,
  });

  factory SimplifyResult.fromJson(Map<String, dynamic> json) {
    return SimplifyResult(
      simpleExplanation: json['simple_explanation'] ?? '',
      summaryPoints: List<String>.from(json['summary_points'] ?? []),
      tasks: List<String>.from(json['tasks'] ?? []),
      banglaTranslation: json['bangla_translation'],
      extractedText: json['extracted_text'],
      error: json['error'],
    );
  }
}