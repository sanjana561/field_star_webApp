import 'package:field_star/model/tech_model.dart';
import 'package:field_star/repository/technician_repository.dart';
import 'package:flutter/material.dart';

class TechnicianOption {
  final String initials;
  final String id;
  final Color avatarColor;
  final String name;
  final String techId;
  final String location;
  final bool isAvailable;
  final int activeJobs;

  const TechnicianOption({
    required this.initials,
    required this.avatarColor,
    required this.name,
    required this.techId,
    required this.location,
    required this.isAvailable,
    required this.activeJobs,
    required this.id,
  });
}

class AssignTechnicianDialog extends StatefulWidget {
  final String ticketId;
  final Future<void> Function(TechnicianOption selected) onAssign;

  const AssignTechnicianDialog({
    super.key,
    required this.ticketId,
    required this.onAssign,
  });

  @override
  State<AssignTechnicianDialog> createState() => _AssignTechnicianDialogState();
}

class _AssignTechnicianDialogState extends State<AssignTechnicianDialog> {
  TechnicianOption? _selected;
  late Future<List<TechModel>> _techFuture;
  final TechnicianRepository _repo = TechnicianRepository();
  bool _isAssigning = false;

  @override
  void initState() {
    super.initState();
    _techFuture = _repo.fetchTechnicians();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: SizedBox(
        width: 400,
       
        height: 500,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assign Technician',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select a technician for ${widget.ticketId}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<TechModel>>(
                  future: _techFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    }

                    final techModels = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: techModels.length,
                      itemBuilder: (context, index) {
                        final tech = techModels[index];
                        final option = TechnicianOption(
                          initials: tech.fullName.substring(0, 2).toUpperCase(),
                          avatarColor: Colors.blue,
                          name: tech.fullName,
                          techId: tech.techId,
                          location: tech.location,
                          isAvailable: true,
                          activeJobs: 0,
                          id: tech.id ?? '',
                        );
                        return _buildTechnicianTile(option);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selected == null || _isAssigning
                          ? null
                          : () async {
                              setState(() => _isAssigning = true);
                              await widget.onAssign(_selected!);
                              if (!mounted) return;
                              setState(() => _isAssigning = false);
                              
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8680A),
                        disabledBackgroundColor: const Color(
                          0xFFE8680A,
                        ).withOpacity(0.4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isAssigning
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Assign',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
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

  Widget _buildTechnicianTile(TechnicianOption tech) {
    final isSelected =
        _selected?.id == tech.id; // ✅ Fixed: compare by id, not reference

    return GestureDetector(
      onTap: () => setState(() => _selected = tech),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF4EC) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE8680A)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: tech.avatarColor,
              child: Text(
                tech.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tech.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${tech.techId} • ${tech.location}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
