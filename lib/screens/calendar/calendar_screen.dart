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
      physics: const BouncingScrollPhysics(),
      itemCount: calendars.length,
      itemBuilder: (context, index) {
        final calendar = calendars[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: smPadding),
          child: Card(
            margin: const EdgeInsets.only(top: 8),
            color: secondaryColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(roundedCornerMD),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(mdPadding),
              leading: const Icon(
                Icons.calendar_today,
                color: primaryColor,
              ),
              title: Text(calendar.username, style: getSubTitle()),
              subtitle: Text(
                '${calendar.date.toLocal().toString().split(' ')[0]} - ${calendar.attendStatus}',
                style: getBody(),
              ),
              trailing: Icon(
                calendar.attendStatus == 'Present'
                    ? Icons.check_circle
                    : Icons.cancel,
                color: calendar.attendStatus == 'Present' ? atvColor : anvColor,
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8),
    );
  }

  // NOTE: Build Holiday List
  Widget _buildHolidayList(List holidays, String emptyMessage) {
    if (holidays.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: holidays.length,
      itemBuilder: (context, index) {
        final holiday = holidays[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              leading: const Icon(
                Icons.beach_access,
                color: Colors.orange,
              ),
              title: Text(
                holiday['name'] ?? 'Unnamed Holiday',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${holiday['date'] ?? 'Unknown Date'}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 10),
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
