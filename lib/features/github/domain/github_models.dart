class GitHubRepo {
  final String id;
  final String name;
  final String owner;
  final String? description;
  final String? language;
  final int stars;
  final String? latestCommitMessage;
  final String? latestCommitBranch;
  final bool? isCiPassing;
  final bool isPrivate;

  GitHubRepo({
    required this.id,
    required this.name,
    required this.owner,
    this.description,
    this.language,
    required this.stars,
    this.latestCommitMessage,
    this.latestCommitBranch,
    this.isCiPassing,
    this.isPrivate = false,
  });
}

class RepoNote {
  final String id;
  final String repoId;
  final String branchName;
  final String content;
  final DateTime createdAt;

  RepoNote({
    required this.id,
    required this.repoId,
    required this.branchName,
    required this.content,
    required this.createdAt,
  });
}
