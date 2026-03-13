import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../domain/github_models.dart';

class GitHubService {
  String get _token => dotenv.get('GITHUB_PAT', fallback: '');

  Map<String, String> get _headers => {
    'Authorization': 'token $_token',
    'Accept': 'application/vnd.github.v3+json',
  };

  Future<List<GitHubRepo>> getMyRepos() async {
    if (_token.isEmpty) return [];

    final url = Uri.parse('https://api.github.com/user/repos?sort=updated&per_page=10');
    try {
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Traemos detalles adicionales (commit y CI) en paralelo para cada repo
        return await Future.wait(data.map((json) async {
          final repoName = json['name'];
          final owner = json['owner']['login'];
          final defaultBranch = json['default_branch'];

          // Obtenemos el último commit de la rama por defecto
          final commitData = await getLatestCommit(owner, repoName, defaultBranch);
          final ciStatus = await _getWorkflowStatus(owner, repoName);

          return GitHubRepo(
            id: json['id'].toString(),
            name: repoName,
            owner: owner,
            description: json['description'],
            language: json['language'],
            stars: json['stargazers_count'],
            latestCommitMessage: commitData['message'],
            latestCommitBranch: defaultBranch,
            isCiPassing: ciStatus,
            isPrivate: json['private'] ?? false,
          );
        }));
      }
    } catch (_) {}
    return [];
  }

  Future<Map<String, String?>> getLatestCommit(String owner, String repo, String branch) async {
    final url = Uri.parse('https://api.github.com/repos/$owner/$repo/commits/$branch');
    try {
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'message': data['commit']['message'],
          'author': data['commit']['author']['name'],
        };
      }
    } catch (_) {}
    return {'message': null, 'author': null};
  }

  Future<bool?> _getWorkflowStatus(String owner, String repo) async {
    final url = Uri.parse('https://api.github.com/repos/$owner/$repo/actions/runs?per_page=1');
    try {
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> runs = data['workflow_runs'] ?? [];
        if (runs.isEmpty) return null;
        return runs.first['conclusion'] == 'success';
      }
    } catch (_) {}
    return null;
  }

  Future<List<String>> getRepoBranches(String owner, String repo) async {
    final url = Uri.parse('https://api.github.com/repos/$owner/$repo/branches');
    try {
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((b) => b['name'] as String).toList();
      }
    } catch (_) {}
    return ['main', 'master'];
  }

  Future<List<Map<String, dynamic>>> getRepoContents(String owner, String repo, {String path = '', String ref = 'main'}) async {
    final url = Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path?ref=$ref');
    try {
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => {
          'name': item['name'],
          'type': item['type'], // 'dir' o 'file'
          'path': item['path'],
        }).toList();
      }
    } catch (_) {}
    return [];
  }
}
