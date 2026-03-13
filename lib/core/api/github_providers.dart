import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/github/data/github_service.dart';
import '../../features/github/data/github_repository.dart';
import '../../features/github/domain/github_models.dart';
import 'auth_providers.dart';

final githubServiceProvider = Provider<GitHubService>((ref) => GitHubService());
final githubRepositoryProvider = Provider<GitHubRepository>((ref) => GitHubRepository());

/// Mis repos de GitHub (vía API)
final myGitHubReposProvider = FutureProvider<List<GitHubRepo>>((ref) async {
  return ref.watch(githubServiceProvider).getMyRepos();
});

/// Ramas de un repo específico
final repoBranchesProvider = FutureProvider.family<List<String>, ({String owner, String repo})>((ref, arg) async {
  return ref.watch(githubServiceProvider).getRepoBranches(arg.owner, arg.repo);
});

/// Notas de un repo/rama (vía Firestore)
final repoNotesProvider = StreamProvider.family<List<RepoNote>, ({String repoId, String branch})>((ref, arg) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(githubRepositoryProvider).watchRepoNotes(user.uid, arg.repoId, arg.branch);
});

/// Contenidos del repo (archivos/carpetas)
final repoContentsProvider = FutureProvider.family<List<Map<String, dynamic>>, ({String owner, String repo, String path, String branch})>((ref, arg) async {
  return ref.watch(githubServiceProvider).getRepoContents(arg.owner, arg.repo, path: arg.path, ref: arg.branch);
});

/// Último commit de una rama específica
final latestCommitProvider = FutureProvider.family<Map<String, String?>, ({String owner, String repo, String branch})>((ref, arg) async {
  return ref.watch(githubServiceProvider).getLatestCommit(arg.owner, arg.repo, arg.branch);
});
