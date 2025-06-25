// Hive가 이 객체를 저장할 수 있도록 타입을 지정합니다.
import 'package:hive/hive.dart';

part 'category_model.g.dart'; // Hive가 자동으로 생성할 파일

@HiveType(typeId: 1) // 각 Hive 모델은 고유한 typeId를 가집니다.
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