class ComplaintModel {
  final String id;
  final String ticketId;
  final String createdAt;
  final String? categoryName;
  final String? serviceRequired;
  final String? problem;
  final String? priorityLevel;
  final String? date;
  final String? imageUrl;
  final String? audioUrl;
  final String? otp;
  final int? technicianId;
  final String? technicianName;
  final String techstatus;
  final String?complaintstatus;

  ComplaintModel({
    required this.id,
    required this.ticketId,
    required this.createdAt,
    this.categoryName,
    this.serviceRequired,
    this.problem,
    this.priorityLevel,
    this.date,
    this.imageUrl,
    this.audioUrl,
    this.otp,
    this.technicianId,
    this.technicianName,
    required this.techstatus, this.complaintstatus,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'].toString(),
      ticketId: json['tickectid'] ?? '',       
      createdAt: json['created_at'] ?? '',
      categoryName: json['Category_name'],
      serviceRequired: json['service_required'],
      problem: json['problem'],
      priorityLevel: json['priority_level'],
      date: json['Date'],
      imageUrl: json['image_url'],
      audioUrl: json['audio_url'],
      otp: json['otp'],
      technicianId: json['technician_id'],
      technicianName: json['technician_name'],
      techstatus: json['tech_status'] ?? 'Pending',
      complaintstatus: json['complaint_status']??'pending'
    );
  }
}