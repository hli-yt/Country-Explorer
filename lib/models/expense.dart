class Expense {
  final int? id;
  final double amount;
  final String category;
  final String note;
  final String date; // ISO-8601 string

  Expense({
    this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'note': note,
      'date': date,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      note: map['note'],
      date: map['date'],
    );
  }
}
