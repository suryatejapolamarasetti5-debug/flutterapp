import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'animations.dart';
import 'theme.dart';
import 'complaints_tab.dart';
import 'complaint_api_page.dart';
import 'complaint_form.dart';
import 'profile_edit_page.dart';
import 'nearby_issues_page.dart';
import 'electrical_offices_page.dart';

class AppShell extends StatefulWidget {
  final VoidCallback? onLoggedOut;

  const AppShell({super.key, this.onLoggedOut});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final GlobalKey<ComplaintsTabState> _complaintsKey =
      GlobalKey<ComplaintsTabState>();

  void _switchTo(int index) {
    setState(() {
      _index = index;
    });
  }

  void _handleLogout() {
    AuthService.logout();
    _complaintsKey.currentState?.reload();

    widget.onLoggedOut?.call();
  }

  void _handleProfileEdited() {
    _complaintsKey.currentState?.reload();

    if (!mounted) return;

    setState(() {});
  }

  void _handleComplaintSubmitted() {
    _complaintsKey.currentState?.reload();

    if (!mounted) return;

    setState(() {
      _index = 0;
    });
  }

  void _handleNotLoggedIn() {
    AuthService.logout();
    _complaintsKey.currentState?.reload();

    widget.onLoggedOut?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps every tab alive, so each tab is wrapped in a
      // TickerMode: only the visible tab runs its ambient animations.
      body: FadeSlideIn(
        duration: const Duration(milliseconds: 260),
        slide: const Offset(0, 0.02),
        replayKey: _index,
        child: IndexedStack(
          index: _index,
          children: <Widget>[
            TickerMode(
              enabled: _index == 0,
              child: ComplaintsTab(key: _complaintsKey),
            ),
            TickerMode(
              enabled: _index == 1,
              child: const ComplaintApiPage(),
            ),
            TickerMode(
              enabled: _index == 2,
              child: const NearbyIssuesPage(),
            ),
            TickerMode(
              enabled: _index == 3,
              child: const ElectricalOfficesPage(),
            ),
            TickerMode(
              enabled: _index == 4,
              child: ComplaintForm(
                onComplaintSubmitted: _handleComplaintSubmitted,
                onNotLoggedIn: _handleNotLoggedIn,
              ),
            ),
            TickerMode(
              enabled: _index == 5,
              child: _ProfileView(
                onLogout: _handleLogout,
                onProfileEdited: _handleProfileEdited,
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _switchTo,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Complaints',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_outlined),
            selectedIcon: Icon(Icons.cloud),
            label: 'API',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Nearby',
          ),
          NavigationDestination(
            icon: Icon(Icons.contact_phone_outlined),
            selectedIcon: Icon(Icons.contact_phone),
            label: 'Contacts',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Report',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(Icons.account_circle),
            label: 'Profile',
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
  final VoidCallback onProfileEdited;

  const _ProfileView({
    required this.onLogout,
    required this.onProfileEdited,
  });

  Future<void> _openEditProfile(BuildContext context) async {
    final edited = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const ProfileEditPage(),
      ),
    );

    if (edited == true) {
      onProfileEdited();
    }
  }

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
            child: FadeSlideIn(
              duration: const Duration(milliseconds: 380),
              slide: const Offset(0, 0.05),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: buildStaggeredChildren(
                      <Widget>[
                        Center(
                          child: LightPulse(
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
                                  isAdmin
                                      ? 'Administrator'
                                      : 'Citizen',
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

                        PressScale(
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () => _openEditProfile(context),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        PressScale(
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton.icon(
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
                        ),
                      ],
                      interval: const Duration(milliseconds: 60),
                      duration: const Duration(milliseconds: 340),
                      maxTotalDelay: const Duration(milliseconds: 460),
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