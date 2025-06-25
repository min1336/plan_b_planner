// lib/data/services/plan_generator_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:plan_b_planner/data/models/fixed_appointment_model.dart';
import 'package:plan_b_planner/data/models/plan_item_model.dart';
import 'package:plan_b_planner/data/models/time_block_model.dart';
import 'package:table_calendar/table_calendar.dart';

class PlanGeneratorService {
  Future<List<PlanItem>> generatePlanForDay(DateTime date) async {
    // 1. 필요한 데이터 박스를 엽니다.
    final timeBlockBox = await Hive.openBox<TimeBlockModel>('time_blocks');
    final appointmentBox = await Hive.openBox<FixedAppointmentModel>('fixed_appointments');

    // 2. 해당 요일의 템플릿을 불러옵니다. (월요일=1, ..., 일요일=7)
    final dayOfWeek = date.weekday;
    final templateBlocks = timeBlockBox.values
        .where((block) => block.dayOfWeek == dayOfWeek)
        .map((block) => PlanItem( // PlanItem으로 변환
      title: block.title,
      startMinuteOfDay: block.startMinuteOfDay,
      endMinuteOfDay: block.endMinuteOfDay,
      category: block.category,
      type: PlanItemType.template,
    ))
        .toList();

    // 3. 해당 날짜의 고정 약속을 불러옵니다.
    final fixedAppointments = appointmentBox.values
        .where((appointment) => isSameDay(appointment.date, date))
        .map((appointment) => PlanItem( // PlanItem으로 변환
      title: appointment.title,
      startMinuteOfDay: appointment.startMinuteOfDay,
      endMinuteOfDay: appointment.endMinuteOfDay,
      category: appointment.category,
      type: PlanItemType.fixed,
    ))
        .toList();

    // 4. 두 리스트를 합치고 시간순으로 정렬합니다.
    final fullPlan = [...templateBlocks, ...fixedAppointments];
    fullPlan.sort((a, b) => a.startMinuteOfDay.compareTo(b.startMinuteOfDay));

    // TODO: 여기에 약속과 템플릿이 겹칠 때 처리하는 고급 로직을 추가할 수 있습니다.

    return fullPlan;
  }
}