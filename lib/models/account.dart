class Account {
  final int id;
  final String accountNumber;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final double balance;
  final String? createdAt;

  const Account({
    required this.id,
    required this.accountNumber,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.balance,
    this.createdAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: int.parse(json['id'].toString()),
      accountNumber: json['account_number'].toString(),
      firstName: json['first_name'].toString(),
      lastName: json['last_name'].toString(),
      email: json['email'].toString(),
      phone: json['phone'].toString(),
      balance: double.parse(json['balance'].toString()),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_number': accountNumber,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'balance': balance,
      'created_at': createdAt,
    };
  }
}
//hahahah
