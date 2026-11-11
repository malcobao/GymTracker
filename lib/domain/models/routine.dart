/// A named training plan, such as "Push day".
class Routine {
  const Routine({required this.id, required this.name, this.description});

  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
  );

  final String id;
  final String name;
  final String? description;
}
