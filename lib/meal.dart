class Meal {
  final String id;
  final String type; // "Breakfast" | "Lunch" | "Dinner" | "Snack"
  final String name;
  final String location;
  final double amount;
  final String note;
  final DateTime createdAt;

  Meal({
    required this.id,
    required this.type,
    required this.name,
    required this.location,
    required this.amount,
    required this.note,
    required this.createdAt,
  });

  // Convert meal to a Map so we can save it
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'location': location,
      'amount': amount,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create a Meal from a saved Map
  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'],
      type: map['type'],
      name: map['name'],
      location: map['location'],
      amount: map['amount'].toDouble(),
      note: map['note'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}