import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:vantage/core/api/auth_providers.dart';
import 'package:vantage/core/api/dashboard_providers.dart';
import 'package:vantage/core/api/task_providers.dart';
import 'package:vantage/features/auth/domain/auth_models.dart';
import 'package:vantage/features/auth/presentation/login_screen.dart';
import 'package:vantage/features/finance/presentation/finance_screen.dart';
import 'package:vantage/features/tasks/domain/task_models.dart';
import 'package:vantage/features/tasks/presentation/tasks_screen.dart';
import 'package:vantage/features/media/presentation/media_hub_screen.dart';
import 'package:vantage/features/github/presentation/dev_hub_screen.dart';
import 'package:vantage/features/context_engine/presentation/context_settings_screen.dart';
import 'package:vantage/features/context_engine/presentation/context_banner_overlay.dart';
import 'package:vantage/features/context_engine/presentation/environments_provider.dart';
import 'package:vantage/features/context_engine/domain/environment.dart';
import 'package:vantage/features/context_engine/domain/action_mode_models.dart';
import 'package:vantage/features/dashboard/domain/dashboard_models.dart';
import 'package:vantage/features/dashboard/presentation/schedules_screen.dart';

class VantageDashboard extends ConsumerWidget {
  const VantageDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final activeEnv = ref.watch(currentActiveEnvironmentProvider);
    final allEnvs = ref.watch(environmentsProvider);
    
    return userAsync.when(
      data: (user) {
        if (user == null) return const LoginScreen();
        final style = user.dashboardStyle;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('VANTAGE', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(width: 4),
                _buildStyleSelector(context, ref, user),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.auto_fix_high_outlined), 
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ContextSettingsScreen())),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
              ),
            ],
          ),
          body: _buildUniversalLayout(context, ref, user, style, activeEnv),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user.actionModeId != 'automatic')
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FloatingActionButton.small(
                    heroTag: 'aura_selector',
                    onPressed: () => _showAuraSelector(context, ref, allEnvs, activeEnv),
                    backgroundColor: activeEnv != null ? Color(activeEnv.colorSeedValue) : Colors.deepPurpleAccent,
                    child: const Icon(Icons.blur_on, color: Colors.white),
                  ),
                ),
              if (style == DashboardStyle.timeline)
                FloatingActionButton(
                  heroTag: 'main_fab',
                  onPressed: () => _showAddEventDialog(context, ref, activeEnv?.id),
                  backgroundColor: Colors.deepPurpleAccent,
                  child: const Icon(Icons.more_time),
                ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, trace) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildUniversalLayout(BuildContext context, WidgetRef ref, VantageUser user, DashboardStyle style, VantageEnvironment? activeEnv) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: _buildBody(style, context, ref, activeEnv),
        ),
        const Divider(height: 1, thickness: 0.5, color: Colors.white10),
        _buildBottomLorePanel(context, ref, activeEnv),
      ],
    );
  }

  Widget _buildBottomLorePanel(BuildContext context, WidgetRef ref, VantageEnvironment? activeEnv) {
    final notes = ref.watch(contextualNotesProvider);
    final tasks = ref.watch(filteredTasksProvider(activeEnv?.id));
    final pendingTasks = tasks.where((t) => !t.isCompleted).toList();

    return Expanded(
      flex: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notes, size: 16, color: Colors.amberAccent),
                      const SizedBox(width: 8),
                      Text(
                        'NOTAS DE ${activeEnv?.name.toUpperCase() ?? "CALLE"}', 
                        style: GoogleFonts.montserrat(
                          fontSize: 11, 
                          fontWeight: FontWeight.w800, 
                          letterSpacing: 1.5, 
                          color: Colors.amberAccent.withValues(alpha: 0.7)
                        )
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (pendingTasks.isNotEmpty)
                        IconButton(
                          icon: Badge(
                            label: Text('${pendingTasks.length}'),
                            child: const Icon(Icons.assignment_late_outlined, size: 20, color: Colors.cyanAccent),
                          ),
                          onPressed: () => _showQuickQuests(context, pendingTasks, ref),
                          tooltip: 'Tareas principales',
                        ),
                      IconButton(
                        icon: const Icon(Icons.add_comment_outlined, size: 20),
                        onPressed: () => _showAddNoteDialog(context, ref, activeEnv?.id),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: notes.isEmpty
                  ? const Center(child: Text('Sin notas registradas en este lugar.', style: TextStyle(color: Colors.blueGrey, fontSize: 12, fontStyle: FontStyle.italic)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: notes.length,
                      itemBuilder: (context, i) => _buildLoreNote(notes[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoreNote(VantageNote note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              note.content,
              style: GoogleFonts.notoSans(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickQuests(BuildContext context, List<VantageTask> pendingTasks, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.priority_high, color: Colors.cyanAccent),
                  const SizedBox(width: 12),
                  Text('TAREAS PRINCIPALES', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.cyanAccent)),
                ],
              ),
              const SizedBox(height: 24),
              ...pendingTasks.take(3).map((t) => CheckboxListTile(
                title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Prioridad: ${t.priority.name}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                value: t.isCompleted,
                onChanged: (val) async {
                  final user = ref.read(authStateProvider).value;
                  if (user != null) {
                    await ref.read(taskRepositoryProvider).saveTask(user.uid, t.copyWith(isCompleted: val ?? false));
                    // Cerramos el modal para que se refresque la lista principal
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.cyanAccent,
                dense: true,
              )),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToModule(context, 'Tareas');
                  }, 
                  child: const Text('IR AL GESTOR DE TAREAS COMPLETO', style: TextStyle(color: Colors.cyanAccent))
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(DashboardStyle style, BuildContext context, WidgetRef ref, VantageEnvironment? activeEnv) {
    switch (style) {
      case DashboardStyle.grid: return _buildGridView(context, activeEnv);
      case DashboardStyle.cards: return _buildCardsView(context, activeEnv);
      case DashboardStyle.timeline: return _buildTimelineView(context, ref);
    }
  }

  Widget _buildGridView(BuildContext context, VantageEnvironment? activeEnv) {
    final allModules = [
      {'id': 'finance', 'name': 'Finanzas', 'icon': Icons.account_balance_wallet, 'color': Colors.teal},
      {'id': 'tasks', 'name': 'Tareas', 'icon': Icons.checklist, 'color': Colors.amber},
      {'id': 'github', 'name': 'GitHub', 'icon': Icons.code, 'color': Colors.blue},
      {'id': 'media', 'name': 'Media', 'icon': Icons.movie_filter, 'color': Colors.redAccent},
    ];

    final visibleModules = activeEnv == null 
        ? allModules 
        : allModules.where((m) => activeEnv.visibleModules.contains(m['id'])).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 20, childAspectRatio: 1.1,
      ),
      itemCount: visibleModules.length,
      itemBuilder: (context, i) {
        final m = visibleModules[i];
        return InkWell(
          onTap: () => _navigateToModule(context, m['name'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: (m['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: (m['color'] as Color).withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(m['icon'] as IconData, size: 40, color: m['color'] as Color),
                const SizedBox(height: 12),
                Text(m['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardsView(BuildContext context, VantageEnvironment? activeEnv) {
    final visibleIds = activeEnv?.visibleModules ?? ['finance', 'tasks', 'github', 'media'];
    
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (visibleIds.contains('finance'))
          _moduleCard(context, 'Finanzas', 'Balance: Ver detalle', 'Nómina configurada', Icons.euro, Colors.teal),
        if (visibleIds.contains('tasks'))
          _moduleCard(context, 'Tareas', 'Revisar motor de contexto', 'Prioridad Alta', Icons.task_alt, Colors.amber),
        if (visibleIds.contains('github'))
          _moduleCard(context, 'GitHub', 'Proyectos activos', 'Estado de repos', Icons.terminal, Colors.blue),
        if (visibleIds.contains('media'))
          _moduleCard(context, 'Media', 'Tus series y animes', 'Capítulos pendientes', Icons.play_circle_outline, Colors.redAccent),
      ],
    );
  }

  Widget _moduleCard(BuildContext context, String title, String main, String sub, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => _navigateToModule(context, title),
        borderRadius: BorderRadius.circular(20),
        child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [
          CircleAvatar(backgroundColor: color.withValues(alpha: 0.2), child: Icon(icon, color: color)),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(main, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(sub, style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
          ])),
        ])),
      ),
    );
  }

  Widget _buildTimelineView(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(timelineEventsProvider);
    final activeEnv = ref.watch(currentActiveEnvironmentProvider);

    return eventsAsync.when(
      data: (events) {
        final visibleEvents = events.where((e) => e.environmentId == null || e.environmentId == activeEnv?.id).toList();
        return visibleEvents.isEmpty
          ? const Center(child: Text('Sin eventos para este contexto'))
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: visibleEvents.length,
              itemBuilder: (context, i) => _buildTimelineItem(visibleEvents[i]),
            );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildTimelineItem(TimelineEvent event) {
    final start = '${event.startHour.toString().padLeft(2, '0')}:${event.startMinute.toString().padLeft(2, '0')}';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          Text(start, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent)),
          Container(width: 2, height: 40, color: Colors.deepPurpleAccent.withValues(alpha: 0.2)),
        ]),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(event.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
        ])),
      ],
    );
  }

  Widget _buildStyleSelector(BuildContext context, WidgetRef ref, VantageUser user) {
    return PopupMenuButton<DashboardStyle>(
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.white54),
      onSelected: (newStyle) async {
        await ref.read(authServiceProvider).updateUserPreference(user.id, {'dashboardStyle': newStyle.name});
      },
      itemBuilder: (context) => [
        _styleMenuItem(context, DashboardStyle.grid, Icons.grid_view, 'Cuadrícula', user.dashboardStyle),
        _styleMenuItem(context, DashboardStyle.cards, Icons.view_agenda_outlined, 'Tarjetas', user.dashboardStyle),
        _styleMenuItem(context, DashboardStyle.timeline, Icons.timeline, 'Cronología', user.dashboardStyle),
      ],
    );
  }

  PopupMenuItem<DashboardStyle> _styleMenuItem(BuildContext context, DashboardStyle style, IconData icon, String label, DashboardStyle current) {
    final isSelected = style == current;
    final themeColor = Theme.of(context).colorScheme.primary;
    return PopupMenuItem(
      value: style,
      child: Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: isSelected ? themeColor : Colors.transparent, boxShadow: isSelected ? [BoxShadow(color: themeColor.withValues(alpha: 0.5), blurRadius: 4, spreadRadius: 1)] : null)),
        const SizedBox(width: 12),
        Icon(icon, size: 18, color: isSelected ? themeColor : Colors.white54),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? themeColor : Colors.white)),
      ]),
    );
  }

  void _showAddNoteDialog(BuildContext context, WidgetRef ref, String? envId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Nota'),
        content: TextField(controller: controller, maxLines: 3, autofocus: true, decoration: const InputDecoration(hintText: '¿En qué estás pensando?')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final note = VantageNote(id: const Uuid().v4(), content: controller.text, environmentId: envId, createdAt: DateTime.now());
                final user = ref.read(authStateProvider).value;
                if (user != null) {
                  ref.read(dashboardRepositoryProvider).saveNote(user.uid, note);
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog(BuildContext context, WidgetRef ref, String? envId) {
    final titleController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nuevo Evento'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Título')),
            ListTile(
              title: const Text('Hora'),
              trailing: Text(selectedTime.format(context)),
              onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: selectedTime);
                if (picked != null) setState(() => selectedTime = picked);
              },
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final event = TimelineEvent(id: const Uuid().v4(), title: titleController.text, startHour: selectedTime.hour, startMinute: selectedTime.minute, environmentId: envId);
                  final user = ref.read(authStateProvider).value;
                  if (user != null) {
                    ref.read(dashboardRepositoryProvider).saveEvent(user.uid, event);
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Añadir'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAuraSelector(BuildContext context, WidgetRef ref, List<VantageEnvironment> envs, VantageEnvironment? active) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Cambiar Contexto Manual', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Wrap(spacing: 12, runSpacing: 12, children: [
            _auraChip(context, ref, null, active?.id == null), 
            ...envs.map((e) => _auraChip(context, ref, e, active?.id == e.id)),
          ]),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _auraChip(BuildContext context, WidgetRef ref, VantageEnvironment? env, bool isSelected) {
    final color = env != null ? Color(env.colorSeedValue) : Colors.deepPurpleAccent;
    return InkWell(
      onTap: () { ref.read(currentActiveEnvironmentProvider.notifier).state = env; Navigator.pop(context); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: isSelected ? color : color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.5))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(env?.iconName == 'home' ? Icons.home : (env?.iconName == 'business_center' ? Icons.business_center : Icons.location_on), size: 18, color: isSelected ? Colors.white : color),
          const SizedBox(width: 8),
          Text(env?.name ?? 'Calle', style: TextStyle(color: isSelected ? Colors.white : color, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  void _navigateToModule(BuildContext context, String moduleName) {
    Widget screen;
    switch (moduleName) {
      case 'Finanzas': screen = const FinanceScreen(); break;
      case 'Tareas': screen = const TasksScreen(); break;
      case 'Media': screen = const MediaHubScreen(); break;
      case 'GitHub': screen = const DevHubScreen(); break;
      default: return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    
    return userAsync.when(
      data: (user) {
        if (user == null) return const Scaffold(body: Center(child: Text('No hay sesión')));

        return Scaffold(
          appBar: AppBar(title: const Text('Mi Perfil')),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
              const SizedBox(height: 20),
              Center(child: Text(user.fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
              Center(child: Text(user.jobTitle ?? 'Sin puesto definido', style: const TextStyle(color: Colors.grey))),
              const SizedBox(height: 40),
              const Text('Inteligencia Contextual', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('¿Cómo debe reaccionar Vantage al detectar un cambio de lugar?', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: user.actionModeId,
                decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                items: const [
                  DropdownMenuItem(value: 'manual', child: Text('Manual (Solo avisar)')),
                  DropdownMenuItem(value: 'suggested', child: Text('Sugerido (Preguntar)')),
                  DropdownMenuItem(value: 'automatic', child: Text('Automático (Cambiar solo)')),
                ],
                onChanged: (val) async {
                  if (val != null) {
                    await ref.read(authServiceProvider).updateUserPreference(user.id, {'actionModeId': val});
                  }
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Notificaciones de Entorno'),
                subtitle: const Text('Avisar al entrar o salir de un lugar guardado'),
                value: user.notificationsEnabled,
                onChanged: (val) async {
                  await ref.read(authServiceProvider).updateUserPreference(user.id, {'notificationsEnabled': val});
                },
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.alarm, color: Colors.deepPurpleAccent),
                title: const Text('Gestionar Horarios Fijos'),
                subtitle: const Text('Entrada al trabajo, rutinas diarias...'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SchedulesScreen())),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar Sesión'),
                onPressed: () {
                  ref.read(authServiceProvider).signOut();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.05), 
                  foregroundColor: Colors.white
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                label: const Text('Eliminar Cuenta Definitivamente', style: TextStyle(color: Colors.redAccent)),
                onPressed: () => _showDeleteAccountDialog(context, ref, user.id),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, trace) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar cuenta?'),
        content: const Text('Esta acción borrará todos tus entornos, tareas y datos financieros de la nube. No se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authServiceProvider).deleteAccount();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ELIMINAR TODO', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
