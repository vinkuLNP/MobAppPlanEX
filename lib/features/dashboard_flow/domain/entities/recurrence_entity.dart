
class RecurrenceEntity {
  final int interval;
  final RecurrenceUnit unit; 

  RecurrenceEntity({required this.interval, required this.unit});
 Map<String, dynamic> toMap() => {
        'unit': unit.name,
        'interval': interval,
      };
  
}

enum RecurrenceUnit { days, weeks, months ,none}

