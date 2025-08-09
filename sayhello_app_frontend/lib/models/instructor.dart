/// Model class for Instructor data from Supabase
/// Handles instructor profile information for course creators

class Instructor {
  final String id;
  final String? profileImage;
  final String name;
  final String email;
  final String username;
  final DateTime dateOfBirth;
  final String password; // Required for authentication
  final String gender; // 'male' or 'female'
  final String country; // 'usa', 'spain', 'japan', 'korea', 'bangladesh'
  final String? bio;
  final String
  nativeLanguage; // 'english', 'spanish', 'japanese', 'korean', 'bangla'
  final String
  teachingLanguage; // 'english', 'spanish', 'japanese', 'korean', 'bangla'
  final int yearsOfExperience;
  final DateTime createdAt;

  const Instructor({
    required this.id,
    this.profileImage,
    required this.name,
    required this.email,
    required this.username,
    required this.password,
    required this.dateOfBirth,
    required this.gender,
    required this.country,
    this.bio,
    required this.nativeLanguage,
    required this.teachingLanguage,
    required this.yearsOfExperience,
    required this.createdAt,
  });

  /// Create Instructor from JSON (Supabase response)
  factory Instructor.fromJson(Map<String, dynamic> json) {
    return Instructor(
      id: json['id'] as String,
      profileImage: json['profile_image'] as String?,
      name: json['name'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      dateOfBirth: DateTime.parse(json['date_of_birth'] as String),
      gender: json['gender'] as String,
      country: json['country'] as String,
      bio: json['bio'] as String?,
      nativeLanguage: json['native_language'] as String,
      teachingLanguage: json['teaching_language'] as String,
      yearsOfExperience: json['years_of_experience'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert Instructor to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_image': profileImage,
      'name': name,
      'email': email,
      'username': username,
      'password': password,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'country': country,
      'bio': bio,
      'native_language': nativeLanguage,
      'teaching_language': teachingLanguage,
      'years_of_experience': yearsOfExperience,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  Instructor copyWith({
    String? id,
    String? profileImage,
    String? name,
    String? email,
    String? username,
    DateTime? dateOfBirth,
    String? gender,
    String? country,
    String? bio,
    String? nativeLanguage,
    String? teachingLanguage,
    int? yearsOfExperience,
    DateTime? createdAt,
  }) {
    return Instructor(
      id: id ?? this.id,
      profileImage: profileImage ?? this.profileImage,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      password: this.password,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      bio: bio ?? this.bio,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      teachingLanguage: teachingLanguage ?? this.teachingLanguage,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Instructor(id: $id, name: $name, email: $email, experience: ${yearsOfExperience}y)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Instructor && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
