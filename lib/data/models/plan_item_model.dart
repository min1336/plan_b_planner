// lib/data/models/plan_item_model.dart

import 'package:plan_b_planner/data/models/category_model.dart';

enum PlanItemType { template, fixed }

class PlanItem {
  final String sourceId; // <-- 1. 원본 데이터의 ID를 저장할 변수
  final String title;
  final int startMinuteOfDay;
  final int endMinuteOfDay;
  final Category category;
  final PlanItemType type;
  bool isConflict;

  PlanItem({
    required this.sourceId, // <-- 2. 생성자에 추가
    required this.title,
    required this.startMinuteOfDay,
    required this.endMinuteOfDay,
    required this.category,
    required this.type,
    this.isConflict = false,
  });
}