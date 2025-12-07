import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';

class MonthlyCalendarScreen extends StatefulWidget {
  const MonthlyCalendarScreen({super.key});

  @override
  State<MonthlyCalendarScreen> createState() => _MonthlyCalendarScreenState();
}

class _MonthlyCalendarScreenState extends State<MonthlyCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Open create event dialog
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
          ),
          const Divider(),
          Expanded(
            child:
                _selectedDay == null
                    ? Center(
                      child: Text(
                        'Select a day to view events',
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                    )
                    : ListView(
                      padding: EdgeInsets.all(16.w),
                      children: [
                        Text(
                          'Events for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        // TODO: Load events for selected day
                        _buildEventCard(
                          'Team Meeting',
                          '10:00 AM - 11:00 AM',
                          Colors.blue,
                        ),
                        _buildEventCard(
                          'Project Review',
                          '2:00 PM - 3:30 PM',
                          Colors.green,
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(String title, String time, Color color) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        leading: Container(width: 4.w, height: 40.h, color: color),
        title: Text(
          title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(time, style: TextStyle(fontSize: 14.sp)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Open event details
        },
      ),
    );
  }
}
