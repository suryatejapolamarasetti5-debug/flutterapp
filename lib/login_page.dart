import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'database_helper.dart';
import 'register_page.dart';
import 'complaint_home.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool rememberMe = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

Future<void> _login() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  try {
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;

    final user = await DatabaseHelper.instance.getUser(
      email,
      password,
    );

    if (user != null) {
      AuthService.setLoggedInUser(user);

      if (!mounted) return;

      Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => ComplaintHome(
      userRole: user['role'] ?? 'user',
    ),
  ),
      );
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email or password'),
        ),
      );
    }
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Login failed: $e'),
      ),
    );
  }
}
  void _openRegisterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // =========================
                        // LOGO
                        // =========================
                        Center(
                          child: CircleAvatar(
                            radius: 42,
                            backgroundColor: colorScheme.primary,
                            child: const Icon(
                              Icons.lightbulb,
                              color: Colors.white,
                              size: 45,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // =========================
                        // TITLE
                        // =========================
                        Center(
                          child: Text(
                            'StreetLight',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Center(
                          child: Text(
                            'Complaint Management System',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ),

                        const SizedBox(height: 35),

                        // =========================
                        // WELCOME
                        // =========================
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Login to continue to your account.',
                          style: TextStyle(
                            color: colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // =========================
                        // EMAIL
                        // =========================
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email address',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter your email';
                            }

                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // =========================
                        // PASSWORD
                        // =========================
                        TextFormField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(Icons.lock_outline),
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
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }

                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // =========================
                        // REMEMBER ME
                        // =========================
                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  rememberMe = value ?? false;
                                });
                              },
                            ),

                            const Text('Remember me'),

                            const Spacer(),

                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Password recovery will be added later.',
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Forgot Password?',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // =========================
                        // LOGIN BUTTON
                        // =========================
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _login,
                            icon: const Icon(Icons.login),
                            label: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // =========================
                        // REGISTER LINK
                        // =========================
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),

                            TextButton(
                              onPressed: _openRegisterPage,
                              child: const Text('Register'),
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