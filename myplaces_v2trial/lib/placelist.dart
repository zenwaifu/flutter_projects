class Place {
  int? id;
  String? name;
  String? state;
  String? category;
  String? description;
  String? imageUrl;
  double? latitude;
  double? longitude;
  String? contact;
  double? rating;

  Place({
     this.id,
     this.name,
     this.state,
     this.category,
     this.description,
     this.imageUrl,
     this.latitude,
     this.longitude,
     this.contact,
     this.rating,
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
      contact: json['contact'] ?? 'NA',
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'state': state,
      'category': category,
      'description': description,
      'image_url': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'contact': contact,
      'rating': rating,
    };
  }
}