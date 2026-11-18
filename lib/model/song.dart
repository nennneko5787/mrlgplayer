class Song {
  final String id;
  final String service;
  final String title;
  final String artist;
  final String? artworkUrl;
  final String websiteUrl;

  Song({
    required this.id,
    required this.service,
    required this.title,
    required this.artist,
    this.artworkUrl,
    required this.websiteUrl,
  });
}
