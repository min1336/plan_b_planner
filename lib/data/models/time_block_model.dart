import 'package:hive/hive.dart';
import 'package:plan_b_planner/data/models/category_model.dart';

part 'time_block_model.g.dart';

@HiveType(typeId: 2)
class TimeBlockModel extends HiveObject {
  @HiveField(0)
  late String id; // 각 블록의 고유 식별자

  @HiveField(1)
  late String title; // 예: "집중 업무"

  // TimeOfDay 대신 자정부터 몇 분이 지났는지를 저장하는 것이
  // 계산 및 정렬에 훨씬 유리합니다. (예: 오전 9시는 9 * 60 = 540)
  @HiveField(2)
  late int startMinuteOfDay;

  @HiveField(3)
  late int endMinuteOfDay;

  @HiveField(4)
  late Category category; // 수면, 일과, 취미

  @HiveField(5)
  late bool isFlexible; // 약속에 따라 시간이 변경될 수 있는지 여부

  @HiveField(6)
  late int dayOfWeek; // 요일 (1: 월요일, 7: 일요일)

  TimeBlockModel({
    required this.id,
    required this.title,
    required this.startMinuteOfDay,
    required this.endMinuteOfDay,
    required this.category,
    required this.isFlexible,
    required this.dayOfWeek,
  });
}