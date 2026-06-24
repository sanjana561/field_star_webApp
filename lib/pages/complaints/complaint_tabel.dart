// lib/pages/complaints/complaints_table.dart

import 'package:field_star/model/complaint_model.dart';
import 'package:field_star/pages/complaints/assign_tech.dart';
import 'package:field_star/repository/technician_repository.dart';
import 'package:flutter/material.dart';

enum Priority { high, medium, low }
enum ComplaintStatus { pending, assigned, inProgress, completed }

Priority _mapPriority(String? val) {
  switch (val?.toLowerCase()) {
    case 'high': return Priority.high;
    case 'medium': return Priority.medium;
    default: return Priority.low;
  }
}

ComplaintStatus _mapStatus(String? val) {
  switch (val?.toLowerCase()) {
    case 'assigned': return ComplaintStatus.assigned;
    case 'in progress': return ComplaintStatus.inProgress;
    case 'completed': return ComplaintStatus.completed;
    default: return ComplaintStatus.pending;
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

  void _refresh() => setState(() {
        _complaintsFuture = _repo.fetchComplaints();
      });
//========================search bar function=============================================
  List<ComplaintModel> _applySearch(List<ComplaintModel> all) {
    if (widget.searchQuery.isEmpty) return all;
    final q = widget.searchQuery.toLowerCase();
    return all
        .where((c) =>
            c.ticketId.toLowerCase().contains(q) ||
            (c.categoryName?.toLowerCase().contains(q) ?? false) ||
            (c.serviceRequired?.toLowerCase().contains(q) ?? false) ||
            (c.problem?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  // ── PRIORITY BADGE ───────────────────────────────────────────────────────────
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
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textColor)),
    );
  }

  // ============== STATUS BADGE ====================================
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
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textColor)),
    );
  }

  // ── TECHNICIAN CELL ──────────────────────────────────────────────────────────
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
                    ticketId: c.ticketId.isNotEmpty ? c.ticketId : c.id,
                    technicianId: int.parse(tech.id),
                    technicianName: tech.name,
                  );
                  if (!mounted) return;
                  _refresh();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${tech.name} assigned successfully')),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_add_alt_1_outlined, size: 16, color: Color(0xFFE8680A)),
            SizedBox(width: 6),
            Text('Assign',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFE8680A))),
          ],
        ),
      );
    }

    final initials = (c.technicianName != null && c.technicianName!.length >= 2)
        ? c.technicianName!.substring(0, 2).toUpperCase()
        : '?';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: const Color(0xFF3B82F6),
          child: Text(initials,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
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

  // ── TICKET CELL (ID + timestamp) ─────────────────────────────────────────────
  Widget _ticketCell(ComplaintModel c) {
    String formattedDate = c.createdAt;
    try {
      final dt = DateTime.parse(c.createdAt).toLocal();
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final minute = dt.minute.toString().padLeft(2, '0');
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      formattedDate =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}  $hour:$minute $amPm';
    } catch (_) {}

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          c.ticketId.isNotEmpty ? c.ticketId : '#${c.id}',
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            const Icon(Icons.access_time_rounded, size: 11, color: Color(0xFF94A3B8)),
            const SizedBox(width: 3),
            Flexible(
              child: Text(formattedDate,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ],
    );
  }

  // ── CATEGORY CELL ────────────────────────────────────────────────────────────
  Widget _categoryCell(ComplaintModel c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          c.categoryName ?? '—',
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 3),
        Text(
          c.serviceRequired ?? '—',
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ── PROBLEM CELL ─────────────────────────────────────────────────────────────
  Widget _problemCell(ComplaintModel c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          c.problem ?? '—',
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
          overflow: TextOverflow.ellipsis,
        ),
        if (c.date != null) ...[
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 11, color: Color(0xFF94A3B8)),
              const SizedBox(width: 3),
              Text(c.date!,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            ],
          ),
        ],
      ],
    );
  }

  // ── BUILD ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
//=============================Fetch complaints===========================================
    return FutureBuilder<List<ComplaintModel>>(
      future: _complaintsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
                padding: EdgeInsets.all(40), child: CircularProgressIndicator()),
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
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (rows.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text('No complaints found.',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: const Color(0xFFEEEEEE),
                    ),
//=========================Datatabel=======================================================
                    child: DataTable(
                      columnSpacing: 16,
                      horizontalMargin: 20,
                      headingRowHeight: 42,
                      dataRowMinHeight: 60,  
                      dataRowMaxHeight: 64,
                      dividerThickness: 1,
                      headingRowColor: WidgetStateProperty.all(
                        const Color(0xFFFAFAFA),
                      ),
                      headingTextStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                      // ── Columns ──────────────────────────────────────────
                      columns: const [
                        DataColumn(label: Text('TICKET')),
                        DataColumn(label: Text('CATEGORY')),
                        DataColumn(label: Text('PROBLEM')),
                        DataColumn(label: Text('PRIORITY')),
                        DataColumn(label: Text('STATUS')),
                        DataColumn(label: Text('TECHNICIAN')),
                      ],
                      // ── Rows ─────────────────────────────────────────────
                      rows: rows.map((c) {
                        final priority = _mapPriority(c.priorityLevel);
                        final status = _mapStatus(c.techstatus);
                        return DataRow(
                          cells: [
                            DataCell(_ticketCell(c)),
                            DataCell(_categoryCell(c)),
                            DataCell(_problemCell(c)),
                            DataCell(_priorityBadge(priority)),
                            DataCell(_statusBadge(status)),
                            DataCell(_technicianCell(c, status)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}