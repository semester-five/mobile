class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.avatarId,
    this.picture,
    this.gender,
    this.birthday,
    this.phoneNumber,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? avatarId;
  final String? picture;
  final String? gender;
  final String? birthday;
  final String? phoneNumber;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      role: json['role'] as String? ?? 'USER',
      avatarId: json['avatarId'] as String?,
      picture: json['picture'] as String?,
      gender: json['gender'] as String?,
      birthday: json['birthday'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  bool get isAdmin => role.toUpperCase() == 'ADMIN';
  bool get isUser => role.toUpperCase() == 'USER';

  // Derived getter, not stored in JSON.
  String get fullName {
    return '$firstName $lastName'.trim();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'avatarId': avatarId,
      'picture': picture,
      'gender': gender,
      'birthday': birthday,
      'phoneNumber': phoneNumber,
    };
  }
}
