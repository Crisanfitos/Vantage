import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../domain/github_models.dart';

class DevHubScreen extends ConsumerWidget {
  const DevHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DEVHUB', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      body: _buildRepoList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.link, color: Colors.white),
      ),
    );
  }

  Widget _buildRepoList() {
    // Mock data temporal
    final repos = [
      GitHubRepo(
        name: 'Vantage',
        description: 'Super-app contextual de vida personal',
        language: 'Dart',
        stars: 12,
        openIssues: 3,
        htmlUrl: '',
        updatedAt: DateTime.now(),
      ),
      GitHubRepo(
        name: 'Flutter-Clean-Arch',
        description: 'Plantilla base para proyectos Flutter',
        language: 'Dart',
        stars: 150,
        openIssues: 0,
        htmlUrl: '',
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: repos.length,
      itemBuilder: (context, index) => _buildRepoCard(repos[index]),
    );
  }

  Widget _buildRepoCard(GitHubRepo repo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(repo.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _buildLanguageChip(repo.language),
              ],
            ),
            const SizedBox(height: 8),
            Text(repo.description ?? 'Sin descripción', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Row(
              children: [
                _repoStat(Icons.star_outline, repo.stars.toString()),
                const SizedBox(width: 16),
                _repoStat(Icons.info_outline, '${repo.openIssues} issues'),
                const Spacer(),
                Text(
                  'Update: ${DateFormat('dd/MM').format(repo.updatedAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageChip(String lang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Text(lang, style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _repoStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
