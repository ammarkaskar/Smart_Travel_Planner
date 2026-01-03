class Place {
  final String id;
  final String name;
  final String? description;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final String? category;
  final double? rating;
  final String? address;

  Place({
    required this.id,
    required this.name,
    this.description,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.category,
    this.rating,
    this.address,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'] ?? json;
    final geometry = json['geometry'] ?? {};
    final coordinates = geometry['coordinates'] ?? [];

    return Place(
      id: json['xid'] ?? json['id'] ?? '',
      name: properties['name'] ?? 'Unknown Place',
      description: properties['wikipedia_extracts']?['text'] ?? 
                   properties['description'] ?? 
                   properties['kinds']?.split(',').first ?? '',
      latitude: coordinates.isNotEmpty ? coordinates[1].toDouble() : null,
      longitude: coordinates.isNotEmpty ? coordinates[0].toDouble() : null,
      category: properties['kinds']?.split(',').first ?? '',
      rating: properties['rate']?.toDouble(),
      address: properties['address'] ?? properties['formatted'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'address': address,
    };
  }

  // Create a copy of this place with updated fields
  Place copyWith({
    String? id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    String? imageUrl,
    String? category,
    double? rating,
    String? address,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      address: address ?? this.address,
    );
  }
}

