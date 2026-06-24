class TechModel {
  final String? id;
  final String fullName;
  final String techId;
  final String phone;
  final String location;
  final String specialization;

 
  TechModel({
    required this.fullName,
    required this.techId,
    required this.phone,
    required this.location,
    required this.specialization,
     this.id,
  });
  factory TechModel.fromMap(Map<String, dynamic> map) {
    return TechModel(
      id: map['id']?.toString(),
      fullName: map['Full_name'] ?? '',
      techId: map['TechID'] ?? '',
      phone: map['Phone_no'] ?? '',
      location: map['Location'] ?? '',
      specialization: map['Specialization'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Full_name': fullName,
      'TechID': techId,
      'Phone_no': phone,
      'Location': location,
      'Specialization': specialization,
    };
  }
}