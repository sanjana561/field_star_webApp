import 'package:flutter/material.dart';

class BillingCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subText; 
  final Color? subTextColor;

  const BillingCard({
    super.key,
    required this.label,
    required this.value,
    this.subText,
    this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          if (subText != null) ...[
            const SizedBox(height: 4),
            Text(
              subText!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: subTextColor ?? Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}