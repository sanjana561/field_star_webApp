import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class sidebar extends StatefulWidget {
  final Widget child;

  const sidebar({super.key, required this.child});

  @override
  State<sidebar> createState() => _sidebarState();
}

class _sidebarState extends State<sidebar> {
  Widget _navItem(
    BuildContext context, {
    required String route,
    required IconData icon,
    required String label,
  }) {
    final currentPath = GoRouterState.of(context).uri.path;
    final isSelected = currentPath == route;

    return InkWell(
      onTap: () => context.go(route),

      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8680A) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : const Color(0xFFB0B8C1),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : const Color(0xFFB0B8C1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: Row(
        children: [
          Container(
            width: 260,
            color: const Color(0xFF1E2330),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo / Brand header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 36, 16, 28),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8680A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.build_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Field Star",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Admin Panel",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF8A9099),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Nav items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _navItem(
                        context,
                        route: '/Dashboard',
                        icon: Icons.grid_view_rounded,
                        label: "Overview",
                      ),
                      _navItem(
                        context,
                        route: '/Complaints',
                        icon: Icons.assignment_outlined,
                        label: "Complaints",
                      ),
                      _navItem(
                        context,
                        route: '/Technicians',
                        icon: Icons.people_outline_rounded,
                        label: "Technicians",
                      ),
                      _navItem(
                        context,
                        route: '/Customers',
                        icon: Icons.person_outline_rounded,
                        label: "Customers",
                      ),
                      // _navItem(
                      //   context,
                      //   route: '/Billing',
                      //   icon: Icons.credit_card_outlined,
                      //   label: "Billing & Payments",
                      // ),
                      // _navItem(
                      //   context,
                      //   route: '/Analytics',
                      //   icon: Icons.bar_chart_rounded,
                      //   label: "Analytics",
                      // ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: InkWell(
                    onTap: () => _handleSignOut(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Sign Out",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (!context.mounted) return;
      context.go('/login');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error signing out: $e")),
      );
    }
  }
}