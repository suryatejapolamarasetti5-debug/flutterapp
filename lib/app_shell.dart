import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'animations.dart';
import 'theme.dart';
import 'complaints_tab.dart';
import 'complaint_form.dart';
import 'login_page.dart';
import 'nearby_issues_page.dart';
import 'electrical_offices_page.dart';
import 'register_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final GlobalKey<ComplaintsTabState> _complaintsKey =
      GlobalKey<ComplaintsTabState>();

  bool get _loggedIn => AuthService.currentUser != null;

  void _switchTo(int index) {
    setState(() {
      _index = index;
    });
  }

  void _handleLoginSuccess() {
    _complaintsKey.currentState?.reload();

    if (!mounted) return;

    setState(() {
      _index = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login successful')),
    );
  }

  void _handleRegistered() {
    if (!mounted) return;

    setState(() {
      _index = 5;
    });
  }

  void _handleLogout() {
    AuthService.logout();
    _complaintsKey.currentState?.reload();

    setState(() {
      _index = 4;
    });
  }

  void _handleComplaintSubmitted() {
    _complaintsKey.currentState?.reload();

    if (!mounted) return;

    setState(() {
      _index = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          ComplaintsTab(key: _complaintsKey),
          const NearbyIssuesPage(),
          const ElectricalOfficesPage(),
          ComplaintForm(
            onComplaintSubmitted: _handleComplaintSubmitted,
            onNotLoggedIn: () => _switchTo(4),
          ),
          _loggedIn
              ? _ProfileView(onLogout: _handleLogout)
              : LoginPage(
                  onLoginSuccess: _handleLoginSuccess,
                  onRegisterTap: () => _switchTo(5),
                ),
          _loggedIn
              ? _AlreadyLoggedInView(onGoToProfile: () => _switchTo(4))
              : RegisterPage(
                  onRegistered: _handleRegistered,
                  onLoginTap: () => _switchTo(4),
                ),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _switchTo,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Complaints',
          ),
          const NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Nearby',
          ),
          const NavigationDestination(
            icon: Icon(Icons.contact_phone_outlined),
            selectedIcon: Icon(Icons.contact_phone),
            label: 'Contacts',
          ),
          const NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Report',
          ),
          NavigationDestination(
            icon: Icon(_loggedIn ? Icons.account_circle_outlined : Icons.login),
            selectedIcon: Icon(_loggedIn ? Icons.account_circle : Icons.login),
            label: _loggedIn ? 'Profile' : 'Login',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_add_alt_1),
            selectedIcon: Icon(Icons.person_add_alt_1),
            label: 'Register',
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PROFILE VIEW (shown on the Login tab when logged in)
// ═══════════════════════════════════════════════════════════════

class _ProfileView extends StatelessWidget {
  final VoidCallback onLogout;

  const _ProfileView({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = AuthService.currentUserName ?? 'User';
    final email = AuthService.currentUserEmail ?? '';
    final role =
        AuthService.currentUser?['role']?.toString() ?? 'user';
    final isAdmin = role == 'admin';

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GlowPulse(
                        borderRadius: BorderRadius.circular(50),
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: colorScheme.primary,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 45,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Center(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Center(
                      child: Text(
                        email,
                        style: TextStyle(
                          color: colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BlinkingDot(
                            color: isAdmin
                                ? AppThemes.statusResolved
                                : AppThemes.statusInProgress,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: (isAdmin
                                      ? AppThemes.statusResolved
                                      : AppThemes.statusInProgress)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isAdmin ? 'Administrator' : 'Citizen',
                              style: TextStyle(
                                color: isAdmin
                                    ? AppThemes.statusResolved
                                    : AppThemes.statusInProgress,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: onLogout,
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ALREADY LOGGED IN VIEW (shown on the Register tab when logged in)
// ═══════════════════════════════════════════════════════════════

class _AlreadyLoggedInView extends StatelessWidget {
  final VoidCallback onGoToProfile;

  const _AlreadyLoggedInView({required this.onGoToProfile});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    BlinkingHalo(
                      color: colorScheme.primary,
                      size: 70,
                      rings: 2,
                      child: Icon(
                        Icons.check_circle,
                        size: 46,
                        color: AppThemes.statusResolved,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'You are already logged in',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Use the Profile tab to manage your account '
                      'or logout.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: onGoToProfile,
                        icon: const Icon(Icons.person),
                        label: const Text(
                          'Go to Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}