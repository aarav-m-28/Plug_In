import 'package:app/screens/announcements_screen.dart';
import 'package:flutter/material.dart';
// NOTE: Lottie import removed as we are replacing assets with Icons
// import 'package:lottie/lottie.dart'; 
import 'package:app/screens/settings_screen.dart';
import 'attendance_screen.dart'; // Assuming these exist
import 'events_screen.dart'; // Assuming these exist
import 'members_screen.dart'; // Assuming these exist
import 'login_screen.dart'; // Assuming these exist
import 'collaboration_screen.dart'; // Assuming these exist

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Helper method to build a dashboard item card
  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    Widget icon,
    String subtitle,
    VoidCallback onTap,
    Color color,
  ) {
    final theme = Theme.of(context);

    // Choose text color based on the card's background color lightness
    final isDark = color.computeLuminance() < 0.5;
    final textColor = isDark ? const Color.fromARGB(255, 0, 0, 0) : Colors.black87;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: color,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: icon,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create a dashboard icon
  Widget _buildDashboardIcon(IconData iconData, Color color, double size) {
    return Icon(iconData, size: size, color: color);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const double iconSizeLarge = 40.0;
    const double iconSizeSmall = 30.0;

    // Define the card data using static Icons
    final List<Map<String, dynamic>> dashboardItems = [
      {
        'title': 'Attendance',
        'icon': _buildDashboardIcon(Icons.checklist_rtl, Colors.white, iconSizeLarge),
        'drawerIcon': _buildDashboardIcon(Icons.checklist_rtl, Colors.black87, iconSizeSmall),
        'subtitle': 'View & mark attendance logs',
        'destination': const AttendanceScreen(),
        'color': const Color.fromARGB(255, 168, 8, 40),
      },
      {
        'title': 'Events',
        'icon': _buildDashboardIcon(Icons.event_note, Colors.white, iconSizeLarge),
        'drawerIcon': _buildDashboardIcon(Icons.event_note, Colors.black87, iconSizeSmall),
        'subtitle': 'Manage and view club events',
        'destination': const EventsScreen(),
        'color': const Color.fromARGB(255, 5, 124, 96),
      },
      {
        'title': 'Collaboration',
        'icon': _buildDashboardIcon(Icons.palette, Colors.white, iconSizeLarge),
        'drawerIcon': _buildDashboardIcon(Icons.palette, Colors.black87, iconSizeSmall),
        'subtitle': 'Access mindmaps and timelines',
        'destination': const CollaborationScreen(),
        'color': Colors.indigo[400],
      },
      {
        'title': 'Announcements',
        'icon': _buildDashboardIcon(Icons.campaign, Colors.white, iconSizeLarge),
        'drawerIcon': _buildDashboardIcon(Icons.campaign, Colors.black87, iconSizeSmall),
        'subtitle': 'Read the latest club news',
        'destination': const AnnouncementsScreen(),
        'color': Colors.green[600],
      },
      {
        'title': 'Members',
        'icon': _buildDashboardIcon(Icons.groups, Colors.white, iconSizeLarge),
        'drawerIcon': _buildDashboardIcon(Icons.groups, Colors.black87, iconSizeSmall),
        'subtitle': 'Directory of all club members',
        'destination': const MembersScreen(),
        'color': Colors.orange[600],
      },
      {
        'title': 'Settings',
        'icon': _buildDashboardIcon(Icons.settings_outlined, Colors.white, iconSizeLarge),
        'drawerIcon': _buildDashboardIcon(Icons.settings_outlined, Colors.black87, iconSizeSmall),
        'subtitle': 'App and profile settings',
        'destination': const SettingsScreen(),
        'color': Colors.blueGrey[700],
      },
    ];

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: colorScheme.primary),
              child: Text('Navigation', style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white)),
            ),
            // Home option to navigate back to the Dashboard
            ListTile(
              leading: const Icon(Icons.home, color: Colors.black87),
              title: const Text('Home'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
              },
            ),
            const Divider(),
            // Navigation to main sections from the Drawer
            ...dashboardItems.map((item) {
              return ListTile(
                leading: SizedBox(width: 30, height: 30, child: item['drawerIcon'] as Widget),
                title: Text(item['title'] as String),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => item['destination'] as Widget));
                },
              );
            }).toList(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220.0,
            floating: true,
            pinned: true,
            foregroundColor: Colors.white,
            backgroundColor: colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              // Keep title at the bottom when collapsed
              titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
              title: Text(
                'Dashboard',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: false,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colorScheme.primary, colorScheme.primaryContainer.withOpacity(0.8)],
                  ),
                ),
                child: Padding(
                  // Reduced top padding and adjusted bottom padding to shift content up
                  padding: const EdgeInsets.only(top: 40, left: 20, bottom: 60), 
                  child: Row(
                    // Align row content to the bottom of the padding area
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Text(
                          'U',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Main User Info Column
                      Column(
                        // Align content within the column to the bottom
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // REMOVED hardcoded SizedBox(height: 50)
                          Text('Welcome back,', style: theme.textTheme.titleSmall?.copyWith(color: Colors.white70)),
                          Text(
                            'User!',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Logout',
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                },
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320.0,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.6,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final item = dashboardItems[index];
                  return _buildDashboardCard(
                    context,
                    item['title'] as String,
                    item['icon'] as Widget,
                    item['subtitle'] as String,
                    () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => item['destination'] as Widget));
                    },
                    item['color'] as Color,
                  );
                },
                childCount: dashboardItems.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}