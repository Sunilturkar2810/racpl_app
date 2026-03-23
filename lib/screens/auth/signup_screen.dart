import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/error_dialog.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _designationController = TextEditingController();
  final _joiningDateController = TextEditingController();

  String _selectedRole = AppConstants.roleEmployee;
  String _selectedDepartment = AppConstants.defaultDepartment;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _designationController.dispose();
    _joiningDateController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _joiningDateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.signup(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
      designation: _designationController.text.trim(),
      department: _selectedDepartment,
      joiningDate: _joiningDateController.text,
    );

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Account created successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to login
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(
          message: authProvider.error?.message ?? 'Signup failed',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First Name
                CustomTextField(
                  label: 'First Name',
                  hint: 'Enter first name',
                  controller: _firstNameController,
                  validator: AppValidators.validateName,
                  prefixIcon: const Icon(Icons.person_outlined),
                ),
                const SizedBox(height: 20),

                // Last Name
                CustomTextField(
                  label: 'Last Name',
                  hint: 'Enter last name',
                  controller: _lastNameController,
                  validator: AppValidators.validateName,
                  prefixIcon: const Icon(Icons.person_outlined),
                ),
                const SizedBox(height: 20),

                // Email
                CustomTextField(
                  label: 'Work Email',
                  hint: 'Enter your work email',
                  controller: _emailController,
                  validator: AppValidators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: 20),

                // Password
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter password (min 6 chars)',
                  controller: _passwordController,
                  validator: AppValidators.validatePassword,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outlined),
                ),
                const SizedBox(height: 20),

                // Confirm Password
                CustomTextField(
                  label: 'Confirm Password',
                  hint: 'Re-enter password',
                  controller: _confirmPasswordController,
                  validator: _validateConfirmPassword,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outlined),
                ),
                const SizedBox(height: 20),

                // Role
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Role',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      items:
                          [AppConstants.roleEmployee, AppConstants.roleManager]
                              .map(
                                (role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value ?? AppConstants.roleEmployee;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Department
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Department',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      items:
                          [
                                AppConstants.defaultDepartment,
                                'HR',
                                'Finance',
                                'Sales',
                              ]
                              .map(
                                (dept) => DropdownMenuItem(
                                  value: dept,
                                  child: Text(dept),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartment =
                              value ?? AppConstants.defaultDepartment;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Designation
                CustomTextField(
                  label: 'Designation',
                  hint: 'e.g. Software Engineer',
                  controller: _designationController,
                  validator: AppValidators.validateName,
                  prefixIcon: const Icon(Icons.work_outlined),
                ),
                const SizedBox(height: 20),

                // Joining Date
                GestureDetector(
                  onTap: _selectDate,
                  child: AbsorbPointer(
                    child: CustomTextField(
                      label: 'Joining Date',
                      hint: 'Select joining date',
                      controller: _joiningDateController,
                      validator: AppValidators.validateDate,
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Signup Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return CustomButton(
                      label: 'Sign Up',
                      isLoading: authProvider.isLoading,
                      onPressed: _handleSignup,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
