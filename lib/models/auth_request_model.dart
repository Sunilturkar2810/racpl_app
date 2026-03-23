class LoginRequest {
  final String workEmail;
  final String password;

  LoginRequest({required this.workEmail, required this.password});

  Map<String, dynamic> toJson() => {
    'Work_Email': workEmail,
    'Password': password,
  };
}

class SignupRequest {
  final String firstName;
  final String lastName;
  final String workEmail;
  final String password;
  final String role;
  final String designation;
  final String department;
  final String joiningDate;

  SignupRequest({
    required this.firstName,
    required this.lastName,
    required this.workEmail,
    required this.password,
    required this.role,
    required this.designation,
    required this.department,
    required this.joiningDate,
  });

  Map<String, dynamic> toJson() => {
    'First_Name': firstName,
    'Last_Name': lastName,
    'Work_Email': workEmail,
    'Password': password,
    'Role': role,
    'Designation': designation,
    'Department': department,
    'Joining_Date': joiningDate,
  };
}
