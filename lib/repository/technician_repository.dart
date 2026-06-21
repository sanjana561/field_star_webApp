import 'package:field_star/model/complaint_model.dart';
import 'package:field_star/model/customer_model.dart';
import 'package:field_star/model/tech_model.dart';
import 'package:field_star/pages/Technician/technician.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TechnicianRepository {
  final _supabase = Supabase.instance.client;

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
    final technicians = await _supabase.from('technician').select('id');

    final available = await _supabase
        .from('technician')
        .select('id')
        .eq('techstatus', 'AVAILABLE');

    final activeJobs = await _supabase
        .from('Raise_complaint')
        .select('id')
        .eq('tech_status', 'Assigned');

    return {
      'total': technicians.length,
      'available': available.length,
      'activeJobs': activeJobs.length,
      'avgRating': 4.7,
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
    try {
      final customers = await _supabase
          .from('customer')
          .select('*, Raise_complaint(id)')
          .order('created_at', ascending: false);

      return (customers as List).map((json) {
        final complaints = json['Raise_complaint'] as List? ?? [];
        final enriched = Map<String, dynamic>.from(json);
        enriched['complaint_count'] = complaints.length;
        return CustomerModel.fromMap(enriched);
      }).toList();
    } catch (e) {
      print('fetchcustomer error: $e');
      rethrow;
    }
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

 Future<Map<String, dynamic>> fetchDashboardStats(String technicianId) async {
  final today = DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);
  final yesterday = todayStart.subtract(const Duration(days: 1));

  // Active complaints (pending) assigned to this technician
  final activeToday = await _supabase
      .from('Raise_complaint')
      .select('id')
      .eq('technician_id', technicianId)
      .eq('complaint_status', 'pending');

  // Active complaints yesterday
  final activeYesterday = await _supabase
      .from('Raise_complaint')
      .select('id')
      .eq('technician_id', technicianId)
      .eq('complaint_status', 'pending')
      .lt('created_at', todayStart.toIso8601String())
      .gte('created_at', yesterday.toIso8601String());

  // Completed today
  final completedToday = await _supabase
      .from('Raise_complaint')
      .select('id')
      .eq('technician_id', technicianId)
      .eq('complaint_status', 'Completed')
      .gte('created_at', todayStart.toIso8601String());

  // Completed yesterday
  final completedYesterday = await _supabase
      .from('Raise_complaint')
      .select('id')
      .eq('technician_id', technicianId)
      .eq('complaint_status', 'Completed')
      .lt('created_at', todayStart.toIso8601String())
      .gte('created_at', yesterday.toIso8601String());

  // Active technicians from technician table
  final activeTechnicians = await _supabase
      .from('technician')
      .select('id')
      .eq('status', 'Available');

  // Offline technicians
  final offlineTechnicians = await _supabase
      .from('technician')
      .select('id')
      .eq('status', 'Offline');

  double complaintTrend = 0;
  if (activeYesterday.isNotEmpty) {
    complaintTrend =
        ((activeToday.length - activeYesterday.length) /
            activeYesterday.length) *
        100;
  }

  double completedTrend = 0;
  if (completedYesterday.isNotEmpty) {
    completedTrend =
        ((completedToday.length - completedYesterday.length) /
            completedYesterday.length) *
        100;
  }

  return {
    'activeComplaints': activeToday.length,
    'completedToday': completedToday.length,
    'activeTechnicians': activeTechnicians.length,
    'offlineTechnicians': offlineTechnicians.length,
    'complaintTrend': complaintTrend,
    'completedTrend': completedTrend,
  };
}
}
