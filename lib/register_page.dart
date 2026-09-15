import 'package:flutter/material.dart';
import 'database_helper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

Future<void> _register() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  try {
    final existingUser =
        await DatabaseHelper.instance.getUserByEmail(
      emailController.text.trim().toLowerCase(),
    );

    if (existingUser != null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email is already registered'),
        ),
      );
      return;
    }

    await DatabaseHelper.instance.insertUser(
      nameController.text.trim(),
      emailController.text.trim().toLowerCase(),
      passwordController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registration successful!'),
      ),
    );

    Navigator.pop(context);
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registration failed: $e'),
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor:
                                colorScheme.primary,
                            child: const Icon(
                              Icons.person_add_alt_1,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Center(
                          child: Text(
                            'Join StreetLight',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Center(
                          child: Text(
                            'Create an account to report and track '
                            'streetlight complaints.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // NAME
                        TextFormField(
                          controller: nameController,
                          textCapitalization:
                              TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            hintText: 'Enter your full name',
                            prefixIcon:
                                Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter your name';
                            }

                            if (value.trim().length < 3) {
                              return 'Name must be at least 3 characters';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // EMAIL
                        TextFormField(
                          controller: emailController,
                          keyboardType:
                              TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText:
                                'Enter your email address',
                            prefixIcon:
                                Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter your email';
                            }

                            if (!value.contains('@') ||
                                !value.contains('.')) {
                              return 'Please enter a valid email';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // PASSWORD
                        TextFormField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Create a password',
                            prefixIcon:
                                const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscurePassword =
                                      !obscurePassword;
                                });
                              },
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons
                                        .visibility_off_outlined,
                              ),
                            ),
                            border:
                                const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return 'Please enter a password';
                            }

                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // CONFIRM PASSWORD
                        TextFormField(
                          controller:
                              confirmPasswordController,
                          obscureText:
                              obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            hintText:
                                'Re-enter your password',
                            prefixIcon: const Icon(
                              Icons.lock_reset_outlined,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscureConfirmPassword =
                                      !obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons
                                        .visibility_off_outlined,
                              ),
                            ),
                            border:
                                const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return 'Please confirm your password';
                            }

                            if (value !=
                                passwordController.text) {
                              return 'Passwords do not match';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 30),

                        // REGISTER BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _register,
                            icon: const Icon(
                              Icons.person_add,
                            ),
                            label: const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // BACK TO LOGIN
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account?',
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Login',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}