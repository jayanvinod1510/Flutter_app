class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String imageUrl;
  final String availability;
  final double rating;
  final String qualification;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.imageUrl,
    required this.availability,
    required this.rating,
    required this.qualification,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['name'] ?? '',
      name: json['doctor_name'] ?? json['name'] ?? '',
      specialization: json['specialization'] ?? '',
      imageUrl: json['image'] ?? '',
      availability: json['availability'] ?? 'Available',
      rating: (json['rating'] ?? 0.0).toDouble(),
      qualification: json['qualification'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': id,
      'doctor_name': name,
      'specialization': specialization,
      'image': imageUrl,
      'availability': availability,
      'rating': rating,
      'qualification': qualification,
    };
  }
}
