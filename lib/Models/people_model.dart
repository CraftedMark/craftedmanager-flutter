class People {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String brand;
  final String? address1;
  final String? address2;
  final String? city;
  final String? state;
  final String? zip;
  final bool? customerBasedPricing;
  final String? accountNumber;
  final String? type;
  final String notes;
  final DateTime? createdDate;
  final String? createdBy;
  final DateTime? updatedDate;
  final String? updatedBy;

  People({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.brand,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.zip,
    this.customerBasedPricing,
    this.accountNumber,
    this.type,
    required this.notes,
    this.createdDate,
    this.createdBy,
    this.updatedDate,
    this.updatedBy,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'firstname': firstName,
    'lastname': lastName,
    'phone': phone,
    'email': email,
    'brand': brand,
    'address1': address1,
    'address2': address2,
    'city': city,
    'state': state,
    'zip': zip,
    'customerbasedpricing': customerBasedPricing ?? false,
    'accountnumber': accountNumber,
    'type': type,
    'notes': notes,
    'createddate': createdDate,
    'created_by': createdBy,
    'updateddate': updatedDate,
    'updated_by': updatedBy,
  };

  factory People.fromMap(Map<String, dynamic> map) {
    // Renamed from 'fromJson' to 'fromMap'
    return People(
      id: map['id'],
      firstName: map['firstname'],
      lastName: map['lastname'],
      phone: map['phone'],
      email: map['email'],
      brand: map['brand'],
      address1: map['address1'],
      address2: map['address2'] == null ? '' : map['address2'].toString(),
      city: map['city'],
      state: map['state'],
      zip: map['zip'],
      customerBasedPricing: map['customerbasedpricing'],
      accountNumber: map['accountnumber'],
      type: map['type'],
      notes: map['notes'],
      createdDate: map['createddate'],
      createdBy: map['created_by'] ?? 'Unknown',
      updatedDate: map['updateddate'],
      updatedBy: map['updated_by'] ?? 'Unknown',
    );
  }
  People copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? brand,
    String? address1,
    String? address2,
    String? city,
    String? state,
    String? zip,
    bool? customerBasedPricing,
    String? accountNumber,
    String? type,
    String? notes,
    DateTime? createdDate,
    String? createdBy,
    DateTime? updatedDate,
    String? updatedBy,
  }) {
    return People(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      brand: brand ?? this.brand,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
      customerBasedPricing: customerBasedPricing ?? this.customerBasedPricing,
      accountNumber: accountNumber ?? this.accountNumber,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      createdDate: createdDate ?? this.createdDate,
      createdBy: createdBy ?? this.createdBy,
      updatedDate: updatedDate ?? this.updatedDate,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}