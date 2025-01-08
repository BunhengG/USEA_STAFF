import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:usea_staff_test/constant/constant.dart';

import '../../../provider/calendar_provider.dart';

class CustomCalendar extends StatefulWidget {
  const CustomCalendar({super.key});

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late DateTime selectedDay;
  late DateTime focusedDay;

  @override
  void initState() {
    super.initState();
    selectedDay = DateTime.now();
    focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double rowHeight = screenHeight * 0.06;
    double daySize = screenWidth * 0.12;

    return Container(
      color: secondaryColor,
      child: Consumer<CalendarProvider>(
        builder: (context, calendarProvider, child) {
          return TableCalendar(
            locale: 'en_US',
            pageAnimationEnabled: true,
            pageAnimationDuration: const Duration(milliseconds: 300),
            pageAnimationCurve: Curves.easeInOut,
            rowHeight: rowHeight,
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, selectedDay),
            daysOfWeekHeight: 36.0,
            calendarStyle: CalendarStyle(
              cellMargin: const EdgeInsets.all(2.5),
              selectedDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(roundedCornerSM - 2),
                color: primaryColor,
              ),
              selectedTextStyle: getWhiteSubTitle(),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: getBody(),
              weekendStyle: getBody().copyWith(color: placeholderColor),
            ),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              headerPadding: const EdgeInsets.symmetric(vertical: 2.0),
              headerMargin: const EdgeInsets.symmetric(vertical: 0.0),
              leftChevronIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    focusedDay = focusedDay.subtract(const Duration(days: 30));
                  });
                },
                child: const FaIcon(
                  FontAwesomeIcons.chevronLeft,
                  color: primaryColor,
                ),
              ),
              rightChevronIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    focusedDay = focusedDay.add(const Duration(days: 30));
                  });
                },
                child: const FaIcon(
                  FontAwesomeIcons.chevronRight,
                  color: primaryColor,
                ),
              ),
              leftChevronPadding: const EdgeInsets.all(0.0),
              rightChevronPadding: const EdgeInsets.all(0.0),
              leftChevronMargin: const EdgeInsets.all(12.0),
              rightChevronMargin: const EdgeInsets.all(12.0),
              titleTextStyle: getSubTitle().copyWith(color: primaryColor),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                bool isHoliday = _isHoliday(day);
                bool isSunday = day.weekday == DateTime.sunday;

                return Container(
                  height: daySize,
                  width: daySize,
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    color: isHoliday
                        ? atvColor
                        : isSunday
                            ? uAtvColor
                            : uAtvShape,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(roundedCornerSM - 2),
                  ),
                  child: Center(
                    child: Text(
                      day.day.toString(),
                      style: isHoliday || isSunday
                          ? getBody().copyWith(color: secondaryColor)
                          : getBody(),
                    ),
                  ),
                );
              },
            ),
            onPageChanged: (focusedDay) {
              setState(() {
                this.focusedDay = focusedDay;
              });

              final month = focusedDay.month;
              final year = focusedDay.year;
              calendarProvider.fetchHolidaysForMonth(month, year);
            },
          );
        },
      ),
    );
  }

  //NOTE: Check if the given day is a holiday
  bool _isHoliday(DateTime day) {
    final holidays =
        Provider.of<CalendarProvider>(context, listen: false).holidays;
    for (var holiday in holidays) {
      final holidayDate = DateTime.parse(holiday['date']);
      if (holidayDate.year == day.year &&
          holidayDate.month == day.month &&
          holidayDate.day == day.day) {
        return true;
      }
    }
    return false;
  }
}
