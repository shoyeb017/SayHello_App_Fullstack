/// Model class for Learner data from Supabase
/// Handles learner profile information and followers relationship

class Learner {
  final String id;
  final String? profileImage;
  final String name;
  final String email;
  final String username;
  final String password;
  final DateTime dateOfBirth;
  final String gender; // 'male' or 'female'
  final String country; // 'usa', 'spain', 'japan', 'korea', 'bangladesh'
  final String? bio;
  final String
  nativeLanguage; // 'english', 'spanish', 'japanese', 'korean', 'bangla'
  final String
  learningLanguage; // 'english', 'spanish', 'japanese', 'korean', 'bangla'
  final String
  languageLevel; // 'beginner', 'elementary', 'intermediate', 'advanced', 'proficient'
  final List<String> interests;
  final DateTime createdAt;

  const Learner({
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
    required this.learningLanguage,
    required this.languageLevel,
    required this.interests,
    required this.createdAt,
  });

  /// Create Learner from JSON (Supabase response)
  factory Learner.fromJson(Map<String, dynamic> json) {
    return Learner(
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
      learningLanguage: json['learning_language'] as String,
      languageLevel: json['language_level'] as String,
      interests: List<String>.from(json['interests'] as List),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert Learner to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_image': profileImage,
      'name': name,
      'email': email,
      'username': username,
      'password': password, // <-- Add this lin
      'date_of_birth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'country': country,
      'bio': bio,
      'native_language': nativeLanguage,
      'learning_language': learningLanguage,
      'language_level': languageLevel,
      'interests': interests,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  Learner copyWith({
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
    String? learningLanguage,
    String? languageLevel,
    List<String>? interests,
    DateTime? createdAt,
  }) {
    return Learner(
      id: id ?? this.id,
      profileImage: profileImage ?? this.profileImage,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      bio: bio ?? this.bio,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      learningLanguage: learningLanguage ?? this.learningLanguage,
      languageLevel: languageLevel ?? this.languageLevel,
      interests: interests ?? this.interests,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Learner(id: $id, name: $name, email: $email, username: $username)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Learner && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Model class for Follower relationship between learners
class Follower {
  final String id;
  final String followerUserId; // learner ID who is following
  final String followedUserId; // learner ID who is being followed
  final DateTime createdAt;

  const Follower({
    required this.id,
    required this.followerUserId,
    required this.followedUserId,
    required this.createdAt,
  });

  /// Create Follower from JSON
  factory Follower.fromJson(Map<String, dynamic> json) {
    return Follower(
      id: json['id'] as String,
      followerUserId: json['follower_user_id'] as String,
      followedUserId: json['followed_user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert Follower to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'follower_user_id': followerUserId,
      'followed_user_id': followedUserId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Follower(id: $id, follower: $followerUserId, followed: $followedUserId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Follower && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
