class Transaction {
  final int id;
  final int accountId;
  final String type;
  final double amount;
  final String? note;
  final DateTime createdAt;
  final String accountNumber;
  final String firstName;
  final String lastName;

  Transaction({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    this.note,
    required this.createdAt,
    required this.accountNumber,
    required this.firstName,
    required this.lastName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: int.parse(json['id'].toString()),
      accountId: int.parse(json['account_id'].toString()),
      type: json['type'].toString(),
      amount: double.parse(json['amount'].toString()),
      note: json['note']?.toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
      accountNumber: json['account_number'].toString(),
      firstName: json['first_name'].toString(),
      lastName: json['last_name'].toString(),
    );
  }
}