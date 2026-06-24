import 'package:field_star/component/stat_card.dart';
import 'package:field_star/navigation/primaryscaffold.dart';
import 'package:field_star/pages/overview/recenttranscation.dart';
import 'package:field_star/repository/technician_repository.dart';
import 'package:flutter/material.dart';

class Overview extends StatefulWidget {
  final String technicianId;

  const Overview({super.key, required this.technicianId});

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  final repo = TechnicianRepository();

  @override
  void initState() {
    super.initState();
    late Future<Map<String, dynamic>> _dashboardFuture;
    debugPrint('Overview initState — technicianId: "${widget.technicianId}"');

    final int? parsedId = int.tryParse(widget.technicianId);
    debugPrint('parsedId: $parsedId');

    _dashboardFuture = (parsedId == null || parsedId == 0)
        ? Future.value({
            'activeComplaints': 0,
            'completedToday': 0,
            'activeTechnicians': 0,
            'offlineTechnicians': 0,
            'complaintTrend': 0.0,
            'completedTrend': 0.0,
          })
        : repo.fetchDashboardStats(widget.technicianId);
  }

  @override
  Widget build(BuildContext context) {
    return sidebar(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dashboard",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    "Welcome back! Here's what's happening today.",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
//=======================Fetch dashboard kpiboxes count============================================
              FutureBuilder<Map<String, dynamic>>(
                future: repo.fetchDashboardStats(widget.technicianId),
                builder: (context, snapshot) {
                  // Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  // Error
                  if (snapshot.hasError) {
                    return SizedBox(
                      height: 100,
                      child: Center(
                        child: Text(
                          'Failed to load stats: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  // No data guard
                  if (!snapshot.hasData) {
                    return const SizedBox(height: 100);
                  }

                  final data = snapshot.data!;

                  // Safe casting with fallback defaults
                  final activeComplaints =
                      (data['activeComplaints'] as num?)?.toInt() ?? 0;
                  final completedToday =
                      (data['completedToday'] as num?)?.toInt() ?? 0;
                  final activeTechs =
                      (data['activeTechnicians'] as num?)?.toInt() ?? 0;
               

                  return Row(
                    children: [
 // ── Active Complaints ─────────────────────────────────────────────
                      Expanded(
                        child: StatCard(
                          value: '$activeComplaints',
                          label: 'Active Complaints',
                          icon: Icons.warning,
                          iconBackgroundColor: Colors.orangeAccent,
                         
                        ),
                      ),
                      const SizedBox(width: 12),

  // ── Completed Today ───────────────────────────────────────────────
                      Expanded(
                        child: StatCard(
                          value: '$completedToday',
                          label: 'Completed Today',
                          icon: Icons.done_all_outlined,
                          iconBackgroundColor: Colors.blueAccent,
                         
                        ),
                      ),
                      const SizedBox(width: 12),

 // ── Active Technicians ────────────────────────────────────────────
                      Expanded(
                        child: StatCard(
                          value: '$activeTechs',
                          label: 'Active Technicians',
                          icon: Icons.people,
                          iconBackgroundColor: Colors.purpleAccent,
                       
                          trendColor: Colors.red,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Recent complaints table
              RecentComplaintsTable(
                searchQuery: '',
                onViewAll: () {
                  // Navigate to complaints page
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
