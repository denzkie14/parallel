class Customer {
  final int id;
  final String lastName;
  final String firstName;
  final DateTime dateOrdered;

  Customer({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.dateOrdered,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as int,
      lastName: json['last_name'] as String,
      firstName: json['first_name'] as String,
      dateOrdered: json['dateOrdered'] as DateTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'last_name': lastName,
      'first_name': firstName,
      'dateOrdered': dateOrdered,
    };
  }
}
