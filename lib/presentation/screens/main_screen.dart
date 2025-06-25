import 'package:flutter/material.dart';
import 'package:plan_b_planner/presentation/screens/template_screen.dart';
import 'package:plan_b_planner/presentation/screens/today_plan_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 현재 선택된 탭의 인덱스
  int _selectedIndex = 0;

  // 하단 탭에 따라 보여줄 화면 목록
  static const List<Widget> _widgetOptions = <Widget>[
    TodayPlanScreen(), // 0번 탭
    TemplateScreen(),  // 1번 탭
  ];

  // 탭을 선택했을 때 호출될 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 선택된 인덱스에 맞는 화면을 보여줍니다.
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // 하단 네비게이션 바 설정
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: '오늘의 계획',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_calendar),
            label: '템플릿 관리',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
    );
  }
}