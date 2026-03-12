class GitHubRepo {
  final String name;
  final String? description;
  final String language;
  final int stars;
  final int openIssues;
  final String htmlUrl;
  final DateTime updatedAt;

  GitHubRepo({
    required this.name,
    this.description,
    required this.language,
    required this.stars,
    required this.openIssues,
    required this.htmlUrl,
    required this.updatedAt,
  });
}
