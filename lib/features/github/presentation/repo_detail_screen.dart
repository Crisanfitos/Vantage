import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../../core/api/auth_providers.dart';
import '../../../core/api/github_providers.dart';
import '../domain/github_models.dart';

class RepoDetailScreen extends ConsumerStatefulWidget {
  final GitHubRepo repo;
  const RepoDetailScreen({super.key, required this.repo});

  @override
  ConsumerState<RepoDetailScreen> createState() => _RepoDetailScreenState();
}

class _RepoDetailScreenState extends ConsumerState<RepoDetailScreen> {
  String _selectedBranch = 'main';
  String _currentPath = '';
  final List<String> _pathHistory = [];
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedBranch = widget.repo.latestCommitBranch ?? 'main';
  }

  void _navigateToDir(String path) {
    setState(() {
      _pathHistory.add(_currentPath);
      _currentPath = path;
    });
  }

  void _goBack() {
    if (_pathHistory.isNotEmpty) {
      setState(() {
        _currentPath = _pathHistory.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final branchesAsync = ref.watch(repoBranchesProvider((owner: widget.repo.owner, repo: widget.repo.name)));
    final notesAsync = ref.watch(repoNotesProvider((repoId: widget.repo.id, branch: _selectedBranch)));
    final contentsAsync = ref.watch(repoContentsProvider((
      owner: widget.repo.owner, 
      repo: widget.repo.name, 
      path: _currentPath, 
      branch: _selectedBranch
    )));
    final latestCommitAsync = ref.watch(latestCommitProvider((
      owner: widget.repo.owner,
      repo: widget.repo.name,
      branch: _selectedBranch
    )));

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150),
          child: Text(widget.repo.name, 
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        actions: [
          branchesAsync.when(
            data: (list) => Container(
              constraints: const BoxConstraints(maxWidth: 120),
              child: DropdownButton<String>(
                isExpanded: true,
                value: list.contains(_selectedBranch) ? _selectedBranch : (list.isNotEmpty ? list.first : 'main'),
                underline: const SizedBox(),
                dropdownColor: const Color(0xFF161B22),
                icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.cyanAccent),
                selectedItemBuilder: (context) => list.map((b) => Center(
                  child: Text(b, 
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.cyanAccent, fontWeight: FontWeight.bold))
                )).toList(),
                items: list.map((b) => DropdownMenuItem(
                  value: b,
                  child: Text(b, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                )).toList(),
                onChanged: (val) => setState(() {
                  _selectedBranch = val!;
                  _currentPath = '';
                  _pathHistory.clear();
                }),
              ),
            ),
            loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            error: (_, __) => const Icon(Icons.error_outline),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              indicatorColor: Colors.cyanAccent,
              labelColor: Colors.cyanAccent,
              unselectedLabelColor: Colors.white24,
              tabs: [
                Tab(text: 'CONTEXTO', icon: Icon(Icons.terminal, size: 18)),
                Tab(text: 'ARCHIVOS', icon: Icon(Icons.folder_open, size: 18)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Pestaña 1: Notas de Contexto de Rama
                  Column(
                    children: [
                      Expanded(child: _buildNotesSection(notesAsync)),
                      _buildNoteInput(),
                    ],
                  ),
                  // Pestaña 2: Explorador de Archivos
                  _buildFileExplorer(contentsAsync, latestCommitAsync),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileExplorer(AsyncValue<List<Map<String, dynamic>>> contentsAsync, AsyncValue<Map<String, String?>> latestCommitAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Último commit de la rama
        _buildLatestCommitHeader(latestCommitAsync),
        
        if (_currentPath.isNotEmpty)
          ListTile(
            leading: const Icon(Icons.arrow_upward, color: Colors.cyanAccent, size: 18),
            title: Text('.. /${_currentPath.split('/').last}', style: const TextStyle(fontSize: 12, color: Colors.cyanAccent)),
            onTap: _goBack,
            dense: true,
          ),
        Expanded(
          child: contentsAsync.when(
            data: (items) => ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                final isDir = item['type'] == 'dir';
                return ListTile(
                  leading: Icon(
                    isDir ? Icons.folder : Icons.insert_drive_file_outlined,
                    color: isDir ? Colors.amberAccent : Colors.white38,
                    size: 18,
                  ),
                  title: Text(item['name'], style: TextStyle(fontSize: 13, color: isDir ? Colors.white : Colors.white70)),
                  onTap: isDir ? () => _navigateToDir(item['path']) : null,
                  dense: true,
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
            error: (e, _) => Center(child: Text('Error al cargar archivos: $e', style: const TextStyle(fontSize: 10))),
          ),
        ),
      ],
    );
  }

  Widget _buildLatestCommitHeader(AsyncValue<Map<String, String?>> latestCommitAsync) {
    return latestCommitAsync.when(
      data: (data) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        color: Colors.black.withValues(alpha: 0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LATEST_COMMIT_ON_$_selectedBranch'.toUpperCase(), 
              style: GoogleFonts.firaCode(fontSize: 9, color: Colors.cyanAccent.withValues(alpha: 0.6))),
            const SizedBox(height: 4),
            Text(data['message'] ?? 'No data', 
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.firaCode(fontSize: 11, color: Colors.white70, height: 1.4)),
            const SizedBox(height: 4),
            Text('By ${data['author'] ?? "Unknown"}', 
              style: GoogleFonts.firaCode(fontSize: 9, color: Colors.white24)),
          ],
        ),
      ),
      loading: () => const LinearProgressIndicator(color: Colors.cyanAccent, minHeight: 2),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildNotesSection(AsyncValue<List<RepoNote>> notesAsync) {
    return notesAsync.when(
      data: (notes) => notes.isEmpty
          ? Center(child: Text('Sin contexto registrado para $_selectedBranch', style: const TextStyle(color: Colors.white24, fontStyle: FontStyle.italic)))
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: notes.length,
              itemBuilder: (context, i) => _buildTerminalNote(notes[i]),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildTerminalNote(RepoNote note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('> BRANCH_CONTEXT', style: GoogleFonts.firaCode(fontSize: 10, color: Colors.cyanAccent.withValues(alpha: 0.5))),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 14, color: Colors.white24),
                onPressed: () => ref.read(githubRepositoryProvider).deleteRepoNote(ref.read(authStateProvider).value!.uid, note.id),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(note.content, style: GoogleFonts.firaCode(fontSize: 13, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildNoteInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).padding.bottom + 12),
      color: const Color(0xFF161B22),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _noteController,
              style: GoogleFonts.firaCode(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Añadir nota al contexto de $_selectedBranch...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.terminal, color: Colors.cyanAccent),
            onPressed: _saveNote,
          ),
        ],
      ),
    );
  }

  void _saveNote() {
    if (_noteController.text.isNotEmpty) {
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        final note = RepoNote(
          id: const Uuid().v4(),
          repoId: widget.repo.id,
          branchName: _selectedBranch,
          content: _noteController.text,
          createdAt: DateTime.now(),
        );
        ref.read(githubRepositoryProvider).saveRepoNote(user.uid, note);
        _noteController.clear();
      }
    }
  }
}
