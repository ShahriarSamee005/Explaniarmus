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

  factory SimplifyResult.dummy() {
    return SimplifyResult(
      simpleExplanation:
          'This assignment asks you to write a research paper about climate change. '
          'You need to find at least 5 sources, write 2000 words, and submit it by Friday.',
      summaryPoints: [
        'Write a 2000-word research paper on climate change',
        'Use at least 5 credible academic sources',
        'Cover causes, effects, and solutions',
        'Follow APA citation format',
        'Deadline is this Friday at 11:59 PM',
      ],
      tasks: [
        'Read the assignment brief carefully',
        'Search for 5 credible sources on Google Scholar',
        'Create an outline covering causes, effects, and solutions',
        'Write the paper section by section',
        'Add APA citations and reference list',
        'Proofread and submit before Friday 11:59 PM',
      ],
      banglaTranslation:
          'এই অ্যাসাইনমেন্টে তোমাকে জলবায়ু পরিবর্তন নিয়ে একটি গবেষণা পত্র লিখতে হবে। '
          'কমপক্ষে ৫টি সূত্র ব্যবহার করো এবং শুক্রবারের মধ্যে জমা দাও।',
    );
  }
}  