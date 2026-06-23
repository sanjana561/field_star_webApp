import 'package:field_star/model/complaint_model.dart';
import 'package:field_star/repository/technician_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum Priority { high, medium, low }

enum ComplaintStatus { pending, assigned, inProgress, completed }

Priority _mapPriority(String? val) {
  switch (val?.toLowerCase()) {
    case 'high':
      return Priority.high;
    case 'medium':
      return Priority.medium;
    default:
      return Priority.low;
  }
}

ComplaintStatus _mapStatus(String? val) {
  switch (val?.toLowerCase()) {
    case 'assigned':
      return ComplaintStatus.assigned;
    case 'in progress':
      return ComplaintStatus.inProgress;
    case 'completed':
      return ComplaintStatus.completed;
    default:
      return ComplaintStatus.pending;
  }
}

class RecentComplaintsTable extends StatefulWidget {
  final String searchQuery;
  final VoidCallback? onViewAll;

  const RecentComplaintsTable({
    super.key,
    this.onViewAll,
    required this.searchQuery,
  });

  @override
  State<RecentComplaintsTable> createState() => _RecentComplaintsTableState();
}

class _RecentComplaintsTableState extends State<RecentComplaintsTable> {
  final _repo = TechnicianRepository();
  late Future<List<ComplaintModel>> _complaintsFuture;

  @override
  void initState() {
    super.initState();
    _complaintsFuture = _repo.fetchComplaints();
  }

  void _refresh() => setState(() {
    _complaintsFuture = _repo.fetchComplaints();
  });

  List<ComplaintModel> _applySearch(List<ComplaintModel> all) {
    if (widget.searchQuery.isEmpty) return all;
    final q = widget.searchQuery.toLowerCase();
    return all
        .where(
          (c) =>
              c.ticketId.toLowerCase().contains(q) ||
              (c.categoryName?.toLowerCase().contains(q) ?? false) ||
              (c.serviceRequired?.toLowerCase().contains(q) ?? false) ||
              (c.problem?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  Widget _priorityBadge(Priority priority) {
    late String label;
    late Color bg;
    late Color textColor;
    switch (priority) {
      case Priority.high:
        label = 'High Priority';
        bg = const Color(0xFFFFE4E4);
        textColor = const Color(0xFFE05252);
        break;
      case Priority.medium:
        label = 'Medium';
        bg = const Color(0xFFFFF3CD);
        textColor = const Color(0xFFB8860B);
        break;
      case Priority.low:
        label = 'Low';
        bg = const Color(0xFFE8E8FF);
        textColor = const Color(0xFF6666CC);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _statusBadge(ComplaintStatus status) {
    late String label;
    late Color bg;
    late Color textColor;
    switch (status) {
      case ComplaintStatus.pending:
        label = 'Pending';
        bg = const Color(0xFFFFF3CD);
        textColor = const Color(0xFFB8860B);
        break;
      case ComplaintStatus.assigned:
        label = 'Assigned';
        bg = const Color(0xFFE8E8FF);
        textColor = const Color(0xFF6666CC);
        break;
      case ComplaintStatus.inProgress:
        label = 'In Progress';
        bg = const Color(0xFFE0F0FF);
        textColor = const Color(0xFF3399CC);
        break;
      case ComplaintStatus.completed:
        label = 'Completed';
        bg = const Color(0xFFD4F5E2);
        textColor = const Color(0xFF2E9E5B);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ComplaintModel>>(
      future: _complaintsFuture,
      builder: (context, snapshot) {
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
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFE05252),
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load complaints\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(onPressed: _refresh, child: const Text('Retry')),
                ],
              ),
            ),
          );
        }

        final rows = _applySearch(snapshot.data ?? []);

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title + View All row ──────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Complaints',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),

              // ── DataTable ─────────────────────────────────────────
              if (rows.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No complaints found.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: Theme(
                    // Override DataTable's default divider and header colors
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: const Color(0xFFEEEEEE)),
                    child: InkWell(
                      child: DataTable(
                        showCheckboxColumn: false,

                        // ── Layout ──────────────────────────────────
                        columnSpacing: 16,
                        horizontalMargin: 20,
                        headingRowHeight: 40,
                        dataRowMinHeight: 52,
                        dataRowMaxHeight: 52,
                        dividerThickness: 1,

                        // ── Header style ────────────────────────────
                        headingRowColor: WidgetStateProperty.all(
                          const Color(0xFFFAFAFA),
                        ),
                        headingTextStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),

                        // ── Row style ───────────────────────────────
                        dataTextStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF334155),
                        ),

                        // ── Columns ─────────────────────────────────
                        columns: const [
                          DataColumn(label: Text('TICKET ID')),
                          DataColumn(label: Text('ITEM NAME')),
                          DataColumn(label: Text('EQUIPMENT')),
                          DataColumn(label: Text('PRIORITY')),
                          DataColumn(label: Text('STATUS')),
                        ],

                        // ── Rows ────────────────────────────────────
                        rows: rows.map((c) {
                          final priority = _mapPriority(c.priorityLevel);
                          final status = _mapStatus(c.techstatus);

                          return DataRow(
                            onSelectChanged: (selected) {
                              if (selected != null) {
                                _showcomplaintform(context, c);
                              }
                            },
                            cells: [
                              DataCell(
                                Text(
                                  c.ticketId,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  c.categoryName ?? '-',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataCell(
                                Text(
                                  c.serviceRequired ?? c.problem ?? '-',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataCell(_priorityBadge(priority)),
                              DataCell(_statusBadge(status)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  //=============================Showw all complaint Details=============================
  void _showcomplaintform(BuildContext context, ComplaintModel c) {
 
    final formKey = GlobalKey<FormState>();
  

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Center(
          child: SizedBox(
            width: 600,
            child: Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.info,
                              size: 18,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Complaint Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                              color: Color(0xFF94A3B8),
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),



                      _editField(
                        'Tickect ID:-',
                        c.ticketId ?? 'N/A',
                        Icons.numbers,
                      ),
                      const SizedBox(height: 14),
                      _editField(
                        'Item Name:-',
                        c.categoryName ?? 'N/A',
                        Icons.devices_other_sharp,
                      ),
                      const SizedBox(height: 14),
                      _editField(
                        'Service Required:-',
                        c.serviceRequired ?? 'N/A',
                        Icons.business_outlined,
                      ),
                      const SizedBox(height: 14),
                      _editField(
                        'problem:-',
                        c.problem ?? 'N/A',
                        Icons.location_on_outlined,
                      ),
                       const SizedBox(height: 14),
                       _editField(
                        'Priority Level:-',
                        c.priorityLevel ?? 'N/A',
                        Icons.location_on_outlined,
                      ),
                        const SizedBox(height: 14),
                       _editField(
                        'Status:-',
                        c.complaintstatus ?? 'N/A',
                        Icons.location_on_outlined,
                      ),
                       const SizedBox(height: 14),
                       _editField(
                        'Tech Assigned:-',
                        c.technicianName ?? 'N/A',
                        Icons.location_on_outlined,
                      ),
                      // Row(
                      //   children: [
                         
                      //     const SizedBox(width: 12),
                      //     Expanded(
                      //       child: ElevatedButton(
                      //          onPressed: saving
                      //             ? null
                      //             : () => Navigator.pop(ctx),
                             
                      //         style: ElevatedButton.styleFrom(
                      //           backgroundColor: const Color(0xFF3B82F6),
                      //           foregroundColor: Colors.white,
                      //           padding: const EdgeInsets.symmetric(
                      //             vertical: 12,
                      //           ),
                      //           elevation: 0,
                      //           shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(8),
                      //           ),
                      //         ),
                      //         child: saving
                      //             ? const SizedBox(
                      //                 width: 16,
                      //                 height: 16,
                      //                 child: CircularProgressIndicator(
                      //                   strokeWidth: 2,
                      //                   color: Colors.white,
                      //                 ),
                      //               )
                      //             : const Text(
                      //                 'OK',
                      //                 style: TextStyle(
                      //                   fontSize: 13,
                      //                   fontWeight: FontWeight.w600,
                      //                 ),
                      //               ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //===============================Helper function===================================
  Widget _editField(String label, String value, IconData icon) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(width: 15),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 6),
    ],
  );
}
