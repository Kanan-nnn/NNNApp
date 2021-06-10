import 'package:sqflite/sqflite.dart';

class Friend {
  final String name;
  final int percentage;

  Friend({
    required this.name,
    required this.percentage,
  });

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'percentage': percentage,
    };
  }
}
