class ContextActionMode {
  final String id;
  final String name;
  final String description;
  final bool autoSwitch; // ¿Cambia el entorno solo?
  final bool showBanner; // ¿Muestra el aviso tipo "toast"?

  ContextActionMode({
    required this.id,
    required this.name,
    required this.description,
    required this.autoSwitch,
    required this.showBanner,
  });
}
