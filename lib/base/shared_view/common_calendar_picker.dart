import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import '../constants/ui/app_colors.dart';
import '../constants/ui/app_text_styles.dart';
import 'common_button.dart';

class CommonCalendarPicker extends StatefulWidget {
  const CommonCalendarPicker({
    super.key,
    required this.onDateTimeChanged,
    this.dates,
    this.firstDate,
    this.lastDate,
    this.type = CalendarDatePicker2Type.single,
  });

  final List<DateTime>? dates;
  final ValueChanged<List<DateTime>> onDateTimeChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final CalendarDatePicker2Type type;

  @override
  State<CommonCalendarPicker> createState() => _CommonCalendarDatePickerState();
}

class _CommonCalendarDatePickerState extends State<CommonCalendarPicker> {
  late List<DateTime> dates;

  bool get available => (dates.length > 1);

  @override
  void initState() {
    super.initState();
    dates = widget.dates ?? [DateTime.now()];
  }

  @override
  Widget build(BuildContext context) {
    final child = CalendarDatePicker2(
      config: CalendarDatePicker2Config(
        dayBuilder: _dayBuilder,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        disabledDayTextStyle: const TextStyle(
          decoration: TextDecoration.lineThrough,
          color: Colors.grey,
          decorationColor: Colors.grey,
        ),
        calendarType: widget.type,
        calendarViewMode: CalendarDatePicker2Mode.scroll,
        // scrollViewTopHeaderTextStyle: AppTextStyles.textBodyMedium.copyWith(color: AppColors.current.neutral40),
        weekdayLabels: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
        hideScrollViewMonthWeekHeader: true,
        weekdayLabelTextStyle: AppTextStyles.bodyMediumRegular,
        // weekdayLabelTextStyle: AppTextStyles.textBody.copyWith(color: AppColors.current.neutral40),
        // selectedRangeHighlightColor: AppColors.current.cam.withOpacity(.1),
        selectedDayHighlightColor: AppColors.current.primary500,
        dayTextStyle: AppTextStyles.bodyMediumRegular,

      ),
      value: dates,
      onValueChanged: (value) {
        setState(() {
          dates = value;
        });
        widget.onDateTimeChanged.call(dates);
      },
    );
    return  SizedBox(height: MediaQuery.sizeOf(context).height / 2,child: child);
  }

  Widget _buildButton() {
    return SafeArea(
      minimum: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: CommonButton(
        fullWidth: true,
        enable: available,
        title: "Save",
        onPressed: () {
          Navigator.of(context).pop(dates);
        },
      ),
    );
  }

  Widget? _dayBuilder({
    required DateTime date,
    BoxDecoration? decoration,
    bool? isDisabled,
    bool? isSelected,
    bool? isToday,
    TextStyle? textStyle,
  }) {
    Widget? dayWidget;
    // final isSame = isSameDay(date, DateTime.now().add(const Duration(days: 3)));
    // if(isSame) {
    //   dayWidget = Center(child: Text(date.fromString('DD'), textAlign: TextAlign.center));
    //   return dayWidget;
    // }
    return dayWidget;
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
