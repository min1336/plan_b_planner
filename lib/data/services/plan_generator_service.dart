import 'package:hive_flutter/hive_flutter.dart';
import 'package:plan_b_planner/data/models/fixed_appointment_model.dart';
import 'package:plan_b_planner/data/models/plan_item_model.dart';
import 'package:plan_b_planner/data/models/time_block_model.dart';
import 'package:table_calendar/table_calendar.dart';

class PlanGeneratorService {
  Future<List<PlanItem>> generatePlanForDay(DateTime date) async {
    final timeBlockBox = await Hive.openBox<TimeBlockModel>('time_blocks');
    final appointmentBox = await Hive.openBox<FixedAppointmentModel>('fixed_appointments');

    final dayOfWeek = date.weekday;
    final templateBlocks = timeBlockBox.values
        .where((block) => block.dayOfWeek == dayOfWeek)
        .map((block) => PlanItem(
      sourceId: block.id, // <-- ID 전달
      title: block.title,
      startMinuteOfDay: block.startMinuteOfDay,
      endMinuteOfDay: block.endMinuteOfDay,
      category: block.category,
      type: PlanItemType.template,
    ))
        .toList();

    final fixedAppointments = appointmentBox.values
        .where((appointment) => isSameDay(appointment.date, date))
        .map((appointment) => PlanItem(
      sourceId: appointment.id, // <-- ID 전달
      title: appointment.title,
      startMinuteOfDay: appointment.startMinuteOfDay,
      endMinuteOfDay: appointment.endMinuteOfDay,
      category: appointment.category,
      type: PlanItemType.fixed,
    ))
        .toList();

    final fullPlan = [...templateBlocks, ...fixedAppointments];
    fullPlan.sort((a, b) => a.startMinuteOfDay.compareTo(b.startMinuteOfDay));

    for (int i = 0; i < fullPlan.length - 1; i++) {
      final currentItem = fullPlan[i];
      final nextItem = fullPlan[i + 1];
      if (currentItem.endMinuteOfDay > nextItem.startMinuteOfDay) {
        currentItem.isConflict = true;
        nextItem.isConflict = true;
      }
    }

    return fullPlan;
  }
}