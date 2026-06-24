import 'package:flutter/material.dart';

class AnalyticsCard extends StatelessWidget {
  final String value;
  final String label;
  final String? target;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String? trend;
  final Color? trendColor;
  final bool isTrendPositive;
  final VoidCallback? onTap;

  const AnalyticsCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.target,
    this.iconColor = const Color(0xFF00C853), 
    this.iconBackgroundColor = const Color(0xFFE8F5E9), 
    this.trend,
    this.trendColor,
    this.isTrendPositive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
       
            padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                if (trend != null)
                  _buildTrendIndicator(
                    trend!,
                    trendColor ?? (isTrendPositive ? Colors.green : Colors.red),
                    isTrendPositive,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            if (target != null) ...[
              const SizedBox(height: 6),
              Text("Target: $target", style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(String trend, Color color, bool isPositive) {
    return Row(
      children: [
        Icon(isPositive ? Icons.trending_up : Icons.trending_down, color: color, size: 16),
        const SizedBox(width: 4),
        Text(trend, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}