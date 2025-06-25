import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:plan_b_planner/data/models/category_model.dart';
import 'package:plan_b_planner/data/models/fixed_appointment_model.dart';
import 'package:plan_b_planner/data/models/plan_item_model.dart';
import 'package:plan_b_planner/data/services/plan_generator_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';

class TodayPlanScreen extends StatefulWidget {
  const TodayPlanScreen({super.key});

  @override
  State<TodayPlanScreen> createState() => _TodayPlanScreenState();
}

class _TodayPlanScreenState extends State<TodayPlanScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final PlanGeneratorService _planGenerator = PlanGeneratorService();
  List<PlanItem> _planItems = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadPlanForSelectedDay();
  }

  Future<void> _loadPlanForSelectedDay() async {
    if (_selectedDay == null) return;

    final plan = await _planGenerator.generatePlanForDay(_selectedDay!);
    if (mounted) {
      setState(() {
        _planItems = plan;
      });
    }
  }

  String _formatTime(int minuteOfDay) {
    final hour = (minuteOfDay ~/ 60).toString().padLeft(2, '0');
    final minute = (minuteOfDay % 60).toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 계획'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'ko_KR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadPlanForSelectedDay();
            },
            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const Divider(),
          Expanded(
            child: _planItems.isEmpty
                ? const Center(child: Text('오늘의 계획이 비어있습니다.'))
                : ListView.builder(
              itemCount: _planItems.length,
              itemBuilder: (context, index) {
                final item = _planItems[index];
                final isFixed = item.type == PlanItemType.fixed;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: isFixed ? 4.0 : 1.0,
                  child: ListTile(
                    leading: Icon(
                      isFixed ? Icons.bookmark : Icons.circle_outlined,
                      color: item.category == Category.work
                          ? Colors.blue
                          : item.category == Category.hobby
                          ? Colors.green
                          : Colors.purple,
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(fontWeight: isFixed ? FontWeight.bold : FontWeight.normal),
                    ),
                    trailing: Text(
                      '${_formatTime(item.startMinuteOfDay)} - ${_formatTime(item.endMinuteOfDay)}',
                      style: TextStyle(fontWeight: isFixed ? FontWeight.bold : FontWeight.w500),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedDay != null) {
            _showAddAppointmentDialog();
          }
        },
        child: const Icon(Icons.add_comment),
        tooltip: '고정 약속 추가',
      ),
    );
  }

  void _showAddAppointmentDialog() {
    final titleController = TextEditingController();
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    Category selectedCategory = Category.work;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('고정 약속 추가'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: '약속 이름'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '약속 이름을 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButton<Category>(
                        value: selectedCategory,
                        items: Category.values.map((category) {
                          return DropdownMenuItem(value: category, child: Text(category.displayName));
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => selectedCategory = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                              if (time != null) {
                                setDialogState(() => startTime = time);
                              }
                            },
                            child: Text(startTime == null ? '시작 시간' : startTime!.format(context)),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                              if (time != null) {
                                setDialogState(() => endTime = time);
                              }
                            },
                            child: Text(endTime == null ? '종료 시간' : endTime!.format(context)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
                TextButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate() == false || startTime == null || endTime == null) {
                      return;
                    }
                    const uuid = Uuid();
                    final newAppointment = FixedAppointmentModel(
                      id: uuid.v4(),
                      title: titleController.text,
                      date: _selectedDay!,
                      startMinuteOfDay: startTime!.hour * 60 + startTime!.minute,
                      endMinuteOfDay: endTime!.hour * 60 + endTime!.minute,
                      category: selectedCategory,
                    );
                    final box = await Hive.openBox<FixedAppointmentModel>('fixed_appointments');
                    await box.put(newAppointment.id, newAppointment);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('고정 약속이 저장되었습니다!')),
                      );
                    }
                    _loadPlanForSelectedDay();
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}