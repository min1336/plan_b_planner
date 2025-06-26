// lib/data/models/category_model.dart의 올바른 전체 코드

import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
enum Category {
  @HiveField(0)
  sleep, // 수면

  @HiveField(1)
  work,  // 일과

  @HiveField(2)
  hobby; // 취미

  // 화면에 한글로 표시하기 위한 도우미
  String get displayName {
    switch (this) {
      case Category.sleep:
        return '수면';
      case Category.work:
        return '일과';
      case Category.hobby:
        return '취미';
    }
  }
}