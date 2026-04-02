class RegisterFormDto {
  const RegisterFormDto({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.birthday,
    required this.phoneNumber,
    required this.password,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final String birthday;
  final String phoneNumber;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'gender': gender,
      'birthday': birthday,
      'phoneNumber': phoneNumber,
      'password': password,
    };
  }
}
