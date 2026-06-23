import 'package:field_star/component/customer_card.dart';
import 'package:field_star/model/customer_model.dart';
import 'package:field_star/navigation/primaryscaffold.dart';
import 'package:field_star/pages/customer/customer_tabel.dart';
import 'package:field_star/repository/technician_repository.dart';
import 'package:flutter/material.dart';

class Customer extends StatefulWidget {
  const Customer({super.key});

  @override
  State<Customer> createState() => _CustomerState();
}

class _CustomerState extends State<Customer> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _equipmentController = TextEditingController();
  final TextEditingController _RevenueController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _hotelName = TextEditingController();
  final _repository = TechnicianRepository();

  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

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
                  "Customer Database",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: const Color.fromARGB(255, 4, 6, 10),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Manage customer profiles and service history",
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
                          _showRegistercustomerDialog(context);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Add customer"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
            FutureBuilder<Map<String, dynamic>>(
              future: _repository.fetchcustomerstats(),
              builder: (context, snapshot) {
                final totalCustomers =
                    ((snapshot.data?['totalCustomers']) as num?)?.toInt() ?? 0;
                final thisMonthCount =
                    ((snapshot.data?['thisMonthCount']) as num?)?.toInt() ?? 0;
                final totalEquipment =
                    ((snapshot.data?['totalEquipment']) as num?)?.toInt() ?? 0;

                return Row(
                  children: [
                    Expanded(
                      child: CustomerStatCard(
                        label: 'Total Customers',
                        value:
                            snapshot.connectionState == ConnectionState.waiting
                            ? '...'
                            : '$totalCustomers',
                        icon: Icons.receipt_long_outlined,
                        iconColor: const Color(0xFF3B82F6),
                        subText: '+$thisMonthCount this month',
                        subTextColor: const Color(0xFF2E9E5B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomerStatCard(
                        label: 'Active Accounts',
                        value:
                            snapshot.connectionState == ConnectionState.waiting
                            ? '...'
                            : '$totalCustomers', // all customers are active
                        icon: Icons.trending_up_rounded,
                        iconColor: const Color(0xFF2E9E5B),
                        subText: totalCustomers == 0
                            ? '0% active rate'
                            : '100% active rate',
                        subTextColor: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomerStatCard(
                        label: 'Total Equipment',
                        value:
                            snapshot.connectionState == ConnectionState.waiting
                            ? '...'
                            : '$totalEquipment',
                        icon: Icons.settings_outlined,
                        iconColor: const Color(0xFF94A3B8),
                        subText: 'Under service',
                        subTextColor: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                );
              },
            ),
            SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E9F0), width: 1.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.0,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase().trim();
                          });
                        },
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration(
                          hintText:
                              'Search by TicketId, Customer, Equipments...',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8), // Muted text token colors
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: CustomersTable(searchQuery: _searchQuery),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //=========================add customer form================================
  void _showRegistercustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (ctx, setLocal) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Add Customer",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildField("Full Name", '', _nameController),
                  const SizedBox(height: 15),
                  _buildField("Place", '', _placeController),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          "Phone number",
                          '',
                          _phoneController,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildField("Location", '', _locationController),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildField("Hotel Name", '', _hotelName),
                  const SizedBox(height: 15),

                  // ── Auth fields ──────────────────────────────────
                  _buildField(
                    "Email",
                    'customer@example.com',
                    _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),
                  _buildField(
                    "Password",
                    'Min 6 characters',
                    _passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                              // Validation
                              if (_nameController.text.trim().isEmpty ||
                                  _phoneController.text.trim().isEmpty ||
                                  _hotelName.text.trim().isEmpty ||
                                  _emailController.text.trim().isEmpty ||
                                  _passwordController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please fill all required fields',
                                    ),
                                  ),
                                );
                                return;
                              }
                              if (_passwordController.text.trim().length < 6) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Password must be at least 6 characters',
                                    ),
                                  ),
                                );
                                return;
                              }

                              setLocal(() => isLoading = true);
                              try {
                                await _repository.registerCustomerWithAuth(
                                  customerName: _nameController.text.trim(),
                                  place: _placeController.text.trim(),
                                  phone: _phoneController.text.trim(),
                                  location: _locationController.text.trim(),
                                  hotelName: _hotelName.text.trim(),
                                  totalEquipment:
                                      int.tryParse(_equipmentController.text) ??
                                      0,
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                );

                                // Clear all fields
                                _nameController.clear();
                                _placeController.clear();
                                _phoneController.clear();
                                _locationController.clear();
                                _hotelName.clear();
                                _equipmentController.clear();
                                _emailController.clear();
                                _passwordController.clear();

                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Customer registered successfully!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  setState(() {}); // refresh table
                                }
                              } catch (e) {
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } finally {
                                if (ctx.mounted)
                                  setLocal(() => isLoading = false);
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Register Customer",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
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
