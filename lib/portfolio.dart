import 'package:flutter/material.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StreetLight',
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xfff6f7fb),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
      ),

      home: HomePage(
        darkMode: darkMode,
        onThemeChanged: () {
          setState(() {
            darkMode = !darkMode;
          });
        },
      ),
    );
  }
}

// ============================================================
// HOME PAGE
// ============================================================

class HomePage extends StatelessWidget {
  final bool darkMode;
  final VoidCallback onThemeChanged;

  const HomePage({
    super.key,
    required this.darkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),

      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            _buildStats(context),
            _buildAbout(context),
            _buildFeatures(context),
            _buildWorkflow(context),
            _buildTimeline(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // APP BAR
  // ==========================================================

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,

      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.lightbulb,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 10),

          const Text(
            'StreetLight',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

      actions: [
        if (MediaQuery.of(context).size.width > 600) ...[
          _navButton('Home'),
          _navButton('About'),
          _navButton('Features'),
          _navButton('Progress'),
        ],

        IconButton(
          onPressed: onThemeChanged,
          tooltip: 'Change Theme',
          icon: Icon(
            darkMode ? Icons.light_mode : Icons.dark_mode,
          ),
        ),

        const SizedBox(width: 10),
      ],
    );
  }

  Widget _navButton(String title) {
    return TextButton(
      onPressed: () {},
      child: Text(title),
    );
  }

  // ==========================================================
  // HERO
  // ==========================================================

  Widget _buildHero(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 70,
      ),

      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1100,
          ),

          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 700) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heroText(context),
                    const SizedBox(height: 50),
                    _heroIllustration(context),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _heroText(context),
                  ),

                  const SizedBox(width: 40),

                  Expanded(
                    child: _heroIllustration(context),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _heroText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),

          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.1),

            borderRadius: BorderRadius.circular(30),
          ),

          child: Text(
            'SMART CITY PROJECT',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Making Streetlight\nComplaints Smarter.',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width < 700
                ? 38
                : 52,

            fontWeight: FontWeight.bold,

            height: 1.1,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'A digital platform for reporting, managing '
          'and tracking streetlight complaints efficiently.',
          style: TextStyle(
            fontSize: 18,
            height: 1.6,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.65),
          ),
        ),

        const SizedBox(height: 30),

        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Project details will be available soon.',
                    ),
                  ),
                );
              },
              child: const Text('View Project'),
            ),

            const SizedBox(width: 15),

            OutlinedButton(
              onPressed: () {},
              child: const Text('Learn More'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _heroIllustration(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 300,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),

          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,

            colors: [
              Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.18),

              Theme.of(context)
                  .colorScheme
                  .secondary
                  .withValues(alpha: 0.08),
            ],
          ),
        ),

        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 150,
              color: Theme.of(context).colorScheme.primary,
            ),

            Positioned(
              bottom: 35,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),

                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                  ],
                ),

                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 18,
                    ),

                    SizedBox(width: 7),

                    Text(
                      'Smart Reporting',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // STATISTICS
  // ==========================================================

  Widget _buildStats(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 20,
      ),

      padding: const EdgeInsets.all(25),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),

      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        runSpacing: 25,

        children: [
          _statItem(
            context,
            '01',
            'Project',
          ),

          _statItem(
            context,
            '04+',
            'Planned Features',
          ),

          _statItem(
            context,
            '24/7',
            'Complaint Access',
          ),

          _statItem(
            context,
            '∞',
            'Future Updates',
          ),
        ],
      ),
    );
  }

  Widget _statItem(
    BuildContext context,
    String number,
    String title,
  ) {
    return SizedBox(
      width: 160,

      child: Column(
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ABOUT
  // ==========================================================

  Widget _buildAbout(BuildContext context) {
    return _section(
      context,

      title: 'About the Project',

      subtitle:
          'Understanding the problem we are trying to solve.',

      child: Container(
        padding: const EdgeInsets.all(30),

        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),

        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return Column(
                children: [
                  _aboutIcon(context),
                  const SizedBox(height: 25),
                  _aboutText(context),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: _aboutIcon(context),
                ),

                const SizedBox(width: 40),

                Expanded(
                  flex: 2,
                  child: _aboutText(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _aboutIcon(BuildContext context) {
    return Container(
      width: 150,
      height: 150,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        color: Theme.of(context)
            .colorScheme
            .primary
            .withValues(alpha: 0.1),
      ),

      child: Icon(
        Icons.location_city,
        size: 75,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _aboutText(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          'The Problem',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 12),

        Text(
          'Damaged or non-working streetlights can create '
          'problems for people, especially during night time. '
          'Reporting these issues may not always be simple '
          'or properly tracked.',

          style: TextStyle(
            fontSize: 16,
            height: 1.6,
          ),
        ),

        SizedBox(height: 20),

        Text(
          'Our Goal',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 12),

        Text(
          'The project aims to provide a simple digital system '
          'where streetlight problems can be reported and '
          'their progress can be monitored.',
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // FEATURES
  // ==========================================================

  Widget _buildFeatures(BuildContext context) {
    final features = [
      [
        Icons.report_problem_outlined,
        'Report Issue',
        'Submit a complaint about a damaged or non-working streetlight.',
      ],
      [
        Icons.location_on_outlined,
        'Add Location',
        'Provide the location of the streetlight for easier identification.',
      ],
      [
        Icons.track_changes,
        'Track Complaint',
        'Monitor the current status of a submitted complaint.',
      ],
      [
        Icons.dashboard_outlined,
        'Management',
        'Provide a dashboard for managing reported complaints.',
      ],
      [
        Icons.notifications_none,
        'Notifications',
        'Receive updates about complaint progress.',
      ],
      [
        Icons.analytics_outlined,
        'Analytics',
        'View useful information about reported complaints.',
      ],
    ];

    return _section(
      context,

      title: 'Key Features',

      subtitle:
          'Features planned for the Streetlight Complaint System.',

      child: LayoutBuilder(
        builder: (context, constraints) {
          int columns = 1;

          if (constraints.maxWidth > 1000) {
            columns = 3;
          } else if (constraints.maxWidth > 600) {
            columns = 2;
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),

            itemCount: features.length,

            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.25,
            ),

            itemBuilder: (context, index) {
              return _featureCard(
                context,
                features[index][0] as IconData,
                features[index][1] as String,
                features[index][2] as String,
              );
            },
          );
        },
      ),
    );
  }

  Widget _featureCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(25),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outline
              .withValues(alpha: 0.15),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.1),

              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 30,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: Text(
              description,
              style: TextStyle(
                height: 1.4,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // WORKFLOW
  // ==========================================================

  Widget _buildWorkflow(BuildContext context) {
    final steps = [
      ['01', 'Report', Icons.edit_note],
      ['02', 'Review', Icons.manage_search],
      ['03', 'Assign', Icons.assignment],
      ['04', 'Resolve', Icons.check_circle_outline],
    ];

    return _section(
      context,

      title: 'Complaint Workflow',

      subtitle:
          'A simple process for handling streetlight complaints.',

      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 20,
        runSpacing: 30,

        children: steps.map((step) {
          return SizedBox(
            width: 180,

            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,

                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),

                  child: Icon(
                    step[2] as IconData,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  step[0] as String,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  step[1] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================================
  // DEVELOPMENT TIMELINE
  // ==========================================================

  Widget _buildTimeline(BuildContext context) {
    return _section(
      context,

      title: 'Development Progress',

      subtitle:
          'The project will be updated as development continues.',

      child: Column(
        children: [
          _timelineItem(
            context,
            '01',
            'Planning',
            'Project idea and requirements.',
            true,
          ),

          _timelineItem(
            context,
            '02',
            'UI Development',
            'Building the Flutter interface.',
            true,
          ),

          _timelineItem(
            context,
            '03',
            'Complaint Module',
            'Developing complaint submission and tracking.',
            false,
          ),

          _timelineItem(
            context,
            '04',
            'Backend Integration',
            'Connecting the application with the backend.',
            false,
          ),

          _timelineItem(
            context,
            '05',
            'Testing',
            'Testing and improving the complete system.',
            false,
          ),
        ],
      ),
    );
  }

  Widget _timelineItem(
    BuildContext context,
    String number,
    String title,
    String description,
    bool completed,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),

      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: completed
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.15),

            child: Text(
              number,
              style: TextStyle(
                color: completed
                    ? Colors.white
                    : Theme.of(context)
                        .colorScheme
                        .onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          Icon(
            completed
                ? Icons.check_circle
                : Icons.radio_button_unchecked,

            color: completed
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SECTION
  // ==========================================================

  Widget _section(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 60,
      ),

      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1100,
          ),

          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                subtitle,
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),

              const SizedBox(height: 35),

              child,
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // FOOTER
  // ==========================================================

  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(
        vertical: 35,
        horizontal: 20,
      ),

      child: Column(
        children: [
          Icon(
            Icons.lightbulb,
            size: 35,
            color: Theme.of(context).colorScheme.primary,
          ),

          const SizedBox(height: 10),

          const Text(
            'StreetLight Complaint System',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Project Portfolio • 2026',
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
          ),

          const SizedBox(height: 15),

          Text(
            'Currently under development',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}