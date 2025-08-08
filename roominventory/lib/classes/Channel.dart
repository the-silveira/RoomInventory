class Channel {
  final int id;
  final String position;
  final String type;
  final String state;
  final String connections;

  Channel({
    required this.id,
    required this.position,
    required this.type,
    required this.state,
    required this.connections,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: int.parse(json['IdChannel'].toString()), // Ensure int
      position: json['Position'].toString(),
      type: json['Type'].toString(),
      state: json['State'].toString(),
      connections: json['Connections']?.toString() ?? '',
    );
  }
}
