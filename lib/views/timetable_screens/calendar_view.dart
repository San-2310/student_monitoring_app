import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../models/timetable.dart';

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
    _fetchAppointmentsFromFirestore();
  }

  // void _showAddSessionDialog() {
  //   String? selectedSubject;
  //   String? selectedDay;
  //   TimeOfDay? selectedStartTime;
  //   TimeOfDay? selectedEndTime;
  //   bool repeatWeekly = false;
  //   String? sessionTitle;

  //   showDialog(
  //     context: context,
  //     builder: (context) => StatefulBuilder(
  //       builder: (context, setDialogState) => AlertDialog(
  //         title: Text("Add Study Session"),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             DropdownButtonFormField<String>(
  //               value: selectedSubject,
  //               items: ["Maths", "Physics", "Chemistry", "Biology", "Other"]
  //                   .map((subject) {
  //                 return DropdownMenuItem(value: subject, child: Text(subject));
  //               }).toList(),
  //               onChanged: (value) {
  //                 setDialogState(() {
  //                   selectedSubject = value;
  //                 });
  //               },
  //               decoration: InputDecoration(labelText: "Select Subject"),
  //             ),
  //             TextField(
  //               decoration: InputDecoration(labelText: "Session Title"),
  //               onChanged: (value) {
  //                 setDialogState(() {
  //                   sessionTitle = value;
  //                 });
  //               },
  //             ),
  //             CheckboxListTile(
  //               title: Text("Repeat every week"),
  //               value: repeatWeekly,
  //               onChanged: (value) {
  //                 setDialogState(() {
  //                   repeatWeekly = value ?? false;
  //                 });
  //               },
  //             ),
  //             ElevatedButton(
  //               onPressed: () async {
  //                 TimeOfDay? pickedTime = await showTimePicker(
  //                   context: context,
  //                   initialTime: TimeOfDay.now(),
  //                 );
  //                 if (pickedTime != null) {
  //                   setDialogState(() {
  //                     selectedStartTime = pickedTime;
  //                   });
  //                 }
  //               },
  //               child: Text(selectedStartTime == null
  //                   ? "Select Start Time"
  //                   : "Start: ${selectedStartTime!.format(context)}"),
  //             ),
  //             ElevatedButton(
  //               onPressed: () async {
  //                 TimeOfDay? pickedTime = await showTimePicker(
  //                   context: context,
  //                   initialTime: TimeOfDay.now(),
  //                 );
  //                 if (pickedTime != null) {
  //                   setDialogState(() {
  //                     selectedEndTime = pickedTime;
  //                   });
  //                 }
  //               },
  //               child: Text(selectedEndTime == null
  //                   ? "Select End Time"
  //                   : "End: ${selectedEndTime!.format(context)}"),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: Text("Cancel"),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               if (selectedSubject != null &&
  //                   selectedStartTime != null &&
  //                   selectedEndTime != null &&
  //                   sessionTitle != null &&
  //                   sessionTitle!.trim().isNotEmpty) {
  //                 _addAppointment(sessionTitle!, selectedSubject!,
  //                     selectedStartTime!, selectedEndTime!, repeatWeekly);
  //                 Navigator.pop(context);
  //               }
  //             },
  //             child: Text("Add"),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  void _showAddSessionDialog() {
    String? selectedSubject;
    String? selectedSessionType;
    String? selectedDay;
    String? target;
    TimeOfDay? selectedStartTime;
    TimeOfDay? selectedEndTime;
    bool repeatWeekly = false;
    String? sessionTitle;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Add Study Session"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedSubject,
                  items: ["Maths", "Physics", "Chemistry", "Biology", "Other"]
                      .map((subject) {
                    return DropdownMenuItem(
                        value: subject, child: Text(subject));
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedSubject = value;
                    });
                  },
                  decoration: InputDecoration(labelText: "Select Subject"),
                ),
                DropdownButtonFormField<String>(
                  value: selectedSessionType,
                  items: ["Study", "Lecture", "Revision", "Practice", "Other"]
                      .map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedSessionType = value;
                    });
                  },
                  decoration: InputDecoration(labelText: "Session Type"),
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Session Title"),
                  onChanged: (value) {
                    setDialogState(() {
                      sessionTitle = value;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Target"),
                  onChanged: (value) {
                    setDialogState(() {
                      target = value;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text("Repeat every week"),
                  value: repeatWeekly,
                  onChanged: (value) {
                    setDialogState(() {
                      repeatWeekly = value ?? false;
                    });
                  },
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedSubject != null &&
                    selectedStartTime != null &&
                    selectedEndTime != null &&
                    sessionTitle != null &&
                    sessionTitle!.trim().isNotEmpty &&
                    selectedSessionType != null &&
                    target != null) {
                  _addAppointment(
                    sessionTitle!,
                    selectedSubject!,
                    selectedSessionType!,
                    target!,
                    selectedStartTime!,
                    selectedEndTime!,
                    repeatWeekly,
                  );
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

  final studentId = FirebaseAuth
      .instance.currentUser!.uid; // Get this from FirebaseAuth or state

  Future<void> _fetchAppointmentsFromFirestore() async {
    final timetableSnap = await FirebaseFirestore.instance
        .collection('timetables')
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();

    if (timetableSnap.docs.isEmpty) return;

    final timetable = Timetable.fromFirestore(timetableSnap.docs.first);

    final List<Appointment> fetchedAppointments = [];

    for (var entry in timetable.entries) {
      if (entry.repeatWeekly) {
        for (int i = 0; i < 12; i++) {
          final DateTime repeatedStart =
              entry.startTime.add(Duration(days: i * 7));
          final DateTime repeatedEnd = entry.endTime.add(Duration(days: i * 7));
          fetchedAppointments
              .add(_entryToAppointment(entry, repeatedStart, repeatedEnd));
        }
      } else {
        fetchedAppointments
            .add(_entryToAppointment(entry, entry.startTime, entry.endTime));
      }
    }

    setState(() {
      _appointments = fetchedAppointments;
      _dataSource = MeetingDataSource(_appointments);
    });
  }

  Appointment _entryToAppointment(
      TimetableEntry entry, DateTime start, DateTime end) {
    final subject = entry.subject;
    Color subjectColor = subject == "Maths"
        ? const Color.fromARGB(255, 226, 101, 101)
        : subject == "Physics"
            ? const Color.fromARGB(255, 63, 123, 214)
            : subject == "Chemistry"
                ? const Color.fromARGB(255, 233, 157, 43)
                : subject == "Biology"
                    ? const Color.fromARGB(255, 79, 182, 82)
                    : const Color.fromARGB(255, 233, 112, 181);
    return Appointment(
      startTime: start,
      endTime: end,
      subject: '${entry.subject} - ${entry.title}',
      notes: entry.entryId, // Used for deletion
      color: subjectColor,
    );
  }

  // void _addAppointment(String title, String subject, TimeOfDay time1,
  //     TimeOfDay time2, bool repeatWeekly) {
  //   DateTime now = DateTime.now();
  //   DateTime baseDate =
  //       DateTime(now.year, now.month, now.day, time1.hour, time1.minute);
  //   DateTime baseEnd =
  //       DateTime(now.year, now.month, now.day, time2.hour, time2.minute);

  //   Color subjectColor = subject == "Maths"
  //       ? const Color.fromARGB(255, 226, 101, 101)
  //       : subject == "Physics"
  //           ? const Color.fromARGB(255, 63, 123, 214)
  //           : subject == "Chemistry"
  //               ? const Color.fromARGB(255, 233, 157, 43)
  //               : subject == "Biology"
  //                   ? const Color.fromARGB(255, 79, 182, 82)
  //                   : const Color.fromARGB(255, 233, 112, 181);
  //   Appointment createAppointment(DateTime start, DateTime end) => Appointment(
  //         startTime: start,
  //         endTime: end,
  //         subject: subject + " - " + title,
  //         notes: title,
  //         color: subjectColor,
  //       );
  //   setState(() {
  //     if (repeatWeekly) {
  //       for (int i = 0; i < 12; i++) {
  //         final start = baseDate.add(Duration(days: i * 7));
  //         final end = baseEnd.add(Duration(days: i * 7));
  //         _appointments.add(createAppointment(start, end));
  //       }
  //     } else {
  //       _appointments.add(createAppointment(baseDate, baseEnd));
  //     }

  //     _dataSource = MeetingDataSource(_appointments);
  //     _controller.view = CalendarView.day;
  //     _controller.selectedDate = baseDate;
  //     _controller.displayDate = baseDate;
  //   });
  // }
  // Future<void> _addAppointment(
  //   String title,
  //   String subject,
  //   String sessionType,
  //   String target,
  //   TimeOfDay time1,
  //   TimeOfDay time2,
  //   bool repeatWeekly,
  // ) async {
  //   DateTime now = DateTime.now();
  //   DateTime startDate =
  //       DateTime(now.year, now.month, now.day, time1.hour, time1.minute);
  //   DateTime endDate =
  //       DateTime(now.year, now.month, now.day, time2.hour, time2.minute);

  //   final entryId = DateTime.now().millisecondsSinceEpoch.toString();

  //   TimetableEntry newEntry = TimetableEntry(
  //     entryId: entryId,
  //     title: title,
  //     subject: subject,
  //     sessionType: sessionType,
  //     startTime: startDate,
  //     endTime: endDate,
  //     target: target,
  //     repeatWeekly: repeatWeekly,
  //   );

  //   final docSnap = await FirebaseFirestore.instance
  //       .collection('timetables')
  //       .where('studentId', isEqualTo: studentId)
  //       .limit(1)
  //       .get();

  //   if (docSnap.docs.isNotEmpty) {
  //     final doc = docSnap.docs.first;
  //     List<TimetableEntry> currentEntries =
  //         Timetable.fromFirestore(doc).entries;
  //     currentEntries.add(newEntry);

  //     await doc.reference.update({
  //       'entries': currentEntries.map((e) => e.toMap()).toList(),
  //     });

  //     await _fetchAppointmentsFromFirestore(); // refresh UI
  //   }
  // }
  Future<void> _addAppointment(
    String title,
    String subject,
    String sessionType,
    String target,
    TimeOfDay startTime,
    TimeOfDay endTime,
    bool repeatWeekly,
  ) async {
    TimetableEntry newEntry = TimetableEntry(
      entryId: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      subject: subject,
      sessionType: sessionType,
      target: target,
      startTime: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        startTime.hour,
        startTime.minute,
      ),
      endTime: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        endTime.hour,
        endTime.minute,
      ),
      repeatWeekly: repeatWeekly,
    );

    await FirebaseFirestore.instance
        .collection('timetables')
        .doc(studentId)
        .set({
      'studentId': studentId,
      'entries': FieldValue.arrayUnion([newEntry.toMap()])
    }, SetOptions(merge: true));

    await _fetchAppointmentsFromFirestore();
  }

  Future<void> deleteSingleSessionFromFirestore(Appointment appointment) async {
    final timetableSnap = await FirebaseFirestore.instance
        .collection('timetables')
        .where('studentId', isEqualTo: studentId) // pass this from outside
        .limit(1)
        .get();

    if (timetableSnap.docs.isEmpty) return;

    final docRef = timetableSnap.docs.first.reference;
    final data = timetableSnap.docs.first.data();

    final updatedEntries = (data['entries'] as List)
        .where((entry) => entry['entryId'] != appointment.id)
        .toList();

    await docRef.update({'entries': updatedEntries});
  }

  Future<void> deleteAllOccurrencesFromFirestore(
      Appointment appointment) async {
    final timetableSnap = await FirebaseFirestore.instance
        .collection('timetables')
        .where('studentId', isEqualTo: studentId) // pass this from outside
        .limit(1)
        .get();

    if (timetableSnap.docs.isEmpty) return;

    final docRef = timetableSnap.docs.first.reference;
    final data = timetableSnap.docs.first.data();

    final updatedEntries = (data['entries'] as List)
        .where((entry) =>
            entry['subject'] != appointment.subject ||
            entry['repeatWeekly'] != true)
        .toList();

    await docRef.update({'entries': updatedEntries});
  }

  @override
  Widget build(BuildContext context) {
    print("Rebuilding UI. Total appointments: ${_appointments.length}");
    return Scaffold(
      appBar: AppBar(
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
        // onTap: (CalendarTapDetails details) {
        //   if (details.targetElement == CalendarElement.appointment &&
        //       details.appointments != null &&
        //       details.appointments!.isNotEmpty) {
        //     final appointment = details.appointments!.first as Appointment;
        //     showDialog(
        //       context: context,
        //       builder: (context) => AlertDialog(
        //         title: Text("Delete Session"),
        //         content: Text(
        //             "Do you want to delete \"${appointment.notes}\" (${appointment.subject})?"),
        //         actions: [
        //           TextButton(
        //             onPressed: () => Navigator.pop(context),
        //             child: Text("Cancel"),
        //           ),
        //           ElevatedButton(
        //             onPressed: () {
        //               setState(() {
        //                 _appointments.remove(appointment);
        //                 _dataSource = MeetingDataSource(_appointments);
        //               });
        //               Navigator.pop(context);
        //             },
        //             child: Text("Delete"),
        //           ),
        //         ],
        //       ),
        //     );
        //   } else if (details.date != null) {
        //     setState(() {
        //       _selectedDate = details.date!;
        //       if (_controller.view == CalendarView.month) {
        //         _controller.view = CalendarView.day;
        //         _controller.displayDate = _selectedDate;
        //       }
        //     });
        //   }
        // },
        onTap: (CalendarTapDetails details) {
          if (details.targetElement == CalendarElement.appointment &&
              details.appointments != null &&
              details.appointments!.isNotEmpty) {
            final appointment = details.appointments!.first as Appointment;

            // Check if appointment is recurring by matching subject
            final isRecurring = _appointments
                .where(
                    (a) => a.subject == appointment.subject && a != appointment)
                .isNotEmpty;

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Delete Session"),
                content: Text("Do you want to delete ${appointment.subject}?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel"),
                  ),
                  if (isRecurring)
                    TextButton(
                      onPressed: () async {
                        // Remove all matching entries (same subject & recurring)
                        setState(() {
                          _appointments.removeWhere(
                            (a) => a.subject == appointment.subject,
                          );
                          _dataSource = MeetingDataSource(_appointments);
                        });

                        // Delete from Firestore
                        await deleteAllOccurrencesFromFirestore(appointment);

                        Navigator.pop(context);
                      },
                      child: Text("Delete All Occurrences"),
                    ),
                  ElevatedButton(
                    onPressed: () async {
                      // Remove just this one from calendar
                      setState(() {
                        _appointments.remove(appointment);
                        _dataSource = MeetingDataSource(_appointments);
                      });

                      // Delete from Firestore
                      await deleteSingleSessionFromFirestore(appointment);

                      Navigator.pop(context);
                    },
                    child: Text("Delete"),
                  ),
                ],
              ),
            );
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
