class Artist {
  final int id;
  final String name;

  Artist({required this.id, required this.name});
  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'],
      name: json['name'],
    );
  }
  static List<Artist> listFromJson(List<dynamic> json) {
    return json.map((e) => Artist.fromJson(e)).toList();
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'Artist{id: $id, name: $name}';
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Artist &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

}
