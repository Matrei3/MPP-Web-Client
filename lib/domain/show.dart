import 'artist.dart';

class Show {
  final int id;
  final Artist artist;
  final String location;
  final DateTime showDate;
  final int availableSeats;
  final int soldSeats;

  Show({required this.id,
    required this.artist,
    required this.location,
    required this.showDate,
    required this.availableSeats,
    required this.soldSeats});

  factory Show.fromJson(Map<String, dynamic> json){
    return Show(
      id: json['id'],
      artist: Artist.fromJson(json['artist']),
      location: json['location'],
      showDate: DateTime.parse(json['showDate']),
      availableSeats: json['availableSeats'],
      soldSeats: json['soldSeats'],
    );
  }
  static List<Show> listFromJson(List<dynamic> json) {
    return json.map((e) => Show.fromJson(e)).toList();
  }
  @override
  String toString() {
    return 'Show{id: $id, artist: $artist, location: $location, showDate: $showDate, availableSeats: $availableSeats, soldSeats: $soldSeats}';
  }
}
