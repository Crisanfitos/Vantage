import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/auth_providers.dart';
import '../../auth/domain/auth_models.dart';
import '../../auth/presentation/login_screen.dart';
import '../../finance/presentation/finance_screen.dart';
import '../../tasks/presentation/tasks_screen.dart';
import '../../media/presentation/media_hub_screen.dart';
import '../../github/presentation/dev_hub_screen.dart';
import '../../context_engine/presentation/context_settings_screen.dart';

class VantageDashboard extends ConsumerWidget {
  const VantageDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    
    return userAsync.when(
      data: (user) {
        if (user == null) return const LoginScreen();
        final style = user.dashboardStyle;

        return Scaffold(
          appBar: AppBar(
            title: Text('VANTAGE', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, letterSpacing: 2)),
            actions: [
              IconButton(
                icon: const Icon(Icons.auto_fix_high_outlined), // La "Varita" para contextos
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ContextSettingsScreen())),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProfileScreen())),
              ),
            ],
          ),
          body: _buildBody(style, context),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, trace) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildBody(DashboardStyle style, BuildContext context) {
    switch (style) {
      case DashboardStyle.grid: return _buildGridView(context);
      case DashboardStyle.cards: return _buildCardsView(context);
      case DashboardStyle.timeline: return _buildTimelineView();
    }
  }

  Widget _buildGridView(BuildContext context) {
    final modules = [
      {'name': 'Finanzas', 'icon': Icons.account_balance_wallet, 'color': Colors.teal},
      {'name': 'Tareas', 'icon': Icons.checklist, 'color': Colors.amber},
      {'name': 'GitHub', 'icon': Icons.code, 'color': Colors.blue},
      {'name': 'Media', 'icon': Icons.movie_filter, 'color': Colors.redAccent},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 20, childAspectRatio: 1.1,
      ),
      itemCount: modules.length,
      itemBuilder: (context, i) {
        final m = modules[i];
        return InkWell(
          onTap: () {
            _navigateToModule(context, m['name'] as String);
          },
          child: Container(
            decoration: BoxDecoration(
              color: (m['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: (m['color'] as Color).withOpacity(0.3)),
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

  Widget _buildCardsView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _infoCard(context, 'Finanzas', 'Balance: 1.250€', 'Nómina en 5 días', Icons.euro, Colors.teal),
        _infoCard(context, 'Tareas', 'Revisar motor de contexto', 'Prioridad Alta', Icons.task_alt, Colors.amber),
        _infoCard(context, 'GitHub', 'Vantage: 3 PRs abiertas', 'Último commit hace 2h', Icons.terminal, Colors.blue),
        _infoCard(context, 'Media', 'One Piece: Cap. 1090', 'Nuevo mañana', Icons.play_circle_outline, Colors.redAccent),
      ],
    );
  }

  Widget _infoCard(BuildContext context, String title, String main, String sub, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => _navigateToModule(context, title),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(main, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(sub, style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
                  ],
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildTimelineView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _timelineItem('09:00', 'Entrada al Trabajo', 'Modo Trabajo activado', true),
        _timelineItem('18:30', 'Gimnasio', 'Modo Calle activado', false),
      ],
    );
  }

  Widget _timelineItem(String time, String title, String desc, bool isCurrent) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Text(time, style: TextStyle(fontWeight: FontWeight.bold, color: isCurrent ? Colors.deepPurpleAccent : Colors.grey)),
            Container(width: 2, height: 50, color: Colors.grey.withOpacity(0.3)),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 16, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
              Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}

// --- PANTALLA DE PERFIL (Se mantiene igual) ---
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
              const Text('Preferencia de Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SegmentedButton<DashboardStyle>(
                segments: const [
                  ButtonSegment(value: DashboardStyle.grid, icon: Icon(Icons.grid_view), label: Text('Grid')),
                  ButtonSegment(value: DashboardStyle.cards, icon: Icon(Icons.view_agenda), label: Text('Cards')),
                  ButtonSegment(value: DashboardStyle.timeline, icon: Icon(Icons.timeline), label: Text('Timeline')),
                ],
                selected: {user.dashboardStyle},
                onSelectionChanged: (Set<DashboardStyle> newSelection) async {
                  final newStyle = newSelection.first;
                  await ref.read(authServiceProvider).updateUserPreference(
                    user.id, 
                    {'dashboardStyle': newStyle.name}
                  );
                },
              ),
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
              const SizedBox(height: 40),
              ElevatedButton.icon(

                icon: const Icon(Icons.logout),
                label: const Text('Cerrar Sesión'),
                onPressed: () {
                  ref.read(authServiceProvider).signOut();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.05), 
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
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pop(context); // Volver al login
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
