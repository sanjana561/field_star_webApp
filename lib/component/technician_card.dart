import 'package:field_star/component/tech_card.dart';
import 'package:field_star/model/tech_model.dart';
import 'package:field_star/repository/technician_repository.dart';
import 'package:flutter/material.dart';

class TechnicianCard extends StatelessWidget {
  final String name;
  final String id;
  final String phone;
  final String location;
  final String activeJobs;
  final String jobsToday;
  final String rating;
  final double completionRate; // 0.0 to 1.0
  final List<String> specializations;
  final VoidCallback onViewProfile;
  final VoidCallback onAssignJob;
  final TechModel technician;
  final String status;
  final bool showAssignButton;

  const TechnicianCard({
    super.key,
    required this.name,
    required this.id,
    required this.phone,
    required this.location,
    required this.activeJobs,
    required this.jobsToday,
    required this.rating,
    required this.completionRate,
    required this.specializations,
    required this.onViewProfile,
    required this.onAssignJob,
    required this.technician,
    required this.status,
    required this.showAssignButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, ID, Busy Badge
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF2563EB),
                child: Text(
                  name.split(' ').map((e) => e[0]).join(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    id,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 10, color: Color(0xFF92400E)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Contact Info
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                phone,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                location,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Metrics Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric(activeJobs, "Active Jobs"),
              _buildMetric(jobsToday, "Today"),
              _buildMetric("★ $rating", "Rating"),
            ],
          ),
          const SizedBox(height: 20),
          // Specializations
          const Text(
            "Specializations",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: specializations
                .map(
                  (spec) => Chip(
                    label: Text(spec, style: const TextStyle(fontSize: 11)),
                    padding: EdgeInsets.zero,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showEditProfile(context),

                  child: const Text("View Profile"),
                ),
              ),
              const SizedBox(width: 12),
              if (showAssignButton)
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAssignJob,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Assign Job"),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String value, String label) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
    ],
  );

  //============================Edit technician form============================
  void _showEditProfile(BuildContext context) {
    final nameController = TextEditingController(text: name);
    final phoneController = TextEditingController(text: phone);
    final locationController = TextEditingController(text: location);
    final specializationController = TextEditingController(
      text: specializations.join(', '),
    );
    final database = TechnicianRepository();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          content: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Edit Technician",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildField('Name', '', nameController),
                const SizedBox(height: 15),
                _buildField('PhoneNo', '', phoneController),
                const SizedBox(height: 15),
                _buildField('Location', '', locationController),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      final updatetech = TechModel(
                        fullName: nameController.text.trim(),
                        id: technician.id,

                        techId: technician.techId,
                        phone: phoneController.text.trim(),
                        location: locationController.text.trim(),
                        specialization: specializationController.text.trim(),
                      );
                      await database.updatetechnician(updatetech);

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Technician updated successfully'),
                        ),
                      );
                    },

                    child: const Text(
                      "Update Technician",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
