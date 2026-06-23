import 'package:field_star/component/tech_card.dart';
import 'package:field_star/component/technician_card.dart';
import 'package:field_star/model/tech_model.dart';
import 'package:field_star/navigation/primaryscaffold.dart';
import 'package:field_star/repository/technician_repository.dart';
import 'package:flutter/material.dart';

class Technician extends StatefulWidget {
  const Technician({super.key});

  @override
  State<Technician> createState() => _TechnicianState();
}

class _TechnicianState extends State<Technician> {
  final _repository = TechnicianRepository();
  String _searchQuery = '';
  bool _isLoading = false;
   late Future<List<TechModel>> _techFuture;
final TextEditingController _emailController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }
 void _refresh() => setState(() {
      _techFuture = _repository.fetchTechnicians(); // ← fetch not delete
    });
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
                    "Technician Management",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: const Color.fromARGB(255, 4, 6, 10),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Monitor technician performance and availability",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),

                      SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            _showRegisterTechnicianDialog(context);
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Add Technician"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 16),
              
              const SizedBox(height: 12),
              FutureBuilder<Map>(
                future: _repository.getTechnicianStats(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final data = snapshot.data!;
                  return Row(
                    children: [
                      Expanded(
                        child: TechCard(
                          label: 'Total Technicians',
                          value: '${data['total']}',
                          icon: Icons.people_alt_outlined,
                          iconBackgroundColor: const Color(0xFFEFF6FF),
                          iconColor: const Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TechCard(
                          label: 'Available Now',
                          value: '${data['available']}',
                          icon: Icons.check_box_rounded,
                          iconBackgroundColor: const Color(0xFFD4F5E2),
                          iconColor: const Color(0xFF2E9E5B),
                          valueColor: const Color(0xFF2E9E5B),
                        ),
                      ),
                      const SizedBox(width: 15),

                      Expanded(
                        child: TechCard(
                          label: 'On Active Jobs',
                          value: '${data['activeJobs']}',
                          icon: Icons.build_outlined,
                          iconBackgroundColor: const Color(0xFFFFF4EC),
                          iconColor: const Color(0xFFE8680A),
                          valueColor: const Color(0xFFE8680A),
                        ),
                      ),
                      const SizedBox(width: 15),

                      Expanded(
                        child: TechCard(
                          label: 'Avg Rating',
                          value: '${data['avgRating']}',
                          icon: Icons.star_rounded,
                          iconBackgroundColor: const Color(0xFFFFFBEB),
                          iconColor: const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: FutureBuilder<List<TechModel>>(
                      future: _repository.fetchTechnicians(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text("No technicians found."),
                          );
                        }

                        final technicians = snapshot.data!;

                        return GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2.2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 5,
                              ),
                          itemCount: technicians.length,
                          itemBuilder: (context, index) {
                            final tech = technicians[index];

                            return FutureBuilder<int>(
                                future: _repository.getActiveComplaintCount(tech.id!),
                              builder: (context, complaintSnapshot) {
                               final activeCount = complaintSnapshot.data ?? 0;
                  final isBusy = activeCount > 0;

                              return  TechnicianCard(
                                  technician: tech,
                                  name: tech.fullName,
                                  id: tech.techId,
                                  techid: tech.techId,
                                  phone: tech.phone,
                                  location: tech.location,
                                  activeJobs: activeCount.toString(),
                                  jobsToday: "0",
                                  status: isBusy ? "Busy" : "Available",
                                  showAssignButton: !isBusy,
                                  rating: "5.0",
                                  completionRate: 1.0,
                                  specializations: [tech.specialization],
                                  onViewProfile: () {},
                                  onAssignJob: () {},
                                  onDelete: _refresh,
                                );
                              },
                            );
                          },
                        );
                      },
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

  //==================================Add Technician Form================================
void _showRegisterTechnicianDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Add Technician",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildField("Full Name", '', _nameController),
              const SizedBox(height: 15),
              _buildField("Tech Id", "", _idController),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildField("Phone number", '', _phoneController)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildField("Location", '', _locationController)),
                ],
              ),
              const SizedBox(height: 15),
              _buildField("Specialization", '', _specializationController),
              const SizedBox(height: 15),

              // ── Auth fields ──────────────────────────────────────
              _buildField("Email", 'technician@example.com', _emailController,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 15),
              _buildField("Password", 'Min 6 characters', _passwordController,
                  obscureText: true),
              const SizedBox(height: 25),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          // Basic validation
                          if (_emailController.text.trim().isEmpty ||
                              _passwordController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Email and password are required')),
                            );
                            return;
                          }
                          if (_passwordController.text.trim().length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Password must be at least 6 characters')),
                            );
                            return;
                          }

                          setState(() => _isLoading = true);
                          try {
                            await _repository.registerTechnicianWithAuth(
                              fullName: _nameController.text.trim(),
                              techId: _idController.text.trim(),
                              phone: _phoneController.text.trim(),
                              location: _locationController.text.trim(),
                              specialization: _specializationController.text.trim(),
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            );

                            // Clear all fields
                            _nameController.clear();
                            _idController.clear();
                            _phoneController.clear();
                            _locationController.clear();
                            _specializationController.clear();
                            _emailController.clear();
                            _passwordController.clear();

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Technician registered successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _refresh();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text("Register Technician",
                          style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget _buildField(
  String label,
  String hint,
  TextEditingController controller, {
  TextInputType keyboardType = TextInputType.text,
  bool obscureText = false,
}) {
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
        keyboardType: keyboardType,
        obscureText: obscureText,
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
