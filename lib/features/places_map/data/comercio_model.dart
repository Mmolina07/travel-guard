class Comercio {
  final String nombre;
  final String direccion;
  final String telefono;
  final double calificacion;
  final String horario;

  Comercio({
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.calificacion,
    required this.horario,
  });

  factory Comercio.fromJson(Map<String, dynamic> json) {
    return Comercio(
      nombre: json['nombre'] ?? '',
      direccion: json['direccion'] ?? '',
      telefono: json['telefono'] ?? '',
      calificacion: (json['calificacion'] ?? 0.0).toDouble(),
      horario: json['horario'] ?? '',
    );
  }
}