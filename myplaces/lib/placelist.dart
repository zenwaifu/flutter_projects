class Place {
  int id;
  String name;
  String state;
  String category;
  String description;
  String imageUrl;
  double latitude;
  double longitude;
  String contact;
double rating;

  Place({
    required this.id,
    required this.name,
    required this.state,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.contact,
    required this.rating,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? 'NA',
      state: json['state'] ?? 'NA',
      category: json['category'] ?? 'NA',
      description: json['description'] ?? 'NA',
      imageUrl: json['image_url'] ?? 'NA',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      contact: json['contact'] ?? 'N/A',
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
    );
  }
}
