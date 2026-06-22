import 'package:field_star/model/complaint_model.dart';
import 'package:field_star/repository/technician_repository.dart';
import 'package:flutter/material.dart';

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

  const RecentComplaintsTable({super.key, this.onViewAll, required this.searchQuery});  

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

 
  void _refresh() {
    setState(() {
      _complaintsFuture = _repo.fetchComplaints();
    });
  }

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
    late Color text;

    switch (priority) {
      case Priority.high:
        label = 'High Priority';
        bg = const Color(0xFFFFE4E4);
        text = const Color(0xFFE05252);
        break;
      case Priority.medium:
        label = 'Medium';
        bg = const Color(0xFFFFF3CD);
        text = const Color(0xFFB8860B);
        break;
      case Priority.low:
        label = 'Low';
        bg = const Color(0xFFE8E8FF);
        text = const Color(0xFF6666CC);
        break;
    }
   


    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: text,
        ),
      ),
    );
  }

  Widget _statusBadge(ComplaintStatus status) {
    late String label;
    late Color bg;
    late Color text;

    switch (status) {
      case ComplaintStatus.pending:
        label = 'Pending';
        bg = const Color(0xFFFFF3CD);
        text = const Color(0xFFB8860B);
        break;
      case ComplaintStatus.assigned:
        label = 'Assigned';
        bg = const Color(0xFFE8E8FF);
        text = const Color(0xFF6666CC);
        break;
      case ComplaintStatus.inProgress:
        label = 'In Progress';
        bg = const Color(0xFFE0F0FF);
        text = const Color(0xFF3399CC);
        break;
      case ComplaintStatus.completed:
        label = 'Completed';
        bg = const Color(0xFFD4F5E2);
        text = const Color(0xFF2E9E5B);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: text,
        ),
      ),
    );
  }

  @override
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
                const Icon(Icons.error_outline, color: Color(0xFFE05252), size: 32),
                const SizedBox(height: 12),
                Text(
                  'Failed to load complaints\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'Recent Complaints',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  _buildHeader(),

                  if (rows.isEmpty)
                    const SizedBox(
                      width: 900,
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No complaints found.',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    ...rows.map(_buildRow),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildHeader() {
  return Container(
    width: 900,
    decoration: const BoxDecoration(
      border: Border(
        top: BorderSide(color: Color(0xFFEEEEEE)),
        bottom: BorderSide(color: Color(0xFFEEEEEE)),
      ),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: const Row(
      children: [
        SizedBox(width: 130, child: _HeaderCell('TICKET ID')),
        SizedBox(width: 170, child: _HeaderCell('ITEM NAME')),
        SizedBox(width: 250, child: _HeaderCell('EQUIPMENT')),
        SizedBox(width: 170, child: _HeaderCell('PRIORITY')),
        SizedBox(width: 140, child: _HeaderCell('STATUS')),
      ],
    ),
  );
}

Widget _buildRow(ComplaintModel c) {
  final priority = _mapPriority(c.priorityLevel);
  final status = _mapStatus(c.techstatus);

  return Container(
    width: 900,
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Color(0xFFF5F5F5)),
      ),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    child: Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(
            c.ticketId,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0F172A),
            ),
          ),
        ),

        SizedBox(
          width: 170,
          child: Text(
            c.categoryName ?? '-',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
          ),
        ),

        SizedBox(
          width: 250,
          child: Text(
            c.serviceRequired ?? c.problem ?? '-',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
          ),
        ),

        SizedBox(
          width: 170,
          child: Align(
            alignment: Alignment.centerLeft,
            child: _priorityBadge(priority),
          ),
        ),

        SizedBox(
          width: 140,
          child: Align(
            alignment: Alignment.centerLeft,
            child: _statusBadge(status),
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