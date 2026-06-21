import 'package:field_star/component/analytics_card.dart';
import 'package:field_star/component/metric.dart';
import 'package:field_star/navigation/primaryscaffold.dart';
import 'package:flutter/material.dart';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  @override
  Widget build(BuildContext context) {
    return sidebar(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Analytics & Insights",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: const Color.fromARGB(255, 4, 6, 10),
                  ),
                ),
                Text(
                  "Performance metrics and business intelligence",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Row(
              spacing: 16,

              children: [
                Expanded(
                  child: AnalyticsCard(
                    value: "95.5%",
                    label: "Service Completion Rate",
                    target: "95%",
                    icon: Icons.track_changes,
                    trend: "+2.3%",
                  ),
                ),
                Expanded(
                  child: AnalyticsCard(
                    value: "28 min",
                    label: "Avg Response Time",
                    target: "30 min",
                    icon: Icons.access_time,
                    trend: "-5 min",
                    isTrendPositive: true, // Positive because -5min is better
                  ),
                ),
                Expanded(
                  child: AnalyticsCard(
                    value: "4.7/5",
                    label: "Customer Satisfaction",
                    target: "4.5/5",
                    icon: Icons.people_outline,
                    trend: "+0.2",
                  ),
                ),
                Expanded(
                  child: AnalyticsCard(
                    value: "8.2%",
                    label: "Repeat Complaints",
                    target: "<10%",
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.orange,
                    iconBackgroundColor: Colors.orange.shade50,
                    trend: "-1.8%",
                    trendColor: Colors.red,
                    isTrendPositive:
                        false, // Negative trend because -1.8% is good
                  ),
                ),
              ],
            ),
            // Add this below your existing Row of cards
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Key Insights",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Insight 1
                  _buildInsightRow(
                    Icons.trending_up,
                    "Performance Improved",
                    "Service completion rate increased by 2.3% compared to last month",
                    Colors.green,
                  ),
                  const SizedBox(height: 12),

                  // Insight 2
                  _buildInsightRow(
                    Icons.warning_amber_rounded,
                    "Equipment Alert",
                    "Deep Fryers show 35% increase in service requests. Consider preventive maintenance program.",
                    Colors.orange,
                  ),
                  const SizedBox(height: 12),

                  // Insight 3
                  _buildInsightRow(
                    Icons.people_outline,
                    "Top Performer",
                    "Suresh Menon maintains highest rating (4.9) with 32 completed jobs this week",
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),

                  // Insight 4
                  _buildInsightRow(
                    Icons.access_time,
                    "Response Time",
                    "Average response time reduced to 28 minutes - beating target of 30 minutes",
                    Colors.amber,
                  ),
                ],
              ),
            ),
            //====================Metric card design===========================
            SizedBox(height: 15),
            Row(
              spacing: 16, // Use your existing spacing property
              children: [
                Expanded(
                  child: MetricCard(
                    title: "Total Services (MTD)",
                    value: "178",
                    subtitle: "+12% from last month",
                    gradientColors: [Color(0xFF2962FF), Color(0xFF3D5AFE)],
                  ),
                ),
                Expanded(
                  child: MetricCard(
                    title: "Revenue Growth",
                    value: "+15.3%",
                    subtitle: "Year over year",
                    gradientColors: [Color(0xFF00C853), Color(0xFF00BFA5)],
                  ),
                ),
                Expanded(
                  child: MetricCard(
                    title: "Active Customers",
                    value: "182",
                    subtitle: "97.8% retention rate",
                    gradientColors: [Color(0xFFFF6D00), Color(0xFFFF9100)],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //Helper Function
  Widget _buildInsightRow(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: color.withOpacity(0.8), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
