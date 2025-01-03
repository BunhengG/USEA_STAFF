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
      appBar: CustomAppBar(title: 'Calendar'),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: CustomCalendar(),
          ),

          // TabBar
          TabBar(
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

          //NOTE: TabBarView for ListView under each Tab
          Expanded(
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
          child: Card(
            margin: const EdgeInsets.only(top: smMargin),
            color: secondaryColor,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(roundedCornerMD),
            ),
            child: Padding(
              padding: const EdgeInsets.all(mdPadding),
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
                        margin:
                            const EdgeInsets.symmetric(horizontal: mdPadding),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Workday', style: getSubTitle()),
                              Text(' / ', style: getSubTitle()),
                              Text('Time', style: getSubTitle()),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                calendar.date
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0],
                                style: getBody().copyWith(color: primaryColor),
                              ),
                              const SizedBox(width: mdPadding),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${calendar.morningTime} AM',
                                    style: getBody(),
                                  ),
                                  Text(
                                    '${calendar.afternoonTime} PM',
                                    style: getBody(),
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
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: mdPadding),
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
          child: Card(
            color: secondaryColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(roundedCornerMD),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(mdPadding),
              leading:
                  const Text('🎉', style: TextStyle(fontSize: titleSize + 4)),
              title: Text(
                holiday['date'] ?? 'Unnamed Date',
                style: getTitle(),
              ),
              subtitle: Column(
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
