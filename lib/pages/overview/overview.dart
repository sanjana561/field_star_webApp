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
  final repo =TechnicianRepository();
  @override
  Widget build(BuildContext context) {
    return sidebar(
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
         FutureBuilder<Map<String, dynamic>>(
  future: widget.technicianId.isEmpty
      ? Future.value({
          'activeComplaints': 0,
          'completedToday': 0,
          'activeTechnicians': 0,
          'offlineTechnicians': 0,
          'complaintTrend': 0.0,
          'completedTrend': 0.0,         // ← already there, good
        })
      : repo.fetchDashboardStats(widget.technicianId),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator()); // ← add Center
    }

    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}'); // ← add error handling
    }

    final data = snapshot.data!;
    final complaintTrend = (data['complaintTrend'] as num).toDouble();
    final completedTrend = (data['completedTrend'] as num).toDouble();
    return Row(
      spacing: 12,
      children: [
        const Expanded(
          child: StatCard(
            value: '0',
            label: 'Total Revenue',
            icon: Icons.attach_money,
            iconBackgroundColor: Colors.greenAccent,
            trend: '0%',
            trendColor: Colors.green,
          ),
        ),

        Expanded(
          child: StatCard(
            value: '${data['activeComplaints']}',
            label: 'Active Complaints',
            icon: Icons.warning,
            iconBackgroundColor: Colors.orangeAccent,
            trend:
                '${complaintTrend >= 0 ? '+' : ''}${complaintTrend.toStringAsFixed(1)}%',
            trendColor: complaintTrend >= 0 ? Colors.green : Colors.red,
          ),
        ),

        Expanded(
          child: StatCard(
            value: '${data['completedToday']}',
            label: 'Completed Today',
            icon: Icons.done_all_outlined,
            iconBackgroundColor: Colors.blueAccent,
            trend:
                '${completedTrend >= 0 ? '+' : ''}${completedTrend.toStringAsFixed(1)}%',
            trendColor: completedTrend >= 0 ? Colors.green : Colors.red,
          ),
        ),

        Expanded(
          child: StatCard(
            value: '${data['activeTechnicians']}',
            label: 'Active Technicians',
            icon: Icons.people,
            iconBackgroundColor: Colors.purpleAccent,
            trend: '${data['offlineTechnicians']} offline',
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
    );
  }
}
