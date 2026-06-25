import 'package:field_star/model/complaint_model.dart';
import 'package:field_star/model/customer_model.dart';
import 'package:field_star/model/tech_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TechnicianRepository {
  final _supabase = Supabase.instance.client;
  //=========================Edit and Delete Customer=================================
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

  
    if (response.isEmpty) {
      throw Exception('No row updated. Wrong id or RLS blocking.');
    }
  }

  Future<void> deleteCustomer({required dynamic id}) async {
    await _supabase.from('customer').delete().eq('id', id);
  }

  //============================insert technician===========================
  Future<void> registerTechnician(TechModel technician) async {
    try {
     
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
       
        response = await _supabase
            .from('Raise_complaint')
            .update({
              'technician_id': technicianId,
              'technician_name': technicianName,
              'tech_status': 'Pending',
            })
            .eq('id', int.tryParse(ticketId) ?? 0)
            .select();
      }

     
    } catch (e) {
     
      rethrow;
    }
  }

  //=======================Fetch complaint========================

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
      rethrow;
    }
  }

  //=====================Count technician=======================
  Future<Map<String, dynamic>> getTechnicianStats() async {
    final technicians = await _supabase.from('technician').select('id');

    final available = await _supabase
        .from('Raise_complaint')
        .select('technician_id')
        .eq('tech_status', 'Pending');

    final activeJobs = await _supabase
        .from('Raise_complaint')
        .select('technician_id')
        .eq('tech_status', 'Assigned');

    final ratings = await _supabase
        .from('service_ratings')
        .select('id,rating')
        .not('rating', 'is', null);

    double avgRating = 0;

    if (ratings.isNotEmpty) {
      final totalRating = ratings.fold<num>(
        0,
        (sum, item) => sum + ((item['rating'] as num?) ?? 0),
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
  //===================Register customer==================================

  Future<void> registerCustomerWithAuth({
    required String customerName,
    required String place,
    required String phone,
    required String location,
    required String hotelName,
    required int totalEquipment,
    required String email,
    required String password,
  }) async {
   
    final authResponse = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': customerName, 'role': 'customer'},
    );

    if (authResponse.user == null) {
      throw Exception('Failed to create auth user');
    }

    final userId = authResponse.user!.id;
  

    await _supabase
        .from('customer')
        .update({
          'cust_name': customerName,
          'cust_phno': phone,
          'cust_location': location,
          'cust_place': place,
          'cust_hotelname': hotelName,
          'total_equipment': totalEquipment,
        })
        .eq('id', userId); 

  }

  //========================Fetch customer================================
  Future<List<CustomerModel>> fetchcustomer() async {
  final response = await Supabase.instance.client
      .from('customer')
      .select(
        'id, cust_name, cust_phno, cust_location, cust_place, cust_hotelname, total_equipment, revenue_ytd, Raise_complaint(id, service_required)',
      );

  return response.map<CustomerModel>((e) {
    final complaints = e['Raise_complaint'] as List? ?? [];

    final equipmentCount = complaints
        .map((r) => r['service_required']?.toString().trim() ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .length;

    return CustomerModel.fromMap({
      ...e,
      'complaint_count': complaints.length,
      'equipment_count': equipmentCount,
    });
  }).toList();
}

//=======================Updated technician=======================
  Future<void> updatetechnician(TechModel technician) async {
    await _supabase
        .from('technician')
        .update(technician.toMap())
        .eq('id', technician.id!);
  }
//==================Delete technician=============================
  Future<void> deletetechnician({required dynamic id}) async {
    final int? parsedId = int.tryParse(id.toString());
    if (parsedId == null) {
      return;
    }
    await _supabase
        .from('Raise_complaint')
        .update({
          'technician_id': null,
          'tech_status': 'pending',
          'technician_name': null,
        })
        .eq('technician_id', parsedId);

  
    await _supabase.from('technician').delete().eq('id', parsedId);
  }


//==============================Get technician KPi box count==================================
  Future<Map<String, dynamic>> getActiveComplaintCount(String technicianId) async {
  final today = DateTime.now();
  final todayStr =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  final results = await Future.wait([
    // Active jobs
    _supabase
        .from('Raise_complaint')
        .select('id')
        .eq('technician_id', technicianId)
        .inFilter('tech_status', ['Assigned']),

    // Jobs today from service_ratings
    _supabase
        .from('service_ratings')
        .select('id')
        .eq('technician_id', technicianId)
        .eq('service_date', todayStr),

    // Ratings
    _supabase
        .from('service_ratings')
        .select('rating')
        .eq('technician_id', technicianId)
        .not('rating', 'is', null),
  ]);

  final activeJobs = (results[0] as List).length;
  final jobsToday = (results[1] as List).length;

  final ratings = results[2] as List;
  final avgRating = ratings.isEmpty
      ? 0.0
      : ratings.fold<double>(
              0, (sum, r) => sum + ((r['rating'] as num?)?.toDouble() ?? 0)) /
          ratings.length;

  return {
    'activeJobs': activeJobs,
    'jobsToday': jobsToday,
    'rating': double.parse(avgRating.toStringAsFixed(1)),
    'totalRatings': ratings.length,
  };
}
Future<double> getratings(String technicianId) async {
  final response = await _supabase
      .from('service_ratings')
      .select('rating')
      .eq('technician_id', technicianId)
      .not('rating', 'is', null);

  final ratings = response as List;

  if (ratings.isEmpty) return 0.0;

  final avg = ratings.fold<double>(
        0, (sum, r) => sum + ((r['rating'] as num?)?.toDouble() ?? 0),
      ) / ratings.length;

  return double.parse(avg.toStringAsFixed(1));
}

  //=================================Get dashboard count==============================================
  Future<Map<String, dynamic>> fetchDashboardStats(String technicianId) async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final yesterday = todayStart.subtract(const Duration(days: 1));

    // Single fetch — no login, so we work with ALL complaints
    final raw = await _supabase
        .from('Raise_complaint')
        .select('id, complaint_status, tech_status, created_at, technician_id');

    final all = raw as List;

    // ── Active (pending) ──────────────────────────────────────────────────────
    final activeTodayList = all
        .where((c) => c['complaint_status'] == 'pending')
        .toList();

    final activeYesterdayList = all.where((c) {
      if (c['complaint_status'] != 'pending') return false;
      final date = DateTime.tryParse(
        c['created_at']?.toString() ?? '',
      )?.toLocal();
      if (date == null) return false;
      return date.isAfter(yesterday) && date.isBefore(todayStart);
    }).toList();

    // ── Completed today ───────────────────────────────────────────────────────
    final completedTodayList = all.where((c) {
      if (c['complaint_status'] != 'pending') return false;
      final date = DateTime.tryParse(
        c['created_at']?.toString() ?? '',
      )?.toLocal();
      if (date == null) return false;
      return !date.isBefore(todayStart);
    }).toList();

    final completedYesterdayList = all.where((c) {
      if (c['complaint_status'] != 'Completed') return false;
      final date = DateTime.tryParse(
        c['created_at']?.toString() ?? '',
      )?.toLocal();
      if (date == null) return false;
      return date.isAfter(yesterday) && date.isBefore(todayStart);
    }).toList();

    // ── Technician counts ─────────────────────────────────────────────────────
    final activeTechnicianIds = all
        .where((c) => c['complaint_status'] == 'pending')
        .map((c) => c['technician_id'])
        .where((id) => id != null)
        .toSet();

    final allTechnicianIds = all
        .map((c) => c['technician_id'])
        .where((id) => id != null)
        .toSet();

    final offlineTechnicianIds = allTechnicianIds.difference(
      activeTechnicianIds,
    );

    // ── Trends ────────────────────────────────────────────────────────────────
    double complaintTrend = 0;
    if (activeYesterdayList.isNotEmpty) {
      complaintTrend =
          ((activeTodayList.length - activeYesterdayList.length) /
              activeYesterdayList.length) *
          100;
    }

    double completedTrend = 0;
    if (completedYesterdayList.isNotEmpty) {
      completedTrend =
          ((completedTodayList.length - completedYesterdayList.length) /
              completedYesterdayList.length) *
          100;
    }

    return {
      'activeComplaints': activeTodayList.length,
      'completedToday': completedTodayList.length,
      'activeTechnicians': activeTechnicianIds.length,
      'offlineTechnicians': offlineTechnicianIds.length,
      'complaintTrend': complaintTrend,
      'completedTrend': completedTrend,
    };
  }
//=======================save technician to the auth and technician tabel============================================
  Future<void> registerTechnicianWithAuth({
    required String fullName,
    required String techId,
    required String phone,
    required String location,
    required String specialization,
    required String email,
    required String password,
  }) async {
 
    final authResponse = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'role': 'technician'},
    );

    if (authResponse.user == null) {
      throw Exception('Failed to create auth user');
    }

    final userId = authResponse.user!.id;
   
    await _supabase.from('technician').insert({
      'Full_name': fullName,
      'TechID': techId,
      'Phone_no': phone,
      'Location': location,
      'Specialization': specialization,
      'user_id': userId, 
    });

  }
  //============================Fetch customer stats=========================
Future<Map<String, dynamic>> fetchCustomerStats() async {
  final results = await Future.wait([
    _supabase.from('customer').select('total_equipment, created_at'),
    _supabase
        .from('Raise_complaint')
        .select('service_required')
        .not('service_required', 'is', null),
  ]);

  final all = results[0] as List;
  final complaints = results[1] as List;

  final totalCustomers = all.length;

  
  final now = DateTime.now();
  final thisMonthStart = DateTime(now.year, now.month, 1);
  final thisMonthCount = all.where((c) {
    final created = DateTime.tryParse(c['created_at']?.toString() ?? '');
    return created != null && created.isAfter(thisMonthStart);
  }).length;

  final totalEquipment = all.fold<int>(
    0,
    (sum, c) => sum + ((c['total_equipment'] as num?)?.toInt() ?? 0),
  );
  final totalServiceEquipment = complaints.length;

 
 final distinctEquipmentTypes = complaints
    .map((c) {
      final raw = c['service_required']?.toString().trim() ?? '';
      return raw.contains(' - ') ? raw.split(' - ').first.trim() : raw;
    })
    .where((s) => s.isNotEmpty)
    .toSet();

  return {
    'totalCustomers': totalCustomers,
    'thisMonthCount': thisMonthCount,
    'totalEquipment': totalEquipment,
    'totalServiceEquipment': totalServiceEquipment,      
    'distinctEquipmentTypes': distinctEquipmentTypes,     
    'distinctEquipmentCount': distinctEquipmentTypes.length,
  };
}
}
