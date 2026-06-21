class CustomerModel {
  final String? id;
  final String customerName;
  final String phone;
  final String location;
  final String place;
  final String hotelName;
  final int totalEquipment;
  final double revenueYtd;
   final int complaintCount; 

  CustomerModel({
    this.id,
    required this.customerName,
    required this.phone,
    required this.location,
    required this.place,
    required this.hotelName,
    required this.totalEquipment,
    required this.revenueYtd,
   this.complaintCount = 0,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id']?.toString(),
      customerName: map['cust_name'] ?? '',
      phone: map['cust_phno'] ?? '',
      location: map['cust_location'] ?? '',
      place: map['cust_place'] ?? '',
      hotelName: map['cust_hotelname'] ?? '',
      totalEquipment: (map['total_equipment'] as num?)?.toInt() ?? 0,
      revenueYtd: (map['revenue_ytd'] as num?)?.toDouble() ?? 0.0,
      complaintCount: (map['complaint_count'] as num?)?.toInt() ?? 0,
      
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cust_name': customerName,
      'cust_phno': phone,
      'cust_location': location,
      'cust_place': place,
      'cust_hotelname': hotelName,
      'total_equipment': totalEquipment,
      'revenue_ytd': revenueYtd,
    };
  }
}