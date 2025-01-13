import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usea_staff_test/provider/calendar_provider.dart';
import '../../Components/custom_appbar_widget.dart';
import '../../constant/constant.dart';
import 'widget/custom_calendar_widget.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    final calendarProvider =
        Provider.of<CalendarProvider>(context, listen: false);
    await calendarProvider.fetchCalendars();

    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;
    await calendarProvider.fetchHolidaysForMonth(currentMonth, currentYear);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(
        title: 'Calendar',
        backgroundColor: secondaryColor,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: CustomCalendar(),
          ),

          // TabBar
          Container(
            color: secondaryColor,
            child: TabBar(
              controller: _tabController,
              labelColor: primaryColor,
              unselectedLabelColor: placeholderColor,
              indicatorColor: primaryColor,
              indicatorWeight: 2,
              tabs: const [
                Tab(text: 'Workday / Time'),
                Tab(text: 'Holiday'),
              ],
            ),
          ),

          //NOTE: TabBarView for ListView under each Tab
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Consumer<CalendarProvider>(
                builder: (context, calendarProvider, child) {
                  if (calendarProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (calendarProvider.errorMessage != null) {
                    return _buildError(calendarProvider.errorMessage!);
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      //* Tab 1
                      _buildCalendarList(
                        calendarProvider.calendars
                            .where((c) => c.attendStatus == 'Present')
                            .toList(),
                        'No workdays found.',
                      ),

                      //* Tab 2
                      _buildHolidayList(
                        calendarProvider.holidays,
                        'No holidays found.',
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build Error Widget
  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          message,
          style: getSubTitle().copyWith(color: uAtvColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // NOTE: Build Calendar List
  Widget _buildCalendarList(List calendars, String emptyMessage) {
    if (calendars.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: calendars.length,
      itemBuilder: (context, index) {
        final calendar = calendars[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: smPadding),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(roundedCornerSM),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      calendar.day.length > 3
                          ? calendar.day.substring(0, 3)
                          : calendar.day,
                      style: getTitle(),
                    ),

                    //* Vertical Divider
                    Container(
                      height: 50,
                      width: 3,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(roundedCornerSM),
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Workday',
                              style: getSubTitle().copyWith(
                                fontSize: 16,
                                color: anvColor,
                              ),
                            ),
                            Text(
                              '\t\t / \t\t',
                              style: getSubTitle().copyWith(
                                fontSize: 16,
                                color: anvColor,
                              ),
                            ),
                            Text(
                              'Time',
                              style: getSubTitle().copyWith(
                                fontSize: 16,
                                color: anvColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: smPadding - 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              calendar.date.toLocal().toString().split(' ')[0],
                              style: getSubTitle().copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: mdPadding),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '\t\t ${calendar.morningTime} AM',
                                  style: getSubTitle().copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2.0,
                                  ),
                                  child: Container(
                                    width: 50.0,
                                    height: 1.0,
                                    color: placeholderColor,
                                  ),
                                ),
                                Text(
                                  '\t\t ${calendar.afternoonTime} PM',
                                  style: getSubTitle().copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) =>
          const SizedBox(height: mdPadding - 4),
    );
  }

  // NOTE: Build Holiday List
  Widget _buildHolidayList(List holidays, String emptyMessage) {
    if (holidays.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: holidays.length,
      itemBuilder: (context, index) {
        final holiday = holidays[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: smPadding),
          child: Container(
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(roundedCornerSM),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.only(
                left: defaultPadding * 1.5,
                bottom: mdPadding,
                top: mdPadding,
              ),
              leading: const Text(
                '🎉',
                style: TextStyle(fontSize: titleSize + 4),
              ),
              title: Padding(
                padding: const EdgeInsets.only(
                  left: smPadding,
                  bottom: smPadding - 2,
                ),
                child: Text(
                  holiday['date'] ?? 'Unnamed Date',
                  style: getTitle(),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(left: smPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${holiday['name'] ?? 'Unknown Holiday'}',
                      style: getSubTitle(),
                    ),
                    Text(
                      '${holiday['description'] ?? 'Unknown Description'}',
                      style: getBody(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: smPadding),
    );
  }

  // Build Empty State
  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          message,
          style: getTitle(),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
