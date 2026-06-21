// lib/pages/complaints/complaints_table.dart

import 'package:field_star/model/complaint_model.dart';
import 'package:field_star/pages/complaints/assign_tech.dart';
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

class ComplaintsTable extends StatefulWidget {
  final String searchQuery;
  const ComplaintsTable({super.key, this.searchQuery = ''});

  @override
  State<ComplaintsTable> createState() => _ComplaintsTableState();
}

class _ComplaintsTableState extends State<ComplaintsTable> {
  final _repo = TechnicianRepository();
  late Future<List<ComplaintModel>> _complaintsFuture;

  @override
  void initState() {
    super.initState();
    _complaintsFuture = _repo.fetchComplaints();
  }

  // Called after assigning a technician to re-fetch fresh data
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

  // ── PRIORITY BADGE ──────────────────────────────────────────────────────────
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

  // ── STATUS BADGE ─────────────────────────────────────────────────────────────
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

  // ========================= TECHNICIAN CELL ===========================================
  Widget _technicianCell(ComplaintModel c, ComplaintStatus status) {
    if (status == ComplaintStatus.pending) {
      return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => AssignTechnicianDialog(
              ticketId: c.ticketId,
              onAssign: (tech) async {
                try {
                  await _repo.assignTechnician(
                    // ticketId: c.ticketId,
                    ticketId: c.ticketId.isNotEmpty ? c.ticketId : c.id,
                    technicianId: int.parse(tech.id),
                    technicianName: tech.name,
                  );
                  if (!mounted) return;
                  _refresh();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${tech.name} assigned successfully'),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to assign: $e')),
                  );
                }
              },
            ),
          );
        },
        child: const Row(
          children: [
            Icon(
              Icons.person_add_alt_1_outlined,
              size: 16,
              color: Color(0xFFE8680A),
            ),
            SizedBox(width: 6),
            Text(
              'Assign',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE8680A),
              ),
            ),
          ],
        ),
      );
    }
    final initials = (c.technicianName != null && c.technicianName!.length >= 2)
        ? c.technicianName!.substring(0, 2).toUpperCase()
        : '?';

    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xFF3B82F6),
          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            c.technicianName ?? '—',
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // =========================TABLE ROW =====================================
  Widget _buildRow(ComplaintModel c) {
    final priority = _mapPriority(c.priorityLevel);
    final status = _mapStatus(c.techstatus);

    String formattedDate = c.createdAt;
    try {
      final dt = DateTime.parse(c.createdAt).toLocal();
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final minute = dt.minute.toString().padLeft(2, '0');
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      formattedDate =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}  $hour:$minute $amPm';
    } catch (_) {}

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ticket ID + timestamp
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.ticketId.isNotEmpty ? c.ticketId : '#${c.id}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 11,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Category
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.categoryName ?? '—',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  c.serviceRequired ?? '—',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Problem / issue description
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.problem ?? '—',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (c.date != null) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 11,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        c.date!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          Expanded(flex: 2, child: _priorityBadge(priority)),
          const SizedBox(width: 5),
          Expanded(flex: 2, child: _statusBadge(status)),
          const SizedBox(width: 5),

          Expanded(flex: 2, child: _technicianCell(c, status)),

          // // View Details
          // Expanded(
          //   flex: 1,
          //   child: PopupMenuButton<String>(
          //     icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
          //     onSelected: (value) {
          //       if (value == 'edit') {
          //         _handleEdit(c);
          //       } else if (value == 'delete') {
          //         _handleDelete(c);
          //       }
          //     },
          //     itemBuilder: (BuildContext context) => [
          //       const PopupMenuItem(
          //         value: 'edit',
          //         child: Row(
          //           children: [
          //             Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
          //             SizedBox(width: 8),
          //             Text('Edit'),
          //           ],
          //         ),
          //       ),
          //       const PopupMenuItem(
          //         value: 'delete',
          //         child: Row(
          //           children: [
          //             Icon(Icons.delete_outline, size: 18, color: Colors.red),
          //             SizedBox(width: 8),
          //             Text('Delete', style: TextStyle(color: Colors.red)),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  // ========================= BUILD ===================================
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ComplaintModel>>(
      future: _complaintsFuture,
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Error
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: const Row(
                  children: [
                    Expanded(flex: 3, child: _HeaderCell('TICKET')),
                    Expanded(flex: 3, child: _HeaderCell('CATEGORY')),
                    Expanded(flex: 4, child: _HeaderCell('PROBLEM')),
                    Expanded(flex: 2, child: _HeaderCell('PRIORITY')),
                    Expanded(flex: 2, child: _HeaderCell('STATUS')),
                    Expanded(flex: 3, child: _HeaderCell('TECHNICIAN')),
                 
                  ],
                ),
              ),

              // Empty state
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
                ...rows.map(_buildRow),
            ],
          ),
        );
      },
    );
  }

  
  Future<void> _handleDelete(ComplaintModel complaint) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Complaint'),
        content: Text(
          'Are you sure you want to delete ticket ${complaint.ticketId}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Assuming you have a delete method in your repository
        // await _repo.deleteComplaint(complaint.id);
        _refresh();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
      }
    }
  }
}

// ── HEADER CELL ───────────────────────────────────────────────────────────────
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

  //==========================edit delete menthod==============================
}
