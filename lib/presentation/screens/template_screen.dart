// lib/presentation/screens/template_screen.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:plan_b_planner/data/models/category_model.dart';
import 'package:plan_b_planner/data/models/time_block_model.dart';
import 'package:uuid/uuid.dart';

class TemplateScreen extends StatefulWidget {
  const TemplateScreen({super.key});

  @override
  State<TemplateScreen> createState() => _TemplateScreenState();
}

class _TemplateScreenState extends State<TemplateScreen> {
  final List<String> _days = ['월', '화', '수', '목', '금', '토', '일'];
  final List<String> _fullDayNames = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
  int _selectedDayIndex = 0;

  List<TimeBlockModel> _timeBlocks = [];

  @override
  void initState() {
    super.initState();
    _loadTimeBlocks();
  }

  Future<void> _loadTimeBlocks() async {
    final box = await Hive.openBox<TimeBlockModel>('time_blocks');
    final currentDayOfWeek = _selectedDayIndex + 1;

    final blocks = box.values
        .where((block) => block.dayOfWeek == currentDayOfWeek)
        .toList();
    blocks.sort((a, b) => a.startMinuteOfDay.compareTo(b.startMinuteOfDay));

    setState(() {
      _timeBlocks = blocks;
    });
  }

  // --- UI 위젯 빌더 함수들 ---

  Widget _buildDaySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          children: List.generate(_days.length, (index) {
            final isSelected = _selectedDayIndex == index;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedDayIndex = index;
                    _loadTimeBlocks();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.teal : Colors.grey[300],
                  foregroundColor: isSelected ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text(_days[index]),
              ),
            );
          }),
        ),
      ),
    );
  }

  // 시간 블록 목록 위젯에 Dismissible과 onTap 기능 추가
  Widget _buildTimeBlockList() {
    if (_timeBlocks.isEmpty) {
      return const Center(child: Text('저장된 시간 블록이 없습니다.\n(+) 버튼을 눌러 추가해보세요!'));
    }
    return ListView.builder(
      itemCount: _timeBlocks.length,
      itemBuilder: (context, index) {
        final block = _timeBlocks[index];
        // '옆으로 밀어서 삭제' 기능을 위해 Dismissible 위젯으로 감쌉니다.
        return Dismissible(
          // 각 항목은 고유한 Key를 가져야 합니다.
          key: Key(block.id),
          // 밀었을 때 실행될 로직
          onDismissed: (direction) async {
            final box = await Hive.openBox<TimeBlockModel>('time_blocks');
            await box.delete(block.id); // DB에서 삭제
            _loadTimeBlocks(); // 목록 새로고침

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${block.title} 블록이 삭제되었습니다.')),
              );
            }
          },
          // 밀었을 때 배경에 표시될 UI
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(
                Icons.circle,
                color: block.category == Category.work
                    ? Colors.blue
                    : block.category == Category.hobby
                    ? Colors.green
                    : Colors.purple,
              ),
              title: Text(block.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('카테고리: ${block.category.displayName}'),
              trailing: Text(
                '${_formatTime(block.startMinuteOfDay)} - ${_formatTime(block.endMinuteOfDay)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              // 항목을 탭하면 수정 다이얼로그를 띄웁니다.
              onTap: () {
                _showAddTimeBlockDialog(existingBlock: block);
              },
            ),
          ),
        );
      },
    );
  }

  // --- 다이얼로그 함수 수정 ---

  // '수정' 기능을 위해 기존 블록을 파라미터로 받을 수 있게 수정합니다.
  void _showAddTimeBlockDialog({TimeBlockModel? existingBlock}) {
    final bool isUpdating = existingBlock != null;
    final titleController = TextEditingController(text: existingBlock?.title);
    TimeOfDay? startTime = existingBlock != null ? TimeOfDay(hour: existingBlock.startMinuteOfDay ~/ 60, minute: existingBlock.startMinuteOfDay % 60) : null;
    TimeOfDay? endTime = existingBlock != null ? TimeOfDay(hour: existingBlock.endMinuteOfDay ~/ 60, minute: existingBlock.endMinuteOfDay % 60) : null;
    Category selectedCategory = existingBlock?.category ?? Category.work;
    bool isFlexible = existingBlock?.isFlexible ?? false;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            // 제목을 '추가' 또는 '수정'으로 동적 변경
            title: Text('${_fullDayNames[_selectedDayIndex]} 블록 ${isUpdating ? '수정' : '추가'}'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  // ... (다이얼로그 UI는 이전과 동일) ...
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: '제목 (예: 오전 업무)'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return '제목을 입력해주세요.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<Category>(
                      value: selectedCategory,
                      items: Category.values.map((category) => DropdownMenuItem(value: category, child: Text(category.displayName))).toList(),
                      onChanged: (value) {
                        if (value != null) setDialogState(() => selectedCategory = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final time = await showTimePicker(context: context, initialTime: startTime ?? TimeOfDay.now());
                            if (time != null) setDialogState(() => startTime = time);
                          },
                          child: Text(startTime == null ? '시작 시간' : startTime!.format(context)),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final time = await showTimePicker(context: context, initialTime: endTime ?? TimeOfDay.now());
                            if (time != null) setDialogState(() => endTime = time);
                          },
                          child: Text(endTime == null ? '종료 시간' : endTime!.format(context)),
                        ),
                      ],
                    ),
                    SwitchListTile(
                      title: const Text('유동 블록'),
                      value: isFlexible,
                      onChanged: (value) => setDialogState(() => isFlexible = value),
                    )
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

                  // '수정'일 경우 기존 ID 사용, '추가'일 경우 새 ID 생성
                  final String blockId = isUpdating ? existingBlock.id : const Uuid().v4();

                  final newTimeBlock = TimeBlockModel(
                    id: blockId,
                    title: titleController.text,
                    startMinuteOfDay: startTime!.hour * 60 + startTime!.minute,
                    endMinuteOfDay: endTime!.hour * 60 + endTime!.minute,
                    category: selectedCategory,
                    isFlexible: isFlexible,
                    dayOfWeek: _selectedDayIndex + 1,
                  );
                  final box = await Hive.openBox<TimeBlockModel>('time_blocks');
                  // Hive의 put은 키가 존재하면 덮어쓰므로 '추가'와 '수정' 모두에 사용 가능
                  await box.put(newTimeBlock.id, newTimeBlock);
                  if (mounted) Navigator.pop(context);
                  _loadTimeBlocks();
                },
                child: const Text('저장'),
              ),
            ],
          );
        });
      },
    );
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
        title: const Text('주간 템플릿 관리'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          _buildDaySelector(),
          const Divider(),
          Expanded(child: _buildTimeBlockList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTimeBlockDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}