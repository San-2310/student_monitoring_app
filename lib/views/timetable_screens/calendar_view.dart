import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarScreenApp extends StatefulWidget {
  @override
  _CalendarScreenAppState createState() => _CalendarScreenAppState();
}

class _CalendarScreenAppState extends State<CalendarScreenApp> {
  CalendarView _calendarView = CalendarView.day;
  List<Appointment> _appointments = [];
  late MeetingDataSource _dataSource;
  final CalendarController _controller = CalendarController();
  DateTime? _selectedDate;
  @override
  void initState() {
    super.initState();
    _appointments = getAppointments();
    _dataSource = MeetingDataSource(_appointments);
  }

  void _showAddSessionDialog() {
    String? selectedSubject;
    String? selectedDay;
    TimeOfDay? selectedStartTime;
    TimeOfDay? selectedEndTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Add Study Session"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedSubject,
                items: ["Maths", "Physics", "Chemistry"].map((subject) {
                  return DropdownMenuItem(value: subject, child: Text(subject));
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedSubject = value;
                  });
                },
                decoration: InputDecoration(labelText: "Select Subject"),
              ),
              DropdownButtonFormField<String>(
                value: selectedDay,
                items: [
                  "Monday",
                  "Tuesday",
                  "Wednesday",
                  "Thursday",
                  "Friday",
                  "Saturday",
                  "Sunday"
                ].map((day) {
                  return DropdownMenuItem(value: day, child: Text(day));
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedDay = value;
                  });
                },
                decoration: InputDecoration(labelText: "Select Day"),
              ),
              ElevatedButton(
                onPressed: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setDialogState(() {
                      selectedStartTime = pickedTime;
                    });
                  }
                },
                child: Text(selectedStartTime == null
                    ? "Select Start Time"
                    : "Start: ${selectedStartTime!.format(context)}"),
              ),
              ElevatedButton(
                onPressed: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setDialogState(() {
                      selectedEndTime = pickedTime;
                    });
                  }
                },
                child: Text(selectedEndTime == null
                    ? "Select End Time"
                    : "End: ${selectedEndTime!.format(context)}"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedSubject != null &&
                    selectedDay != null &&
                    selectedStartTime != null &&
                    selectedEndTime != null) {
                  print("Add Appointment button pressed!");
                  _addAppointment(selectedSubject!, selectedDay!,
                      selectedStartTime!, selectedEndTime!);
                  Navigator.pop(context);
                }
              },
              child: Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  void _addAppointment(
      String subject, String day, TimeOfDay time1, TimeOfDay time2) {
    print("Function _addAppointment is called!");

    DateTime now = DateTime.now();
    int dayOffset = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ].indexOf(day);
    DateTime startTime = DateTime(now.year, now.month,
        now.day - now.weekday + dayOffset + 1, time1.hour, time1.minute);
    DateTime endTime = DateTime(now.year, now.month,
        now.day - now.weekday + dayOffset + 1, time2.hour, time2.minute);

    Color subjectColor = subject == "Maths"
        ? Colors.red
        : subject == "Physics"
            ? Colors.blue
            : Colors.green;

    print("Before setState: Appointments count = ${_appointments.length}");

    setState(() {
      _appointments.add(Appointment(
        startTime: startTime,
        endTime: endTime,
        subject: subject,
        color: subjectColor,
      ));
      _dataSource = MeetingDataSource(_appointments); // THIS IS CRUCIAL
    });

    print(
        "After setState: Appointment added: $subject from $startTime to $endTime");
    print("After setState: Appointments count = ${_appointments.length}");
    debugPrint("Debug: New appointment added!");
  }

  @override
  Widget build(BuildContext context) {
    print("Rebuilding UI. Total appointments: ${_appointments.length}");
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Opens the drawer
            },
          ),
        ),
        title: DropdownButtonHideUnderline(
          child: DropdownButton<CalendarView>(
            value: _controller.view,
            onChanged: (CalendarView? newView) {
              if (newView != null) {
                setState(() {
                  _controller.view = newView;
                  if (newView == CalendarView.day && _selectedDate != null) {
                    _controller.displayDate = _selectedDate;
                  }
                });
              }
            },
            items: const [
              DropdownMenuItem(value: CalendarView.day, child: Text('Day')),
              DropdownMenuItem(value: CalendarView.week, child: Text('Week')),
              DropdownMenuItem(value: CalendarView.month, child: Text('Month')),
            ],
          ),
          // DropdownButton<CalendarView>(
          //   value: _calendarView,
          //   icon: Icon(Icons.arrow_drop_down, color: Colors.white),
          //   dropdownColor: Colors.white,
          //   onChanged: (CalendarView? newView) {
          //     if (newView != null) {
          //       setState(() {
          //         _calendarView = newView;

          //         if (newView == CalendarView.day && _selectedDate != null) {
          //           _controller.displayDate = _selectedDate;
          //         }
          //       });
          //     }
          //   },
          //   items: const [
          //     DropdownMenuItem(
          //       value: CalendarView.day,
          //       child: Text('Day'),
          //     ),
          //     DropdownMenuItem(
          //       value: CalendarView.week,
          //       child: Text('Week'),
          //     ),
          //     DropdownMenuItem(
          //       value: CalendarView.month,
          //       child: Text('Month'),
          //     ),
          //   ],
          // ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddSessionDialog,
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            color: const Color.fromARGB(255, 31, 115, 121),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person),
            color: const Color.fromARGB(255, 0, 0, 0),
            onPressed: () {},
          ),
        ],
      ),
      body:
          // SfCalendar(
          //   key: ValueKey(_calendarView),
          //   controller: _controller,
          //   view: _calendarView,
          //   firstDayOfWeek: 1,
          //   onTap: (details) {
          //     if (details.date != null) {
          //       setState(() {
          //         _selectedDate = details.date!;
          //       });
          //     }
          //   },
          //   dataSource: MeetingDataSource(_appointments),
          //   monthViewSettings: MonthViewSettings(showAgenda: true),
          // ),
          //     SfCalendar(
          //   //controller: _controller,
          //   key: ValueKey(_calendarView),
          //   view: _calendarView,
          //   firstDayOfWeek: 1,
          //   dataSource: MeetingDataSource(_appointments),
          //   monthViewSettings: MonthViewSettings(showAgenda: true),
          //   onTap: (CalendarTapDetails details) {
          //     if (details.date != null) {
          //       setState(
          //         () {
          //           _selectedDate = details.date!;
          //           if (_calendarView == CalendarView.month) {
          //             _calendarView = CalendarView.day;
          //             _controller.displayDate = _selectedDate;
          //           }
          //         },
          //       );
          //     }
          //   },
          // ),
          SfCalendar(
        controller: _controller,
        key: ValueKey(_controller.view),
        firstDayOfWeek: 1,
        dataSource: _dataSource,
        monthViewSettings: MonthViewSettings(showAgenda: true),
        onTap: (CalendarTapDetails details) {
          if (details.date != null) {
            setState(() {
              _selectedDate = details.date!;
              if (_controller.view == CalendarView.month) {
                _controller.view = CalendarView.day;
                _controller.displayDate = _selectedDate;
              }
            });
          }
        },
      ),
    );
  }
}

List<Appointment> getAppointments() {
  return [];
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
