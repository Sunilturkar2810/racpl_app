class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? designation;
  final String? department;
  final String? profilePhotoUrl;
  final String theme;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.designation,
    this.department,
    this.profilePhotoUrl,
    this.theme = 'light',
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    // Helper to convert id (can be String or int from backend)
    int userId = 0;
    final idValue = json['id'];
    if (idValue is String) {
      userId = int.tryParse(idValue) ?? 0;
    } else if (idValue is int) {
      userId = idValue;
    }

    return User(
      id: userId,
      email: json['email'] ?? json['Work_Email'] ?? '',
      firstName: json['first_name'] ?? json['First_Name'] ?? '',
      lastName: json['last_name'] ?? json['Last_Name'] ?? '',
      role: json['role'] ?? 'Employee',
      designation: json['designation'],
      department: json['department'],
      profilePhotoUrl: json['profile_photo_url'],
      theme: json['theme'] ?? 'light',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'role': role,
    'designation': designation,
    'department': department,
    'profile_photo_url': profilePhotoUrl,
    'theme': theme,
  };

  User copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    String? designation,
    String? department,
    String? profilePhotoUrl,
    String? theme,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      theme: theme ?? this.theme,
    );
  }
}
