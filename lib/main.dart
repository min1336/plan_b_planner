// lib/main.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart'; // 1. 이 import를 추가하세요.
import 'package:plan_b_planner/data/models/category_model.dart';
import 'package:plan_b_planner/data/models/fixed_appointment_model.dart';
import 'package:plan_b_planner/data/models/time_block_model.dart';
import 'package:plan_b_planner/presentation/screens/main_screen.dart';

Future<void> main() async {
  // Flutter 엔진과 위젯 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 2. 날짜/시간 형식 데이터를 초기화합니다. (가장 중요한 부분!)
  // 이 한 줄이 'ko_KR' 같은 로케일 데이터를 로드해줍니다.
  await initializeDateFormatting();

  // Hive 데이터베이스 초기화
  await Hive.initFlutter();

  // Hive 어댑터 등록
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(TimeBlockModelAdapter());
  Hive.registerAdapter(FixedAppointmentModelAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plan B Planner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}