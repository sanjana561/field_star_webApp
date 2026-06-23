import 'package:field_star/component/tech_card.dart';
import 'package:field_star/model/tech_model.dart';
import 'package:field_star/repository/technician_repository.dart';
import 'package:flutter/material.dart';

class TechnicianCard extends StatefulWidget {
  final String name;
  final String id;
  final String techid;
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
  final VoidCallback onDelete;

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
    required this.techid,
    required this.onDelete,
  });

  @override
  State<TechnicianCard> createState() => _TechnicianCardState();
}

class _TechnicianCardState extends State<TechnicianCard> {
  final database = TechnicianRepository();
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
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Avatar, Name, ID, Busy Badge
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF2563EB),
                    child: Text(
                      widget.name.split(' ').map((e) => e[0]).join(),
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
                        widget.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.id,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.status,
                      style: TextStyle(fontSize: 10, color: Color(0xFF92400E)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Contact Info
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.phone,
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
                    widget.location,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Metrics Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetric(widget.activeJobs, "Active Jobs"),
                  _buildMetric(widget.jobsToday, "Today"),
                  _buildMetric("★ ${widget.rating}", "Rating"),
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
                children: widget.specializations
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

                      child: const Text("Edit Profile"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (widget.showAssignButton)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onAssignJob,
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
          Tooltip(
            message: 'Delete Technician',
            child: IconButton(
              onPressed: () async {
                print('Delete button tapped — widget.id: ${widget.id}');

                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: const Text('Delete Technician'),
                    content: const Text(
                      'Are you sure you want to delete this technician? This cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                print('Dialog result: $confirmed');

                if (confirmed == true) {
                  print(
                    'Calling deletetechnician with id: ${widget.technician.id}',
                  );
                  try {
                    await database.deletetechnician(id: widget.technician.id);
                    print('Delete successful');
                    widget.onDelete();
                  } catch (e) {
                    print('Delete failed with error: $e');
                  }
                }
              },
              icon: const Icon(Icons.delete),
              color: Colors.red,
            ),
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
    final nameController = TextEditingController(text: widget.name);
    final phoneController = TextEditingController(text: widget.phone);
    final locationController = TextEditingController(text: widget.location);
    final specializationController = TextEditingController(
      text: widget.specializations.join(', '),
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
                        id: widget.technician.id,

                        techId: widget.technician.techId,
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
