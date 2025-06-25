import 'package:plan_b_planner/data/models/category_model.dart';

enum PlanItemType { template, fixed }

class PlanItem {
  final String title;
  final int startMinuteOfDay;
  final int endMinuteOfDay;
  final Category category;
  final PlanItemType type;

  PlanItem({
    required this.title,
    required this.startMinuteOfDay,
    required this.endMinuteOfDay,
    required this.category,
    required this.type,
  });
}