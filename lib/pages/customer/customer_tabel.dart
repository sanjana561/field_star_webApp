import 'package:field_star/model/customer_model.dart';
import 'package:field_star/repository/technician_repository.dart';
import 'package:flutter/material.dart';


class CustomersTable extends StatefulWidget {
  final String searchQuery;

  const CustomersTable({super.key, this.searchQuery = ''});

  @override
  State<CustomersTable> createState() => _CustomersTableState();
}

class _CustomersTableState extends State<CustomersTable> {
   final _repo = TechnicianRepository();
  late Future<List<CustomerModel>> _customerFuture;
@override
  void initState() {
    super.initState();
    _customerFuture = _repo.fetchcustomer();
  }

 
  void _refresh() {
    setState(() {
      _customerFuture = _repo.fetchcustomer();
    });
  }

  List<CustomerModel> _applySearch(List<CustomerModel> all) {
  if (widget.searchQuery.isEmpty) return all;

  final q = widget.searchQuery.toLowerCase();

  return all.where((c) {
    return c.customerName.toLowerCase().contains(q) ||
        c.phone.toLowerCase().contains(q) ||
        c.hotelName.toLowerCase().contains(q) ||
        c.location.toLowerCase().contains(q);
  }).toList();
}
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CustomerModel>>(
      future:_customerFuture,
      builder:(context,snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }
  if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFE05252), size: 32),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load complaints\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
   final rows = _applySearch(snapshot.data ?? []);
   return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: const Row(
              children: [
                Expanded(flex: 5, child: _HeaderCell('CUSTOMER')),
                Expanded(flex: 4, child: _HeaderCell('CONTACT')),
                Expanded(flex: 2, child: _HeaderCell('EQUIPMENT')),
                Expanded(flex: 3, child: _HeaderCell('COMPLAINTS')),
                // Expanded(flex: 3, child: _HeaderCell('LAST SERVICE')),
                Expanded(flex: 3, child: _HeaderCell('REVENUE (YTD)')),
                Expanded(flex: 2, child: _HeaderCell('ACTIONS')),
              ],
            ),
          ),
             if (rows.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No Customer found.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    ),
                  ),
                )
              else
                ...rows.map(_buildRow),

        
        ],
      ),
    );
      }

    );
  
    
  }
  String getFirstLetter(CustomerModel c) {
  if (c.customerName.trim().isEmpty) return '';
  
  return c.customerName.trim().characters.first.toUpperCase();
}

  Widget _buildRow(CustomerModel c) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Customer
          Expanded(
            flex: 5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                backgroundColor: Colors.blue,
                  child: Text(
                   getFirstLetter(c),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.place,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          )),
                      const SizedBox(height: 2),
                      Text(c.hotelName,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          )),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 11, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(c.location,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                ),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contact
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.customerName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0F172A),
                    )),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined,
                        size: 11, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 3),
                    Text(c.phone,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        )),
                  ],
                ),
              ],
            ),
          ),

          // Equipment
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${c.totalEquipment}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                const Text('units',
                    style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
          ),

          // Complaints
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${c.complaintCount} active',     
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: c.complaintCount > 0
              ? const Color(0xFFE8680A)
              : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${c.complaintCount} total',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          // Last Service
          // Expanded(
          //   flex: 3,
          //   child: Text(
          //     c.cre,
          //     style: const TextStyle(
          //       fontSize: 13,
          //       color: Color(0xFF334155),
          //     ),
          //   ),
          // ),
// 
          // Revenue YTD
          Expanded(
            flex: 3,
            child: Text(
             '₹${c.revenueYtd.toStringAsFixed(1)}L',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E9E5B),
              ),
            ),
          ),

          // Actions
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {},
              child: const Text(
                'View Details',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  const _HeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFF94A3B8),
        letterSpacing: 0.5,
      ),
    );
  }
}