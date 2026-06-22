import 'package:field_star/model/complaint_model.dart';
import 'package:field_star/model/customer_model.dart';
import 'package:field_star/model/tech_model.dart';
import 'package:field_star/pages/Technician/technician.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TechnicianRepository {
  final _supabase = Supabase.instance.client;
  
Future<void> updateCustomer({
  required String? id,
  required String customerName,
  required String phone,
  required String hotelName,
  required String location,
}) async {
  if (id == null || id.isEmpty) {
    throw Exception('Customer id is null');
  }

  final response = await Supabase.instance.client
      .from('customer')
      .update({
        'cust_name': customerName,
        'cust_phno': phone,
        'cust_hotelname': hotelName,
        'cust_location': location,
      })
      .eq('id', id)
      .select();

  print('UPDATE RESPONSE: $response');

  if (response.isEmpty) {
    throw Exception('No row updated. Wrong id or RLS blocking.');
  }
}
Future<void> deleteCustomer({required dynamic id}) async {
  await _supabase
      .from('customer')   // ← replace with your table name
      .delete()
      .eq('id', id);
}

  //============================insert technician===========================
  // Change the method signature to use TechModel
  Future<void> registerTechnician(TechModel technician) async {
    try {
      // This will now work because .toMap() exists in TechModel
      await _supabase.from('technician').insert(technician.toMap());
    } catch (e) {
      throw Exception('Failed to register technician: $e');
    }
  }
  //========================Fetch Technician =================================

  Future<List<TechModel>> fetchTechnicians() async {
    final response = await _supabase.from('technician').select('*');
    return (response as List<dynamic>)
        .map((tech) => TechModel.fromMap(tech))
        .toList();
  }

  //========================Asign technician==============================
  // technician_repository.dart
  Future<void> assignTechnician({
    required String ticketId,
    required int technicianId,
    required String technicianName,
  }) async {
    print('>>> ticketId received: "$ticketId"'); // add this
    print('>>> technicianId: $technicianId');
    print('>>> technicianName: $technicianName');
    try {
      var response = await _supabase
          .from('Raise_complaint')
          .update({
            'technician_id': technicianId,
            'technician_name': technicianName,
            'tech_status': 'Assigned',
          })
          .eq('tickectid', ticketId)
          .select();

      if (response.isEmpty) {
        print(' tickectid match failed, trying id column...');
        response = await _supabase
            .from('Raise_complaint')
            .update({
              'technician_id': technicianId,
              'technician_name': technicianName,
              'tech_status': 'Assigned',
            })
            .eq('id', int.tryParse(ticketId) ?? 0)
            .select();
      }

      if (response.isEmpty) {
        print(' Still no rows matched');
      } else {
        print('Updated ${response.length} row(s): $response');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  //=======================Fetch complaint========================
  // In technician_repository.dart

  Future<List<ComplaintModel>> fetchComplaints() async {
    try {
      final response = await _supabase
          .from('Raise_complaint')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ComplaintModel.fromJson(json))
          .toList();
    } catch (e) {
      print('fetchComplaints error: $e');
      rethrow;
    }
  }

  //=====================Count technician=======================
Future<Map<String, dynamic>> getTechnicianStats() async {
  final technicians = await _supabase
      .from('technician')
      .select('id');

  final available = await _supabase
      .from('Raise_complaint')
      .select('technician_id')
      .eq('tech_status', '');

  final activeJobs = await _supabase
      .from('Raise_complaint')
      .select('technician_id')
      .eq('tech_status', 'Assigned');

  final ratings = await _supabase
      .from('service_ratings')
      .select('id,rating');

  double avgRating = 0;

  if (ratings.isNotEmpty) {
    final totalRating = ratings.fold<int>(
      0,
      (sum, item) => sum + ((item['rating'] ?? 0) as int),
    );

    avgRating = totalRating / ratings.length;
  }

  return {
    'total': technicians.length,
    'available': available.length,
    'activeJobs': activeJobs.length,
    'avgRating': avgRating.toStringAsFixed(1),
  };
}
  //===================Register customer====================

  Future<void> registerCustomer(CustomerModel cust) async {
    try {
      await _supabase.from('customer').insert(cust.toMap());
    } catch (e) {
      throw Exception('Failed to register technician: $e');
    }
  }

  //========================Fetch customer==========
 Future<List<CustomerModel>> fetchcustomer() async {
  final response = await Supabase.instance.client
      .from('customer')
      .select('id, cust_name, cust_phno, cust_location, cust_place, cust_hotelname, total_equipment, revenue_ytd');

  return response.map<CustomerModel>((e) {
    return CustomerModel.fromMap(e);
  }).toList();
}

  //=======================Updated technician=======================
  Future<void> updatetechnician(TechModel technician) async {
    await _supabase
        .from('technician')
        .update(technician.toMap())
        .eq('id', technician.id!);
  }

  Future<int> getPendingComplaintCount(String technicianId) async {
    final response = await _supabase
        .from('Raise_complaint')
        .select('id')
        .eq('technician_id', technicianId)
        .eq('tech_status', 'Pending');

    return response.length;
  }

  Future<int> getTodayComplaintCount(String technicianId) async {
    final today = DateTime.now().toIso8601String().split('T').first;

    final response = await _supabase
        .from('Raise_complaint')
        .select('id')
        .eq('technician_id', technicianId)
        .eq('Date', today)
        .eq('tech_status', 'Pending');

    return response.length;
  }

  Future<int> getActiveComplaintCount(String technicianId) async {
    final response = await _supabase
        .from('Raise_complaint')
        .select('id')
        .eq('technician_id', technicianId)
        .inFilter('tech_status', ['Pending', 'Assigned']);

    return response.length;
  }

  //=================================Get dashboard count==============================================
Future<Map<String, dynamic>> fetchDashboardStats(String technicianId) async {
  print('fetchDashboardStats called with: "$technicianId"'); // ← add this
  
  final int? techId = int.tryParse(technicianId); // ← tryParse instead of parse
  
  // Guard — if id is invalid, return zeros instead of crashing
  if (techId == null || techId == 0) {
    print('Invalid technicianId: "$technicianId" — returning zeros');
    return {
      'activeComplaints': 0,
      'completedToday': 0,
      'activeTechnicians': 0,
      'offlineTechnicians': 0,
      'complaintTrend': 0.0,
      'completedTrend': 0.0,
    };
  }

  final today = DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);
  final yesterday = todayStart.subtract(const Duration(days: 1));

  final allComplaintsRaw = await _supabase
      .from('Raise_complaint')
      .select('id, complaint_status, tech_status, created_at, technician_id');

  final myComplaintsRaw = await _supabase
      .from('Raise_complaint')
      .select('id, complaint_status, tech_status, created_at,');
     

  final allComplaints = allComplaintsRaw as List;
  final myComplaints  = myComplaintsRaw  as List;

  print('All complaints: ${allComplaints.length}');
  print('My complaints: ${myComplaints.length}');
  print('My statuses: ${myComplaints.map((c) => c['complaint_status']).toSet()}');

  final activeTodayList = myComplaints
      .where((c) => c['complaint_status'] == 'pending')
      .toList();

  final activeYesterdayList = myComplaints.where((c) {
    if (c['complaint_status'] != 'pending') return false;
    final date = DateTime.tryParse(c['created_at']?.toString() ?? '')?.toLocal();
    if (date == null) return false;
    return date.isAfter(yesterday) && date.isBefore(todayStart);
  }).toList();

  final completedTodayList = myComplaints.where((c) {
    if (c['complaint_status'] != 'Completed') return false;
    final date = DateTime.tryParse(c['created_at']?.toString() ?? '')?.toLocal();
    if (date == null) return false;
    return !date.isBefore(todayStart);
  }).toList();

  final completedYesterdayList = myComplaints.where((c) {
    if (c['complaint_status'] != 'Completed') return false;
    final date = DateTime.tryParse(c['created_at']?.toString() ?? '')?.toLocal();
    if (date == null) return false;
    return date.isAfter(yesterday) && date.isBefore(todayStart);
  }).toList();

  final activeTechnicianIds = allComplaints
      .where((c) => c['complaint_status'] == 'pending')
      .map((c) => c['technician_id'])
      .where((id) => id != null)
      .toSet();

  final allTechnicianIds = allComplaints
      .map((c) => c['technician_id'])
      .where((id) => id != null)
      .toSet();

  final offlineTechnicianIds = allTechnicianIds.difference(activeTechnicianIds);

  double complaintTrend = 0;
  if (activeYesterdayList.isNotEmpty) {
    complaintTrend = ((activeTodayList.length - activeYesterdayList.length) /
        activeYesterdayList.length) * 100;
  }

  double completedTrend = 0;
  if (completedYesterdayList.isNotEmpty) {
    completedTrend = ((completedTodayList.length - completedYesterdayList.length) /
        completedYesterdayList.length) * 100;
  }

  return {
    'activeComplaints': activeTodayList.length,
    'completedToday':   completedTodayList.length,
    'activeTechnicians': activeTechnicianIds.length,
    'offlineTechnicians': offlineTechnicianIds.length,
    'complaintTrend': complaintTrend,
    'completedTrend': completedTrend,
  };
}

}

