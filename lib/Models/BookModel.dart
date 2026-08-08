class BookModel {
  final int id;
  final String title;
  final String author;
  final String imageUrl;
  final int downloadCount;
  final String textUrl;
  final String description;
  final String language;

  const BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.downloadCount,
    required this.textUrl,
    required this.description,
    required this.language,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final authors = json['authors'] as List<dynamic>? ?? [];
    final languages = json['languages'] as List<dynamic>? ?? [];

    String authorName = 'Unknown Author';

    if (authors.isNotEmpty) {
      final author = authors.first as Map<String, dynamic>;
      authorName = author['name']?.toString() ?? 'Unknown Author';
    }

    final formats =
        json['formats'] as Map<String, dynamic>? ?? {};

    final imageUrl =
        formats['image/jpeg']?.toString() ??
        formats['image/png']?.toString() ??
        '';

    final textUrl =
        formats['text/plain; charset=utf-8']?.toString() ??
        formats['text/plain']?.toString() ??
        '';

    return BookModel(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? 'Unknown Title',
      author: authorName,
      imageUrl: imageUrl,
      downloadCount: json['download_count'] ?? 0,
      textUrl: textUrl,
      description: _getDescription(json),
      language: languages.isNotEmpty
          ? languages.first.toString().toUpperCase()
          : 'EN',
    );
  }

  static String _getDescription(Map<String, dynamic> json) {
    final subjects = json['subjects'] as List<dynamic>? ?? [];

    if (subjects.isNotEmpty) {
      return subjects.take(3).join(', ');
    }

    return 'No description available for this book.';
  }
}