import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardPrototyper extends StatefulWidget {
  const DashboardPrototyper({super.key});

  @override
  State<DashboardPrototyper> createState() => _DashboardPrototyperState();
}

class _DashboardPrototyperState extends State<DashboardPrototyper> {
  int _currentIndex = 0;

  final List<String> _titles = ['Grid de Módulos', 'Cards Informativas', 'Timeline Diario'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex], style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildGridView(),
          _buildCardsView(),
          _buildTimelineView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Grid'),
          BottomNavigationBarItem(icon: Icon(Icons.view_agenda_outlined), label: 'Cards'),
          BottomNavigationBarItem(icon: Icon(Icons.timeline), label: 'Timeline'),
        ],
      ),
    );
  }

  // --- OPCIÓN 1: GRID DE MÓDULOS ---
  Widget _buildGridView() {
    final modules = [
      {'name': 'Finanzas', 'icon': Icons.account_balance_wallet, 'color': Colors.teal},
      {'name': 'Tareas', 'icon': Icons.checklist, 'color': Colors.amber},
      {'name': 'GitHub', 'icon': Icons.code, 'color': Colors.blue},
      {'name': 'Media', 'icon': Icons.movie_filter, 'color': Colors.redAccent},
      {'name': 'Casa', 'icon': Icons.home, 'color': Colors.purple},
      {'name': 'Trabajo', 'icon': Icons.business_center, 'color': Colors.orange},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.1,
      ),
      itemCount: modules.length,
      itemBuilder: (context, i) {
        final m = modules[i];
        return InkWell(
          onTap: () {},
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

  // --- OPCIÓN 2: CARDS INFORMATIVAS ---
  Widget _buildCardsView() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _infoCard('Finanzas', 'Balance: 1.250€', 'Nómina en 5 días', Icons.euro, Colors.teal),
        _infoCard('Próxima Tarea', 'Revisar motor de contexto', 'Prioridad Alta', Icons.task_alt, Colors.amber),
        _infoCard('GitHub', 'Vantage: 3 PRs abiertas', 'Último commit hace 2h', Icons.terminal, Colors.blue),
        _infoCard('Media', 'One Piece: Cap. 1090', 'Nuevo mañana', Icons.play_circle_outline, Colors.redAccent),
      ],
    );
  }

  Widget _infoCard(String title, String main, String sub, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // --- OPCIÓN 3: TIMELINE DIARIO ---
  Widget _buildTimelineView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _timelineItem('09:00', 'Entrada al Trabajo', 'Modo Trabajo activado', true),
        _timelineItem('11:30', 'Reunión Daily', 'Proyecto Vantage', false),
        _timelineItem('14:00', 'Comida', 'Modo Descanso', false),
        _timelineItem('18:30', 'Gimnasio', 'Modo Calle activado', false),
        _timelineItem('21:00', 'Ver Anime', 'Solo Leveling Cap. 12', false),
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
