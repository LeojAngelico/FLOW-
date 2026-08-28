class Avatar {
  final String path;
  final String filename;
  final String directory;
  final String fullPath;
  final String thumbPath;

  const Avatar({
    required this.path,
    required this.filename,
    required this.directory,
    required this.fullPath,
    required this.thumbPath,
  });

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      path: json['path'] as String? ?? '',
      filename: json['filename'] as String? ?? '',
      directory: json['directory'] as String? ?? '',
      fullPath: json['full_path'] as String? ?? '',
      thumbPath: json['thumb_path'] as String? ?? '',
    );
  }
}
