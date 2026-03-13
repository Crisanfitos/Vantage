import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/github_providers.dart';
import '../domain/github_models.dart';
import 'repo_detail_screen.dart';

class DevHubScreen extends ConsumerWidget {
  const DevHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reposAsync = ref.watch(myGitHubReposProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('DEVHUB', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, letterSpacing: 2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.cyanAccent),
            onPressed: () => ref.refresh(myGitHubReposProvider),
          ),
        ],
      ),
      body: reposAsync.when(
        data: (repos) => repos.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: repos.length,
                itemBuilder: (context, i) => _buildRepoCard(context, repos[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
        error: (e, _) => Center(child: Text('Error: Configura GITHUB_PAT en .env\n$e')),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.extension_off_outlined, size: 64, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          const Text('No se han encontrado repositorios.', style: TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildRepoCard(BuildContext context, GitHubRepo repo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RepoDetailScreen(repo: repo))),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(repo.name, 
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                        ),
                        const SizedBox(width: 8),
                        _buildVisibilityBadge(repo.isPrivate),
                      ],
                    ),
                  ),
                  if (repo.isCiPassing != null)
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: repo.isCiPassing! ? Colors.greenAccent : Colors.redAccent,
                        boxShadow: [
                          BoxShadow(
                            color: (repo.isCiPassing! ? Colors.greenAccent : Colors.redAccent).withValues(alpha: 0.5),
                            blurRadius: 4, spreadRadius: 1
                          )
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.circle, size: 10, color: Colors.cyanAccent),
                  const SizedBox(width: 6),
                  Text(repo.language ?? 'Unknown', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(width: 16),
                  const Icon(Icons.star_border, size: 14, color: Colors.amberAccent),
                  const SizedBox(width: 4),
                  Text('${repo.stars}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LATEST COMMIT @ ${repo.latestCommitBranch?.toUpperCase()}', 
                      style: GoogleFonts.firaCode(fontSize: 9, color: Colors.cyanAccent.withValues(alpha: 0.6))),
                    const SizedBox(height: 6),
                    Text(repo.latestCommitMessage ?? 'No data available', 
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.firaCode(fontSize: 11, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisibilityBadge(bool isPrivate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isPrivate ? Colors.amberAccent.withValues(alpha: 0.1) : Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isPrivate ? Colors.amberAccent.withValues(alpha: 0.2) : Colors.white24),
      ),
      child: Text(
        isPrivate ? 'Private' : 'Public',
        style: TextStyle(
          fontSize: 9, 
          fontWeight: FontWeight.bold, 
          color: isPrivate ? Colors.amberAccent : Colors.white54
        ),
      ),
    );
  }
}
