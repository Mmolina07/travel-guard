/// HU-16: un colaborador invitado a un viaje (fila de
/// `viaje_colaboradores`, join con `usuarios`/`turistas` para mostrar su
/// nombre y correo). El dueño del viaje NO aparece en esta lista — se
/// identifica por separado con `Trip.turistaId`.
class TripCollaborator {
  final int usuarioId;
  final String email;
  final String nombreCompleto;
  final DateTime? createdAt;

  const TripCollaborator({
    required this.usuarioId,
    required this.email,
    required this.nombreCompleto,
    this.createdAt,
  });

  factory TripCollaborator.fromRow(Map<String, dynamic> row) {
    final usuario = row['usuarios'] as Map<String, dynamic>?;
    final turista = row['turistas'] as Map<String, dynamic>?;
    final nombre = turista?['nombre'] as String?;
    final apellido = turista?['apellido'] as String?;
    final nombreCompleto = [
      nombre,
      apellido,
    ].where((s) => s != null && s.isNotEmpty).join(' ');

    return TripCollaborator(
      usuarioId: row['usuario_id'] as int,
      email: usuario?['email'] as String? ?? '',
      nombreCompleto: nombreCompleto.isNotEmpty ? nombreCompleto : (usuario?['email'] as String? ?? 'Colaborador'),
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? ''),
    );
  }
}
