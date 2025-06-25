import 'package:hive/hive.dart';
import 'package:plan_b_planner/data/models/category_model.dart';

part 'fixed_appointment_model.g.dart';

@HiveType(typeId: 3)
class FixedAppointmentModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title; // 예: "치과 진료"

  @HiveField(2)
  late DateTime date; // 약속 날짜 (연/월/일)

  @HiveField(3)
  late int startMinuteOfDay; // 시작 시간

  @HiveField(4)
  late int endMinuteOfDay; // 종료 시간

  @HiveField(5)
  late Category category;

  FixedAppointmentModel({
    required this.id,
    required this.title,
    required this.date,
    required this.startMinuteOfDay,
    required this.endMinuteOfDay,
    required this.category,
  });
}