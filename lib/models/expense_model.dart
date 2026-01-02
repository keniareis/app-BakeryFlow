class Expense {
  final int? id;
  final String description;
  final double value;
  final DateTime date;

  Expense({
    this.id,
    required this.description,
    required this.value,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'value': value,
      'date': date.millisecondsSinceEpoch, 
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      description: map['description'],
      value: map['value'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']), 
    );
  }
}
