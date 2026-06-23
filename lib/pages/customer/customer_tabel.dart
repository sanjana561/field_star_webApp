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

  void _refresh() => setState(() {
        _customerFuture = _repo.fetchcustomer();
      });

  List<CustomerModel> _applySearch(List<CustomerModel> all) {
    if (widget.searchQuery.isEmpty) return all;
    final q = widget.searchQuery.toLowerCase();
    return all
        .where((c) =>
            c.customerName.toLowerCase().contains(q) ||
            c.phone.toLowerCase().contains(q) ||
            c.hotelName.toLowerCase().contains(q) ||
            c.location.toLowerCase().contains(q))
        .toList();
  }

  String _initial(CustomerModel c) => c.customerName.trim().isEmpty
      ? '?'
      : c.customerName.trim()[0].toUpperCase();

  // ── CUSTOMER CELL (avatar + location + hotel) ─────────────────────────────
  Widget _customerCell(CustomerModel c) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xFF3B82F6),
          child: Text(
            _initial(c),
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                c.location,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                c.hotelName,
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── CONTACT CELL (name + phone) ───────────────────────────────────────────
  Widget _contactCell(CustomerModel c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          c.customerName,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        Text(
          c.phone,
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  // ── EQUIPMENT CELL ────────────────────────────────────────────────────────
  Widget _equipmentCell(CustomerModel c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${c.totalEquipment}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3B82F6),
          ),
        ),
        const Text(
          'units',
          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  // ── COMPLAINTS CELL ───────────────────────────────────────────────────────
  Widget _complaintsCell(CustomerModel c) {
    return Text(
      '${c.complaintCount} active',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: c.complaintCount > 0
            ? const Color(0xFFE8680A)
            : const Color(0xFF64748B),
      ),
    );
  }

  // ── ACTIONS CELL (popup menu) ─────────────────────────────────────────────
  Widget _actionsCell(BuildContext context, CustomerModel c) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') _showEditDialog(context, c);
        if (value == 'delete') _showDeleteConfirm(context, c);
      },
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      offset: const Offset(-80, 10),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          height: 42,
          child: Row(
            children: const [
              Icon(Icons.edit_outlined, size: 16, color: Color(0xFF3B82F6)),
              SizedBox(width: 10),
              Text('Edit',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0F172A))),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: 'delete',
          height: 42,
          child: Row(
            children: const [
              Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
              SizedBox(width: 10),
              Text('Delete',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFEF4444))),
            ],
          ),
        ),
      ],
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Actions',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B82F6))),
          SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded,
              size: 16, color: Color(0xFF3B82F6)),
        ],
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CustomerModel>>(
      future: _customerFuture,
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
                  const Icon(Icons.error_outline,
                      color: Color(0xFFE05252), size: 32),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load customers\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF94A3B8)),
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
                    child: Text('No Customer found.',
                        style: TextStyle(
                            color: Color(0xFF94A3B8), fontSize: 14)),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: const Color(0xFFEEEEEE),
                    ),
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
                      // ── Columns ───────────────────────────────────────
                      columns: const [
                        DataColumn(label: Text('CUSTOMER')),
                        DataColumn(label: Text('CONTACT')),
                        DataColumn(label: Text('EQUIPMENT')),
                        DataColumn(label: Text('COMPLAINTS')),
                        DataColumn(label: Text('ACTIONS')),
                      ],
                      // ── Rows ──────────────────────────────────────────
                      rows: rows.map((c) {
                        return DataRow(
                          cells: [
                            DataCell(_customerCell(c)),
                            DataCell(_contactCell(c)),
                            DataCell(_equipmentCell(c)),
                            DataCell(_complaintsCell(c)),
                            DataCell(_actionsCell(context, c)),
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

  // ── EDIT DIALOG ───────────────────────────────────────────────────────────
  void _showEditDialog(BuildContext context, CustomerModel c) {
    final nameCtrl = TextEditingController(text: c.customerName);
    final phoneCtrl = TextEditingController(text: c.phone);
    final hotelCtrl = TextEditingController(text: c.hotelName);
    final locationCtrl = TextEditingController(text: c.location);
    final formKey = GlobalKey<FormState>();
    bool saving = false;

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
                  borderRadius: BorderRadius.circular(16)),
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
                            child: const Icon(Icons.edit_outlined,
                                size: 18, color: Color(0xFF3B82F6)),
                          ),
                          const SizedBox(width: 12),
                          const Text('Edit Customer',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A))),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close,
                                size: 18, color: Color(0xFF94A3B8)),
                            onPressed: () => Navigator.pop(ctx),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _editField(nameCtrl, 'Customer Name',
                          Icons.person_outline, 'Enter name'),
                      const SizedBox(height: 14),
                      _editField(phoneCtrl, 'Phone', Icons.phone_outlined,
                          'Enter phone',
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 14),
                      _editField(hotelCtrl, 'Hotel / Company',
                          Icons.business_outlined, 'Enter hotel name'),
                      const SizedBox(height: 14),
                      _editField(locationCtrl, 'Location',
                          Icons.location_on_outlined, 'Enter location'),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed:
                                  saving ? null : () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                side: const BorderSide(
                                    color: Color(0xFFE2E8F0)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Cancel',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B))),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: saving
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate())
                                        return;
                                      final nav = Navigator.of(context);
                                      final messenger =
                                          ScaffoldMessenger.of(context);
                                      setLocal(() => saving = true);
                                      try {
                                        await _repo.updateCustomer(
                                          id: c.id,
                                          customerName: nameCtrl.text.trim(),
                                          phone: phoneCtrl.text.trim(),
                                          hotelName: hotelCtrl.text.trim(),
                                          location: locationCtrl.text.trim(),
                                        );
                                        nav.pop();
                                        await Future.delayed(Duration.zero);
                                        _refresh();
                                        messenger.showSnackBar(const SnackBar(
                                          content: Text('Customer updated'),
                                          backgroundColor: Color(0xFF22C55E),
                                          behavior: SnackBarBehavior.floating,
                                        ));
                                      } catch (e) {
                                        setLocal(() => saving = false);
                                        messenger.showSnackBar(SnackBar(
                                          content: Text('Failed: $e'),
                                          backgroundColor:
                                              const Color(0xFFEF4444),
                                          behavior: SnackBarBehavior.floating,
                                        ));
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: saving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white))
                                  : const Text('Save Changes',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
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

  // ── DELETE DIALOG ─────────────────────────────────────────────────────────
  void _showDeleteConfirm(BuildContext context, CustomerModel c) {
    bool deleting = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Center(
          child: SizedBox(
            width: 440,
            child: Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete_outline,
                          size: 26, color: Color(0xFFEF4444)),
                    ),
                    const SizedBox(height: 16),
                    const Text('Delete Customer',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 8),
                    Text(
                      'Are you sure you want to delete "${c.customerName}"? This cannot be undone.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                deleting ? null : () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(
                                  color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Cancel',
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFF64748B))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: deleting
                                ? null
                                : () async {
                                    final nav = Navigator.of(context);
                                    final messenger =
                                        ScaffoldMessenger.of(context);
                                    final name = c.customerName;
                                    setLocal(() => deleting = true);
                                    try {
                                      await _repo.deleteCustomer(id: c.id);
                                      nav.pop();
                                      await Future.delayed(Duration.zero);
                                      _refresh();
                                      messenger.showSnackBar(SnackBar(
                                        content: Text('"$name" deleted'),
                                        backgroundColor:
                                            const Color(0xFFEF4444),
                                        behavior: SnackBarBehavior.floating,
                                      ));
                                    } catch (e) {
                                      setLocal(() => deleting = false);
                                      messenger.showSnackBar(SnackBar(
                                        content: Text('Failed: $e'),
                                        backgroundColor:
                                            const Color(0xFFEF4444),
                                        behavior: SnackBarBehavior.floating,
                                      ));
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: deleting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Text('Delete',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── FIELD BUILDER ─────────────────────────────────────────────────────────
  Widget _editField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF475569))),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(fontSize: 13, color: Color(0xFFCBD5E1)),
              prefixIcon:
                  Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                      color: Color(0xFF3B82F6), width: 1.5)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFEF4444))),
            ),
          ),
        ],
      );
}