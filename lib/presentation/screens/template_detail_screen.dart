import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:plan_b_planner/data/models/category_model.dart';
import 'package:plan_b_planner/data/models/time_block_model.dart';
import 'package:uuid/uuid.dart';

class TemplateDetailScreen extends StatefulWidget {
  final String dayOfWeek;

  const TemplateDetailScreen({
    super.key,
    required this.dayOfWeek,
  });

  @override
  State<TemplateDetailScreen> createState() => _TemplateDetailScreenState();
}

class _TemplateDetailScreenState extends State<TemplateDetailScreen> {
  final Map<String, int> dayOfWeekMap = {
    '월요일': 1, '화요일': 2, '수요일': 3, '목요일': 4,
    '금요일': 5, '토요일': 6, '일요일': 7,
  };

  // DB에서 불러온 시간 블록들을 담을 리스트
  List<TimeBlockModel> _timeBlocks = [];

  @override
  void initState() {
    super.initState();
    // 화면이 처음 로드될 때 시간 블록들을 불러옵니다.
    _loadTimeBlocks();
  }

  // Hive DB에서 시간 블록 데이터를 불러와 상태를 업데이트하는 함수
  Future<void> _loadTimeBlocks() async {
    final box = await Hive.openBox<TimeBlockModel>('time_blocks');
    final int currentDayOfWeek = dayOfWeekMap[widget.dayOfWeek]!;

    // 현재 요일에 해당하는 블록들만 필터링하고 시간순으로 정렬
    final blocks = box.values
        .where((block) => block.dayOfWeek == currentDayOfWeek)
        .toList();
    blocks.sort((a, b) => a.startMinuteOfDay.compareTo(b.startMinuteOfDay));

    setState(() {
      _timeBlocks = blocks;
    });
  }

  // 분(minuteOfDay)을 HH:mm 형식의 문자열로 변환하는 함수
  String _formatTime(int minuteOfDay) {
    final hour = (minuteOfDay ~/ 60).toString().padLeft(2, '0');
    final minute = (minuteOfDay % 60).toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showAddTimeBlockDialog() {
    // ... (이전과 동일한 다이얼로그 코드) ...
    // 단, 저장 버튼의 onPressed 마지막에 _loadTimeBlocks() 호출을 추가합니다.
    final titleController = TextEditingController();
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    Category selectedCategory = Category.work;
    bool isFlexible = false;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('${widget.dayOfWeek}에 시간 블록 추가'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
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
                        items: Category.values.map((category) {
                          return DropdownMenuItem(value: category, child: Text(category.displayName));
                        }).toList(),
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
                              final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                              if (time != null) setDialogState(() => startTime = time);
                            },
                            child: Text(startTime == null ? '시작 시간' : startTime!.format(context)),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                              if (time != null) setDialogState(() => endTime = time);
                            },
                            child: Text(endTime == null ? '종료 시간' : endTime!.format(context)),
                          ),
                        ],
                      ),
                      SwitchListTile(
                        title: const Text('유동 블록'),
                        subtitle: const Text('약속 발생 시 시간 변경 허용'),
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
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('모든 정보를 입력해주세요.')));
                      return;
                    }
                    const uuid = Uuid();
                    final newTimeBlock = TimeBlockModel(
                      id: uuid.v4(),
                      title: titleController.text,
                      startMinuteOfDay: startTime!.hour * 60 + startTime!.minute,
                      endMinuteOfDay: endTime!.hour * 60 + endTime!.minute,
                      category: selectedCategory,
                      isFlexible: isFlexible,
                      dayOfWeek: dayOfWeekMap[widget.dayOfWeek]!,
                    );
                    final box = await Hive.openBox<TimeBlockModel>('time_blocks');
                    await box.put(newTimeBlock.id, newTimeBlock);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('시간 블록이 저장되었습니다!')));
                    }
                    // ★★★★★ 저장 후 목록을 다시 불러옵니다!
                    _loadTimeBlocks();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.dayOfWeek} 템플릿')),
      // body 부분을 ListView.builder로 교체합니다.
      body: _timeBlocks.isEmpty
          ? const Center(child: Text('저장된 시간 블록이 없습니다.\n(+) 버튼을 눌러 추가해보세요!'))
          : ListView.builder(
        itemCount: _timeBlocks.length,
        itemBuilder: (context, index) {
          final block = _timeBlocks[index];
          return Card(
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
              // TODO: 탭하면 수정, 길게 누르면 삭제 기능 추가 예정
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTimeBlockDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}