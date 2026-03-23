class Expense {
  final int id;
  final int userId;
  final String userName;
  final String email;
  final double amount;
  final String category;
  final String description;
  final String? receiptUrl;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Specific expense fields
  final String? location;
  final String? travelType;
  final String? fromLocation;
  final String? toLocation;
  final double? km;
  final double? tollAmount;
  final String? checkIn;
  final String? checkOut;

  Expense({
    required this.id,
    required this.userId,
    required this.userName,
    required this.email,
    required this.amount,
    required this.category,
    required this.description,
    this.receiptUrl,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.location,
    this.travelType,
    this.fromLocation,
    this.toLocation,
    this.km,
    this.tollAmount,
    this.checkIn,
    this.checkOut,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId:
          int.tryParse(
            json['user_id']?.toString() ?? json['userId']?.toString() ?? '0',
          ) ??
          0,
      userName:
          json['employee_name']?.toString() ??
          json['user_name']?.toString() ??
          json['userName']?.toString() ??
          'Unknown',
      email: json['email']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      category: json['category']?.toString() ?? 'Other',
      description:
          json['other_description']?.toString() ??
          json['description']?.toString() ??
          '',
      receiptUrl:
          json['bill_url']?.toString() ??
          json['receipt_url']?.toString() ??
          json['receiptUrl']?.toString(),
      status: json['status']?.toString() ?? 'Completed',
      location: json['location']?.toString(),
      travelType: json['travel_type']?.toString(),
      fromLocation: json['from_location']?.toString(),
      toLocation: json['to_location']?.toString(),
      km: double.tryParse(json['km']?.toString() ?? ''),
      tollAmount: double.tryParse(json['toll_amount']?.toString() ?? ''),
      checkIn: json['check_in']?.toString(),
      checkOut: json['check_out']?.toString(),
      createdAt: json['created_at'] != null || json['timestamp'] != null
          ? DateTime.tryParse(
                  (json['created_at'] ?? json['timestamp']).toString(),
                ) ??
                DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}
