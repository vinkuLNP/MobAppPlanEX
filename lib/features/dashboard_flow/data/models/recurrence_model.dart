import 'package:plan_ex_app/features/dashboard_flow/domain/entities/recurrence_entity.dart';

class RecurrenceModel extends RecurrenceEntity {
  RecurrenceModel({required super.unit, required super.interval});

  factory RecurrenceModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return RecurrenceModel(unit: RecurrenceUnit.none, interval: 0);
    }

    final unitString = map['unit'] as String?;

    return RecurrenceModel(
      interval: map['interval'] ?? 1,
      unit: RecurrenceUnit.values.firstWhere(
        (u) => u.name == unitString,
        orElse: () => RecurrenceUnit.days,
      ),
    );
  }
}
