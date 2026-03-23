class Vendor {
  final String id;
  final String companyName;
  final String? email;
  final String? location;
  final String? address;
  final String? contactPerson;
  final String? contactNumber;
  final String? profileName;
  final List<String> categories;
  final List<String> subCategories;
  final List<String> projects;
  final String? suggestedBy;
  final String? websiteUrl;
  final String? linkedinUrl;
  final String? profileDocType;
  final String? profileDocValue;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Vendor({
    required this.id,
    required this.companyName,
    this.email,
    this.location,
    this.address,
    this.contactPerson,
    this.contactNumber,
    this.profileName,
    this.categories = const [],
    this.subCategories = const [],
    this.projects = const [],
    this.suggestedBy,
    this.websiteUrl,
    this.linkedinUrl,
    this.profileDocType,
    this.profileDocValue,
    this.createdAt,
    this.updatedAt,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      return [];
    }

    return Vendor(
      id: json['id']?.toString() ?? '',
      companyName: json['company_name'] ?? '',
      email: json['email'],
      location: json['location'],
      address: json['address'],
      contactPerson: json['contact_person'],
      contactNumber: json['contact_number'],
      profileName: json['profile_name'],
      categories: parseList(json['categories']),
      subCategories: parseList(json['sub_categories']),
      projects: parseList(json['projects']),
      suggestedBy: json['suggested_by'],
      websiteUrl: json['website_url'],
      linkedinUrl: json['linkedin_url'],
      profileDocType: json['profile_doc_type'],
      profileDocValue: json['profile_doc_value'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }
}
