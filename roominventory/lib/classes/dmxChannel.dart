class DMXChannel {
  final int id;
  final String position;
  final String type;
  String state;
  final String connections;

  DMXChannel(this.id, this.position, this.type, this.state, this.connections);

  factory DMXChannel.fromJson(Map<String, dynamic> json) {
    // Usa as chaves que a API realmente devolve (minúsculas)
    final idRaw = json['idchannel'];
    final id =
        idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? '') ?? 0;

    return DMXChannel(
      id,
      json['position']?.toString() ?? '',
      json['type']?.toString() ?? 'fixture',
      json['state']?.toString() ?? 'disconnected',
      json['connections']?.toString() ?? '',
    );
  }
}
