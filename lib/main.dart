import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:plan_b_planner/data/models/category_model.dart';
import 'package:plan_b_planner/data/models/fixed_appointment_model.dart';
import 'package:plan_b_planner/data/models/time_block_model.dart';
import 'package:plan_b_planner/presentation/screens/template_screen.dart';
import 'package:plan_b_planner/presentation/screens/main_screen.dart';

// main 함수는 앱의 진입점입니다.
Future<void> main() async {
  // Flutter 앱이 시작하기 전에 네이티브 코드를 초기화해야 할 때 사용합니다.
  // Hive 초기화가 그중 하나입니다.
  WidgetsFlutterBinding.ensureInitialized();

  // --- 데이터베이스 초기화 시작 ---

  // 1. Hive를 Flutter 환경에서 사용할 수 있도록 초기화합니다.
  await Hive.initFlutter();

  // 2. Hive에게 우리가 만든 모델들을 알려줍니다 (Adapter 등록).
  //    이 과정을 거쳐야 Hive가 해당 객체들을 저장하고 불러올 수 있습니다.
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(TimeBlockModelAdapter());
  Hive.registerAdapter(FixedAppointmentModelAdapter());

  // --- 데이터베이스 초기화 끝 ---

  // 모든 준비가 끝나면 앱을 실행합니다.
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
      // 아직 홈 화면이 없으므로 임시로 빈 화면을 보여줍니다.
      home: const MainScreen(),
    );
  }
}