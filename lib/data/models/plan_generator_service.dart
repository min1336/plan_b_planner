// lib/data/services/plan_generator_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:plan_b_planner/data/models/fixed_appointment_model.dart';
import 'package:plan_b_planner/data/models/plan_item_model.dart';
import 'package:plan_b_planner/data/models/time_block_model.dart';
import 'package:table_calendar/table_calendar.dart';

// [시작시간, 종료시간]을 나타내는 간단한 클래스
class TimeRange {
  int start;
  int end;
  TimeRange(this.start, this.end);
}

class PlanGeneratorService {
  Future<List<PlanItem>> generatePlanForDay(DateTime date) async {
    final timeBlockBox = await Hive.openBox<TimeBlockModel>('time_blocks');
    final appointmentBox = await Hive.openBox<FixedAppointmentModel>('fixed_appointments');

    // 1. 고정 약속들을 PlanItem 리스트로 변환
    final fixedItems = appointmentBox.values
        .where((appointment) => isSameDay(appointment.date, date))
        .map((appointment) => PlanItem(
      sourceId: appointment.id,
      title: appointment.title,
      startMinuteOfDay: appointment.startMinuteOfDay,
      endMinuteOfDay: appointment.endMinuteOfDay,
      category: appointment.category,
      type: PlanItemType.fixed,
    ))
        .toList();

    final List<PlanItem> finalPlan = [...fixedItems]; // 최종 계획 리스트는 고정 약속으로 시작

    // 2. 해당 요일의 템플릿 블록들을 가져옴
    final dayOfWeek = date.weekday;
    final templateBlocks = timeBlockBox.values.where((block) => block.dayOfWeek == dayOfWeek);

    // 3. 각 템플릿 블록에 대해 조정 로직 실행
    for (final block in templateBlocks) {
      // 3-1. 유동적이지 않은 블록은 충돌 검사만 하고 바로 추가
      if (!block.isFlexible) {
        bool isConflict = fixedItems.any((fixed) =>
        block.startMinuteOfDay < fixed.endMinuteOfDay && block.endMinuteOfDay > fixed.startMinuteOfDay);
        finalPlan.add(PlanItem(
          sourceId: block.id,
          title: block.title,
          startMinuteOfDay: block.startMinuteOfDay,
          endMinuteOfDay: block.endMinuteOfDay,
          category: block.category,
          type: PlanItemType.template,
          isConflict: isConflict,
        ));
        continue; // 다음 템플릿 블록으로 넘어감
      }

      // 3-2. 유동적인 블록의 시간 범위를 생성
      List<TimeRange> availableSlots = [TimeRange(block.startMinuteOfDay, block.endMinuteOfDay)];

      // 3-3. 모든 고정 약속을 순회하며 템플릿 블록의 시간을 '조각냄'
      for (final fixed in fixedItems) {
        List<TimeRange> nextAvailableSlots = [];
        for (final slot in availableSlots) {
          // Case 1: 약속이 슬롯을 완전히 덮을 때 -> 슬롯 사라짐
          if (fixed.startMinuteOfDay <= slot.start && fixed.endMinuteOfDay >= slot.end) {
            // 아무것도 안함 (슬롯 제거)
          }
          // Case 2: 약속이 슬롯 중간에 있을 때 -> 슬롯이 두 개로 분할됨
          else if (fixed.startMinuteOfDay > slot.start && fixed.endMinuteOfDay < slot.end) {
            nextAvailableSlots.add(TimeRange(slot.start, fixed.startMinuteOfDay));
            nextAvailableSlots.add(TimeRange(fixed.endMinuteOfDay, slot.end));
          }
          // Case 3: 약속이 슬롯 앞부분에 걸칠 때 -> 슬롯 시작 시간이 밀림
          else if (fixed.startMinuteOfDay <= slot.start && fixed.endMinuteOfDay > slot.start) {
            nextAvailableSlots.add(TimeRange(fixed.endMinuteOfDay, slot.end));
          }
          // Case 4: 약속이 슬롯 뒷부분에 걸칠 때 -> 슬롯 종료 시간이 당겨짐
          else if (fixed.startMinuteOfDay < slot.end && fixed.endMinuteOfDay >= slot.end) {
            nextAvailableSlots.add(TimeRange(slot.start, fixed.startMinuteOfDay));
          }
          // Case 5: 겹치지 않을 때 -> 슬롯 그대로 유지
          else {
            nextAvailableSlots.add(slot);
          }
        }
        availableSlots = nextAvailableSlots;
      }

      // 3-4. 최종적으로 남은 시간 조각들을 PlanItem으로 변환하여 추가
      for (final slot in availableSlots) {
        if (slot.start < slot.end) { // 유효한 시간대만 추가
          finalPlan.add(PlanItem(
            sourceId: block.id,
            title: block.title,
            startMinuteOfDay: slot.start,
            endMinuteOfDay: slot.end,
            category: block.category,
            type: PlanItemType.template,
          ));
        }
      }
    }

    // 4. 모든 아이템을 시간순으로 최종 정렬
    finalPlan.sort((a, b) => a.startMinuteOfDay.compareTo(b.startMinuteOfDay));

    return finalPlan;
  }
}