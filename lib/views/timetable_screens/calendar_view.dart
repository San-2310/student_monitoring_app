// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
// import 'package:syncfusion_flutter_calendar/calendar.dart' as calendar;

// import '../../models/timetable.dart';

// class CalendarScreenApp extends StatefulWidget {
//   const CalendarScreenApp({super.key});

//   @override
//   _CalendarScreenAppState createState() => _CalendarScreenAppState();
// }

// class _CalendarScreenAppState extends State<CalendarScreenApp> {
//   final calendar.CalendarView _calendarView = calendar.CalendarView.day;
//   List<calendar.Appointment> _appointments = [];
//   late MeetingDataSource _dataSource;
//   final calendar.CalendarController _controller = calendar.CalendarController();
//   DateTime? _selectedDate;
//   @override
//   void initState() {
//     super.initState();
//     _controller.view = _calendarView;
//     _appointments = getAppointments();
//     _dataSource = MeetingDataSource(_appointments);
//     _fetchAppointmentsFromFirestore();
//   }

//   // void _showAddSessionDialog() {
//   //   String? selectedSubject;
//   //   String? selectedDay;
//   //   TimeOfDay? selectedStartTime;
//   //   TimeOfDay? selectedEndTime;
//   //   bool repeatWeekly = false;
//   //   String? sessionTitle;

//   //   showDialog(
//   //     context: context,
//   //     builder: (context) => StatefulBuilder(
//   //       builder: (context, setDialogState) => AlertDialog(
//   //         title: Text("Add Study Session"),
//   //         content: Column(
//   //           mainAxisSize: MainAxisSize.min,
//   //           children: [
//   //             DropdownButtonFormField<String>(
//   //               value: selectedSubject,
//   //               items: ["Maths", "Physics", "Chemistry", "Biology", "Other"]
//   //                   .map((subject) {
//   //                 return DropdownMenuItem(value: subject, child: Text(subject));
//   //               }).toList(),
//   //               onChanged: (value) {
//   //                 setDialogState(() {
//   //                   selectedSubject = value;
//   //                 });
//   //               },
//   //               decoration: InputDecoration(labelText: "Select Subject"),
//   //             ),
//   //             TextField(
//   //               decoration: InputDecoration(labelText: "Session Title"),
//   //               onChanged: (value) {
//   //                 setDialogState(() {
//   //                   sessionTitle = value;
//   //                 });
//   //               },
//   //             ),
//   //             CheckboxListTile(
//   //               title: Text("Repeat every week"),
//   //               value: repeatWeekly,
//   //               onChanged: (value) {
//   //                 setDialogState(() {
//   //                   repeatWeekly = value ?? false;
//   //                 });
//   //               },
//   //             ),
//   //             ElevatedButton(
//   //               onPressed: () async {
//   //                 TimeOfDay? pickedTime = await showTimePicker(
//   //                   context: context,
//   //                   initialTime: TimeOfDay.now(),
//   //                 );
//   //                 if (pickedTime != null) {
//   //                   setDialogState(() {
//   //                     selectedStartTime = pickedTime;
//   //                   });
//   //                 }
//   //               },
//   //               child: Text(selectedStartTime == null
//   //                   ? "Select Start Time"
//   //                   : "Start: ${selectedStartTime!.format(context)}"),
//   //             ),
//   //             ElevatedButton(
//   //               onPressed: () async {
//   //                 TimeOfDay? pickedTime = await showTimePicker(
//   //                   context: context,
//   //                   initialTime: TimeOfDay.now(),
//   //                 );
//   //                 if (pickedTime != null) {
//   //                   setDialogState(() {
//   //                     selectedEndTime = pickedTime;
//   //                   });
//   //                 }
//   //               },
//   //               child: Text(selectedEndTime == null
//   //                   ? "Select End Time"
//   //                   : "End: ${selectedEndTime!.format(context)}"),
//   //             ),
//   //           ],
//   //         ),
//   //         actions: [
//   //           TextButton(
//   //             onPressed: () => Navigator.pop(context),
//   //             child: Text("Cancel"),
//   //           ),
//   //           ElevatedButton(
//   //             onPressed: () {
//   //               if (selectedSubject != null &&
//   //                   selectedStartTime != null &&
//   //                   selectedEndTime != null &&
//   //                   sessionTitle != null &&
//   //                   sessionTitle!.trim().isNotEmpty) {
//   //                 _addAppointment(sessionTitle!, selectedSubject!,
//   //                     selectedStartTime!, selectedEndTime!, repeatWeekly);
//   //                 Navigator.pop(context);
//   //               }
//   //             },
//   //             child: Text("Add"),
//   //           ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }

//   void showEditStudySessionDialog(
//       BuildContext context, Map<String, dynamic> existingSession) {
//     String? selectedSubject = existingSession['subject'];
//     String? sessionTitle = existingSession['title'];
//     String? target = existingSession['target'];
//     bool repeatWeekly = existingSession['repeatWeekly'] ?? false;
//     TimeOfDay? selectedStartTime = existingSession['startTime'];
//     TimeOfDay? selectedEndTime = existingSession['endTime'];

//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setDialogState) => AlertDialog(
//           title: const Text("Edit Study Session"),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // 🧠 Subject Dropdown (Pre-filled)
//                 DropdownButtonFormField2<String>(
//                   isExpanded: true,
//                   value: selectedSubject,
//                   decoration: _inputDecoration("Select Subject"),
//                   items: ["Maths", "Physics", "Chemistry", "Biology", "Other"]
//                       .map((subject) => DropdownMenuItem<String>(
//                             value: subject,
//                             child: Text(
//                               subject,
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ))
//                       .toList(),
//                   onChanged: (value) {
//                     setDialogState(() => selectedSubject = value);
//                   },
//                   dropdownStyleData: DropdownStyleData(
//                     maxHeight: 200,
//                     decoration: BoxDecoration(
//                       color: const Color.fromARGB(255, 217, 251, 255),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   iconStyleData: const IconStyleData(
//                     icon: Icon(Icons.arrow_drop_down, color: Colors.black),
//                     iconSize: 24,
//                   ),
//                   style: const TextStyle(
//                     color: Colors.black,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 8),

//                 // 🧠 Session Title
//                 TextField(
//                   controller: TextEditingController(text: sessionTitle),
//                   decoration: _inputDecoration("Session Title"),
//                   onChanged: (value) =>
//                       setDialogState(() => sessionTitle = value),
//                 ),
//                 const SizedBox(height: 8),

//                 // 🧠 Target
//                 TextField(
//                   controller: TextEditingController(text: target),
//                   decoration: _inputDecoration("Target"),
//                   onChanged: (value) => setDialogState(() => target = value),
//                 ),
//                 const SizedBox(height: 8),

//                 // 🧠 Repeat Weekly Checkbox
//                 Container(
//                   decoration: _checkboxContainerDecoration(),
//                   child: CheckboxListTile(
//                     title: const Text("Repeat every week",
//                         style: TextStyle(
//                             fontWeight: FontWeight.w500, fontSize: 16)),
//                     value: repeatWeekly,
//                     onChanged: (value) =>
//                         setDialogState(() => repeatWeekly = value ?? false),
//                     controlAffinity: ListTileControlAffinity.leading,
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//                     activeColor: Colors.teal,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 // 🧠 Start Time Picker
//                 _timeButton(
//                   context,
//                   label: selectedStartTime == null
//                       ? "Select Start Time"
//                       : "Start: ${selectedStartTime!.format(context)}",
//                   onTap: () {
//                     _showTimeSpinner(
//                       context,
//                       selectedStartTime ?? TimeOfDay.now(),
//                       (picked) =>
//                           setDialogState(() => selectedStartTime = picked),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 8),

//                 // 🧠 End Time Picker
//                 _timeButton(
//                   context,
//                   label: selectedEndTime == null
//                       ? "Select End Time"
//                       : "End: ${selectedEndTime!.format(context)}",
//                   onTap: () {
//                     _showTimeSpinner(
//                       context,
//                       selectedEndTime ?? TimeOfDay.now(),
//                       (picked) =>
//                           setDialogState(() => selectedEndTime = picked),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text("Cancel")),
//             ElevatedButton(
//               onPressed: () async {
//                 if (selectedSubject != null &&
//                     sessionTitle != null &&
//                     target != null &&
//                     selectedStartTime != null &&
//                     selectedEndTime != null) {
//                   await _editAppointment(
//                     existingSession['entryId'],
//                     sessionTitle!,
//                     selectedSubject!,
//                     target!,
//                     selectedStartTime!,
//                     selectedEndTime!,
//                     repeatWeekly,
//                   );
//                   Navigator.pop(context);
//                 }
//               },
//               child: const Text("Update"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showAddSessionDialog() {
//     String? selectedSubject;
//     //String? selectedSessionType;
//     String? selectedDay;
//     String? target;
//     TimeOfDay? selectedStartTime;
//     TimeOfDay? selectedEndTime;
//     bool repeatWeekly = false;
//     String? sessionTitle;

//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setDialogState) => AlertDialog(
//           title: const Text("Add Study Session"),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // DropdownButtonFormField<String>(
//                 //   value: selectedSubject,
//                 //   items: ["Maths", "Physics", "Chemistry", "Biology", "Other"]
//                 //       .map((subject) {
//                 //     return DropdownMenuItem(
//                 //         value: subject, child: Text(subject));
//                 //   }).toList(),
//                 //   onChanged: (value) {
//                 //     setDialogState(() {
//                 //       selectedSubject = value;
//                 //     });
//                 //   },
//                 //   decoration:
//                 //       const InputDecoration(labelText: "Select Subject"),
//                 // ),
//                 // DropdownButtonFormField<String>(
//                 //   value: selectedSessionType,
//                 //   items: ["Study", "Lecture", "Revision", "Practice", "Other"]
//                 //       .map((type) {
//                 //     return DropdownMenuItem(value: type, child: Text(type));
//                 //   }).toList(),
//                 //   onChanged: (value) {
//                 //     setDialogState(() {
//                 //       selectedSessionType = value;
//                 //     });
//                 //   },
//                 //   decoration: const InputDecoration(labelText: "Session Type"),
//                 // ),
//                 DropdownButtonFormField2<String>(
//                   isExpanded: true,
//                   value: selectedSubject,
//                   decoration: InputDecoration(
//                     contentPadding: const EdgeInsets.symmetric(
//                         vertical: 20, horizontal: 16),
//                     labelText: "Select Subject",
//                     labelStyle: const TextStyle(
//                       color: Colors.black54,
//                       fontWeight: FontWeight.w500,
//                       fontSize: 16,
//                     ),
//                     filled: true,
//                     fillColor: const Color.fromARGB(255, 223, 251, 255),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide:
//                           const BorderSide(color: Colors.black54, width: 1.5),
//                     ),
//                   ),
//                   items: ["Maths", "Physics", "Chemistry", "Biology", "Other"]
//                       .map((subject) => DropdownMenuItem<String>(
//                             value: subject,
//                             child: Text(
//                               subject,
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ))
//                       .toList(),
//                   onChanged: (value) {
//                     setDialogState(() {
//                       selectedSubject = value;
//                     });
//                   },
//                   dropdownStyleData: DropdownStyleData(
//                     maxHeight: 200,
//                     decoration: BoxDecoration(
//                       color: const Color.fromARGB(255, 217, 251, 255),
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 10,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                   ),
//                   iconStyleData: const IconStyleData(
//                     icon: Icon(Icons.arrow_drop_down, color: Colors.black),
//                     iconSize: 24,
//                   ),
//                   style: const TextStyle(
//                     color: Colors.black,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),

//                 const SizedBox(height: 8),

// // Session Title TextField
//                 TextField(
//                   decoration: InputDecoration(
//                     labelText: "Session Title",
//                     labelStyle: const TextStyle(
//                       color: Colors.black54,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     filled: true,
//                     fillColor: const Color.fromARGB(255, 223, 251, 255),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide:
//                           const BorderSide(color: Colors.black54, width: 1.5),
//                     ),
//                   ),
//                   onChanged: (value) {
//                     setDialogState(() {
//                       sessionTitle = value;
//                     });
//                   },
//                 ),
//                 const SizedBox(height: 8),
//                 // Target TextField
//                 TextField(
//                   decoration: InputDecoration(
//                     labelText: "Target",
//                     labelStyle: const TextStyle(
//                       color: Colors.black54,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     filled: true,
//                     fillColor: const Color.fromARGB(255, 223, 251, 255),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide:
//                           const BorderSide(color: Colors.black54, width: 1.5),
//                     ),
//                   ),
//                   onChanged: (value) {
//                     setDialogState(() {
//                       target = value;
//                     });
//                   },
//                 ),
//                 const SizedBox(height: 8),
//                 // Styled Checkbox
//                 Container(
//                   decoration: BoxDecoration(
//                     color: const Color.fromARGB(255, 223, 251, 255),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.grey.shade300),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 5,
//                         offset: const Offset(0, 2),
//                       )
//                     ],
//                   ),
//                   child: CheckboxListTile(
//                     title: const Text(
//                       "Repeat every week",
//                       style: TextStyle(
//                         fontWeight: FontWeight.w500,
//                         fontSize: 16,
//                       ),
//                     ),
//                     value: repeatWeekly,
//                     onChanged: (value) {
//                       setDialogState(() {
//                         repeatWeekly = value ?? false;
//                       });
//                     },
//                     controlAffinity: ListTileControlAffinity.leading,
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//                     activeColor: Colors.teal,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//                 // TextField(
//                 //   decoration: const InputDecoration(labelText: "Session Title"),
//                 //   onChanged: (value) {
//                 //     setDialogState(() {
//                 //       sessionTitle = value;
//                 //     });
//                 //   },
//                 // ),
//                 // TextField(
//                 //   decoration: const InputDecoration(labelText: "Target"),
//                 //   onChanged: (value) {
//                 //     setDialogState(() {
//                 //       target = value;
//                 //     });
//                 //   },
//                 // ),
//                 // CheckboxListTile(
//                 //   title: const Text("Repeat every week"),
//                 //   value: repeatWeekly,
//                 //   onChanged: (value) {
//                 //     setDialogState(() {
//                 //       repeatWeekly = value ?? false;
//                 //     });
//                 //   },
//                 // ),
//                 // ElevatedButton(
//                 //   onPressed: () async {
//                 //     TimeOfDay? pickedTime = await showTimePicker(
//                 //       context: context,
//                 //       initialTime: TimeOfDay.now(),
//                 //     );
//                 //     if (pickedTime != null) {
//                 //       setDialogState(() {
//                 //         selectedStartTime = pickedTime;
//                 //       });
//                 //     }
//                 //   },
//                 //   child: Text(selectedStartTime == null
//                 //       ? "Select Start Time"
//                 //       : "Start: ${selectedStartTime!.format(context)}"),
//                 // ),
//                 const SizedBox(height: 8),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color.fromARGB(
//                         255, 86, 206, 206), // custom background
//                     foregroundColor: Colors.white, // text & icon color
//                     shape: RoundedRectangleBorder(
//                       borderRadius:
//                           BorderRadius.circular(16), // rounded corners
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 20, vertical: 16),
//                     elevation: 4, // shadow
//                     textStyle: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   onPressed: () {
//                     showDialog(
//                       context: context,
//                       builder: (context) {
//                         TimeOfDay tempPickedTime =
//                             selectedStartTime ?? TimeOfDay.now();

//                         return AlertDialog(
//                           title: const Text("Pick Time"),
//                           content: SizedBox(
//                             height: 150,
//                             child: TimePickerSpinner(
//                               is24HourMode: false,
//                               normalTextStyle: const TextStyle(
//                                   fontSize: 18, color: Colors.grey),
//                               highlightedTextStyle: const TextStyle(
//                                   fontSize: 24, color: Colors.black),
//                               spacing: 40,
//                               itemHeight: 40,
//                               isForce2Digits: true,
//                               time: DateTime(
//                                 0,
//                                 0,
//                                 0,
//                                 tempPickedTime.hour,
//                                 tempPickedTime.minute,
//                               ),
//                               onTimeChange: (DateTime time) {
//                                 tempPickedTime = TimeOfDay(
//                                     hour: time.hour, minute: time.minute);
//                               },
//                             ),
//                           ),
//                           actions: [
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.of(context).pop();
//                                 setDialogState(() {
//                                   selectedStartTime = tempPickedTime;
//                                 });
//                               },
//                               child: const Text("OK"),
//                             ),
//                           ],
//                         );
//                       },
//                     );
//                   },
//                   child: Text(selectedStartTime == null
//                       ? "Select Start Time"
//                       : "Start: ${selectedStartTime!.format(context)}"),
//                 ),
//                 // ElevatedButton(
//                 //   onPressed: () async {
//                 //     TimeOfDay? pickedTime = await showTimePicker(
//                 //       context: context,
//                 //       initialTime: TimeOfDay.now(),
//                 //     );
//                 //     if (pickedTime != null) {
//                 //       setDialogState(() {
//                 //         selectedEndTime = pickedTime;
//                 //       });
//                 //     }
//                 //   },
//                 //   child: Text(selectedEndTime == null
//                 //       ? "Select End Time"
//                 //       : "End: ${selectedEndTime!.format(context)}"),
//                 // ),
//                 SizedBox(
//                   height: 8,
//                 ),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color.fromARGB(
//                         255, 58, 183, 183), // custom background
//                     foregroundColor: Colors.white, // text & icon color
//                     shape: RoundedRectangleBorder(
//                       borderRadius:
//                           BorderRadius.circular(16), // rounded corners
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 24, vertical: 16),
//                     elevation: 4, // shadow
//                     textStyle: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   onPressed: () {
//                     showDialog(
//                       context: context,
//                       builder: (context) {
//                         TimeOfDay tempPickedTime =
//                             selectedEndTime ?? TimeOfDay.now();

//                         return AlertDialog(
//                           title: const Text("Pick End Time"),
//                           content: SizedBox(
//                             height: 150,
//                             child: TimePickerSpinner(
//                               is24HourMode: false,
//                               normalTextStyle: const TextStyle(
//                                   fontSize: 18, color: Colors.grey),
//                               highlightedTextStyle: const TextStyle(
//                                   fontSize: 24, color: Colors.black),
//                               spacing: 40,
//                               itemHeight: 40,
//                               isForce2Digits: true,
//                               time: DateTime(
//                                 0,
//                                 0,
//                                 0,
//                                 tempPickedTime.hour,
//                                 tempPickedTime.minute,
//                               ),
//                               onTimeChange: (DateTime time) {
//                                 tempPickedTime = TimeOfDay(
//                                     hour: time.hour, minute: time.minute);
//                               },
//                             ),
//                           ),
//                           actions: [
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.of(context).pop();
//                                 setDialogState(() {
//                                   selectedEndTime = tempPickedTime;
//                                 });
//                               },
//                               child: const Text("OK"),
//                             ),
//                           ],
//                         );
//                       },
//                     );
//                   },
//                   child: Text(selectedEndTime == null
//                       ? "Select End Time"
//                       : "End: ${selectedEndTime!.format(context)}"),
//                 ),
//               ],
//             ),
//           ),
//           //   actions: [
//           //     TextButton(
//           //       onPressed: () => Navigator.pop(context),
//           //       child: const Text("Cancel"),
//           //     ),
//           //     ElevatedButton(
//           //       onPressed: () {
//           //         if (selectedSubject != null &&
//           //             selectedStartTime != null &&
//           //             selectedEndTime != null &&
//           //             sessionTitle != null &&
//           //             sessionTitle!.trim().isNotEmpty &&
//           //             target != null) {
//           //           _addAppointment(
//           //             sessionTitle!,
//           //             selectedSubject!,
//           //             //selectedSessionType!,
//           //             target!,
//           //             selectedStartTime!,
//           //             selectedEndTime!,
//           //             repeatWeekly,
//           //           );
//           //           Navigator.pop(context);
//           //         }
//           //       },
//           //       child: const Text("Add"),
//           //     ),
//           //   ],
//           actions: [
//             // Cancel Button (Subtle and clean)
//             TextButton.icon(
//               onPressed: () => Navigator.pop(context),
//               icon: const Icon(Icons.close, color: Colors.black54),
//               label: const Text(
//                 "Cancel",
//                 style: TextStyle(
//                   color: Colors.black54,
//                   fontWeight: FontWeight.w500,
//                   fontSize: 16,
//                 ),
//               ),
//             ),

//             // Add Button (High Contrast CTA)
//             ElevatedButton.icon(
//               onPressed: () {
//                 if (selectedSubject != null &&
//                     selectedStartTime != null &&
//                     selectedEndTime != null &&
//                     sessionTitle != null &&
//                     sessionTitle!.trim().isNotEmpty &&
//                     target != null) {
//                   // Time comparison logic
//                   final startMinutes =
//                       selectedStartTime!.hour * 60 + selectedStartTime!.minute;
//                   final endMinutes =
//                       selectedEndTime!.hour * 60 + selectedEndTime!.minute;

//                   if (startMinutes >= endMinutes) {
//                     // Show error dialog
//                     showDialog(
//                       context: context,
//                       builder: (context) => AlertDialog(
//                         title: const Text("Invalid Time"),
//                         content:
//                             const Text("Start time must be before End time."),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: const Text("OK"),
//                           ),
//                         ],
//                       ),
//                     );
//                     return;
//                   }

//                   // If time is valid, proceed
//                   _addAppointment(
//                     sessionTitle!,
//                     selectedSubject!,
//                     target!,
//                     selectedStartTime!,
//                     selectedEndTime!,
//                     repeatWeekly,
//                   );
//                   Navigator.pop(context);
//                 }
//               },
//               icon: const Icon(Icons.check_circle, color: Colors.white),
//               label: const Text(
//                 "Add",
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 16,
//                 ),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF00B7C2), // Teal shade
//                 foregroundColor: Colors.white,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 elevation: 3,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   final studentId = FirebaseAuth
//       .instance.currentUser!.uid; // Get this from FirebaseAuth or state

//   Future<void> _fetchAppointmentsFromFirestore() async {
//     final timetableSnap = await FirebaseFirestore.instance
//         .collection('timetables')
//         .where('studentId', isEqualTo: studentId)
//         .limit(1)
//         .get();

//     if (timetableSnap.docs.isEmpty) return;

//     final timetable = Timetable.fromFirestore(timetableSnap.docs.first);

//     final List<calendar.Appointment> fetchedAppointments = [];

//     for (var entry in timetable.entries) {
//       if (entry.repeatWeekly) {
//         for (int i = 0; i < 12; i++) {
//           final DateTime repeatedStart =
//               entry.startTime.add(Duration(days: i * 7));
//           final DateTime repeatedEnd = entry.endTime.add(Duration(days: i * 7));
//           fetchedAppointments
//               .add(_entryToAppointment(entry, repeatedStart, repeatedEnd));
//         }
//       } else {
//         fetchedAppointments
//             .add(_entryToAppointment(entry, entry.startTime, entry.endTime));
//       }
//     }

//     setState(() {
//       _appointments = fetchedAppointments;
//       _dataSource = MeetingDataSource(_appointments);
//     });
//   }

//   calendar.Appointment _entryToAppointment(
//       TimetableEntry entry, DateTime start, DateTime end) {
//     final subject = entry.subject;
//     Color subjectColor = subject == "Maths"
//         ? const Color.fromARGB(255, 226, 101, 101)
//         : subject == "Physics"
//             ? const Color.fromARGB(255, 63, 123, 214)
//             : subject == "Chemistry"
//                 ? const Color.fromARGB(255, 233, 157, 43)
//                 : subject == "Biology"
//                     ? const Color.fromARGB(255, 79, 182, 82)
//                     : const Color.fromARGB(255, 233, 112, 181);
//     return calendar.Appointment(
//       id: entry.entryId,
//       startTime: start,
//       endTime: end,
//       subject: '${entry.subject} - ${entry.title}',
//       notes: entry.entryId, // Used for deletion
//       color: subjectColor,
//     );
//   }

//   // void _addAppointment(String title, String subject, TimeOfDay time1,
//   //     TimeOfDay time2, bool repeatWeekly) {
//   //   DateTime now = DateTime.now();
//   //   DateTime baseDate =
//   //       DateTime(now.year, now.month, now.day, time1.hour, time1.minute);
//   //   DateTime baseEnd =
//   //       DateTime(now.year, now.month, now.day, time2.hour, time2.minute);

//   //   Color subjectColor = subject == "Maths"
//   //       ? const Color.fromARGB(255, 226, 101, 101)
//   //       : subject == "Physics"
//   //           ? const Color.fromARGB(255, 63, 123, 214)
//   //           : subject == "Chemistry"
//   //               ? const Color.fromARGB(255, 233, 157, 43)
//   //               : subject == "Biology"
//   //                   ? const Color.fromARGB(255, 79, 182, 82)
//   //                   : const Color.fromARGB(255, 233, 112, 181);
//   //   Appointment createAppointment(DateTime start, DateTime end) => Appointment(
//   //         startTime: start,
//   //         endTime: end,
//   //         subject: subject + " - " + title,
//   //         notes: title,
//   //         color: subjectColor,
//   //       );
//   //   setState(() {
//   //     if (repeatWeekly) {
//   //       for (int i = 0; i < 12; i++) {
//   //         final start = baseDate.add(Duration(days: i * 7));
//   //         final end = baseEnd.add(Duration(days: i * 7));
//   //         _appointments.add(createAppointment(start, end));
//   //       }
//   //     } else {
//   //       _appointments.add(createAppointment(baseDate, baseEnd));
//   //     }

//   //     _dataSource = MeetingDataSource(_appointments);
//   //     _controller.view = CalendarView.day;
//   //     _controller.selectedDate = baseDate;
//   //     _controller.displayDate = baseDate;
//   //   });
//   // }
//   // Future<void> _addAppointment(
//   //   String title,
//   //   String subject,
//   //   String sessionType,
//   //   String target,
//   //   TimeOfDay time1,
//   //   TimeOfDay time2,
//   //   bool repeatWeekly,
//   // ) async {
//   //   DateTime now = DateTime.now();
//   //   DateTime startDate =
//   //       DateTime(now.year, now.month, now.day, time1.hour, time1.minute);
//   //   DateTime endDate =
//   //       DateTime(now.year, now.month, now.day, time2.hour, time2.minute);

//   //   final entryId = DateTime.now().millisecondsSinceEpoch.toString();

//   //   TimetableEntry newEntry = TimetableEntry(
//   //     entryId: entryId,
//   //     title: title,
//   //     subject: subject,
//   //     sessionType: sessionType,
//   //     startTime: startDate,
//   //     endTime: endDate,
//   //     target: target,
//   //     repeatWeekly: repeatWeekly,
//   //   );

//   //   final docSnap = await FirebaseFirestore.instance
//   //       .collection('timetables')
//   //       .where('studentId', isEqualTo: studentId)
//   //       .limit(1)
//   //       .get();

//   //   if (docSnap.docs.isNotEmpty) {
//   //     final doc = docSnap.docs.first;
//   //     List<TimetableEntry> currentEntries =
//   //         Timetable.fromFirestore(doc).entries;
//   //     currentEntries.add(newEntry);

//   //     await doc.reference.update({
//   //       'entries': currentEntries.map((e) => e.toMap()).toList(),
//   //     });

//   //     await _fetchAppointmentsFromFirestore(); // refresh UI
//   //   }
//   // }
//   // Future<void> _addAppointment(
//   //   String title,
//   //   String subject,
//   //   String sessionType,
//   //   String target,
//   //   TimeOfDay startTime,
//   //   TimeOfDay endTime,
//   //   bool repeatWeekly,
//   // ) async {
//   //   TimetableEntry newEntry = TimetableEntry(
//   //     entryId: DateTime.now().millisecondsSinceEpoch.toString(),
//   //     title: title,
//   //     subject: subject,
//   //     sessionType: sessionType,
//   //     target: target,
//   //     startTime: DateTime(
//   //       DateTime.now().year,
//   //       DateTime.now().month,
//   //       DateTime.now().day,
//   //       startTime.hour,
//   //       startTime.minute,
//   //     ),
//   //     endTime: DateTime(
//   //       DateTime.now().year,
//   //       DateTime.now().month,
//   //       DateTime.now().day,
//   //       endTime.hour,
//   //       endTime.minute,
//   //     ),
//   //     repeatWeekly: repeatWeekly,
//   //   );

//   //   await FirebaseFirestore.instance
//   //       .collection('timetables')
//   //       .doc(studentId)
//   //       .set({
//   //     'studentId': studentId,
//   //     'entries': FieldValue.arrayUnion([newEntry.toMap()])
//   //   }, SetOptions(merge: true));

//   //   await _fetchAppointmentsFromFirestore();
//   // }
//   Future<void> _addAppointment(
//     String title,
//     String subject,
//     //String sessionType,
//     String target,
//     TimeOfDay startTime,
//     TimeOfDay endTime,
//     bool repeatWeekly,
//   ) async {
//     // 🔒 Always get the latest data from server
//     final snapshot = await FirebaseFirestore.instance
//         .collection('timetables')
//         .doc(studentId)
//         .get(const GetOptions(source: Source.server));

//     List<dynamic> currentEntries = [];
//     if (snapshot.exists && snapshot.data()!.containsKey('entries')) {
//       currentEntries = snapshot.data()!['entries'];
//     }

//     TimetableEntry newEntry = TimetableEntry(
//       entryId: DateTime.now().millisecondsSinceEpoch.toString(),
//       title: title,
//       subject: subject,
//       sessionType: "",
//       target: target,
//       startTime: DateTime(
//         DateTime.now().year,
//         DateTime.now().month,
//         DateTime.now().day,
//         startTime.hour,
//         startTime.minute,
//       ),
//       endTime: DateTime(
//         DateTime.now().year,
//         DateTime.now().month,
//         DateTime.now().day,
//         endTime.hour,
//         endTime.minute,
//       ),
//       repeatWeekly: repeatWeekly,
//       done: false,
//     );

//     // ✅ Add to current list
//     currentEntries.add(newEntry.toMap());

//     // 🔥 Full overwrite — not merge
//     await FirebaseFirestore.instance
//         .collection('timetables')
//         .doc(studentId)
//         .set({
//       'studentId': studentId,
//       'entries': currentEntries,
//     }, SetOptions(merge: false));

//     // Refresh UI
//     await _fetchAppointmentsFromFirestore();
//   }

//   Future<void> _editAppointment(
//     String entryId,
//     String title,
//     String subject,
//     String target,
//     TimeOfDay startTime,
//     TimeOfDay endTime,
//     bool repeatWeekly,
//   ) async {
//     // 🔒 Get latest data
//     final snapshot = await FirebaseFirestore.instance
//         .collection('timetables')
//         .doc(studentId)
//         .get(const GetOptions(source: Source.server));

//     List<dynamic> currentEntries = [];
//     if (snapshot.exists && snapshot.data()!.containsKey('entries')) {
//       currentEntries = snapshot.data()!['entries'];
//     }

//     // 🧠 Replace the existing entry
//     currentEntries = currentEntries.map((entry) {
//       if (entry['entryId'] == entryId) {
//         return TimetableEntry(
//           entryId: entryId,
//           title: title,
//           subject: subject,
//           sessionType: "", // Optional
//           target: target,
//           startTime: DateTime(
//             DateTime.now().year,
//             DateTime.now().month,
//             DateTime.now().day,
//             startTime.hour,
//             startTime.minute,
//           ),
//           endTime: DateTime(
//             DateTime.now().year,
//             DateTime.now().month,
//             DateTime.now().day,
//             endTime.hour,
//             endTime.minute,
//           ),
//           repeatWeekly: repeatWeekly,
//           done: false,
//         ).toMap();
//       }
//       return entry;
//     }).toList();

//     // 🔥 Save updated list
//     await FirebaseFirestore.instance
//         .collection('timetables')
//         .doc(studentId)
//         .set({
//       'studentId': studentId,
//       'entries': currentEntries,
//     }, SetOptions(merge: false));

//     // Refresh UI
//     await _fetchAppointmentsFromFirestore();
//   }

//   Future<void> deleteSingleSessionFromFirestore(
//       String studentId, calendar.Appointment appointment) async {
//     final docRef =
//         FirebaseFirestore.instance.collection('timetables').doc(studentId);

//     final snapshot = await docRef.get(const GetOptions(source: Source.server));

//     if (!snapshot.exists) return;

//     final data = snapshot.data();
//     if (data == null || !data.containsKey('entries')) return;

//     final originalEntries = List<Map<String, dynamic>>.from(data['entries']);

//     final updatedEntries = originalEntries.where((entry) {
//       //print(
// //"Firestore entryId: ${entry['entryId']} vs Appointment ID: ${appointment.id}");

//       final isMatch = entry['entryId'] == appointment.id;
//       if (isMatch) {
//         //print("✅ Deleting entryId: ${entry['entryId']}");
//       }
//       return !isMatch;
//     }).toList();

//     await docRef.set({
//       'studentId': studentId,
//       'entries': updatedEntries,
//     }, SetOptions(merge: false)); // ✅ Overwrites the entire doc

//     // print("Updated entries count: ${updatedEntries.length}");
//   }

//   Future<void> deleteAllOccurrencesFromFirestore(
//       String studentId, calendar.Appointment appointment) async {
//     final docRef =
//         FirebaseFirestore.instance.collection('timetables').doc(studentId);

//     final snapshot = await docRef.get(const GetOptions(source: Source.server));

//     if (!snapshot.exists) return;

//     final data = snapshot.data();
//     if (data == null || !data.containsKey('entries')) return;

//     final originalEntries = List<Map<String, dynamic>>.from(data['entries']);

//     final updatedEntries = originalEntries.where((entry) {
//       final isMatch = entry['subject'] == appointment.subject &&
//           entry['repeatWeekly'] == true;
//       if (isMatch) {
//         //print("Deleting recurring entry for subject: ${entry['subject']}");
//       }
//       return !isMatch;
//     }).toList();

//     await docRef.set({
//       'studentId': studentId,
//       'entries': updatedEntries,
//     }, SetOptions(merge: false)); // ✅ Full replace

//     //print("Recurring entries deleted, remaining: ${updatedEntries.length}");
//   }

//   @override
//   Widget build(BuildContext context) {
//     //print("Rebuilding UI. Total appointments: ${_appointments.length}");
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(0, 254, 255, 255),
//         title: const Text(
//           'Create Timetable',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         // title: DropdownButtonHideUnderline(
//         //   child: DropdownButton<CalendarView>(
//         //     value: _controller.view,
//         //     onChanged: (CalendarView? newView) {
//         //       if (newView != null) {
//         //         setState(() {
//         //           _controller.view = newView;
//         //           if (newView == CalendarView.day && _selectedDate != null) {
//         //             _controller.displayDate = _selectedDate;
//         //           }
//         //         });
//         //       }
//         //     },
//         //     items: const [
//         //       DropdownMenuItem(value: CalendarView.day, child: Text('Day')),
//         //       DropdownMenuItem(value: CalendarView.week, child: Text('Week')),
//         //       DropdownMenuItem(value: CalendarView.month, child: Text('Month')),
//         //     ],
//         //   ),
//         //   // DropdownButton<CalendarView>(
//         //   //   value: _calendarView,
//         //   //   icon: Icon(Icons.arrow_drop_down, color: Colors.white),
//         //   //   dropdownColor: Colors.white,
//         //   //   onChanged: (CalendarView? newView) {
//         //   //     if (newView != null) {
//         //   //       setState(() {
//         //   //         _calendarView = newView;
//         //   //         if (newView == CalendarView.day && _selectedDate != null) {
//         //   //           _controller.displayDate = _selectedDate;
//         //   //         }
//         //   //       });
//         //   //     }
//         //   //   },
//         //   //   items: const [
//         //   //     DropdownMenuItem(
//         //   //       value: CalendarView.day,
//         //   //       child: Text('Day'),
//         //   //     ),
//         //   //     DropdownMenuItem(
//         //   //       value: CalendarView.week,
//         //   //       child: Text('Week'),
//         //   //     ),
//         //   //     DropdownMenuItem(
//         //   //       value: CalendarView.month,
//         //   //       child: Text('Month'),
//         //   //     ),
//         //   //   ],
//         //   // ),
//         // ),
//         // actions: [
//         //   IconButton(
//         //     icon: const Icon(Icons.add),
//         //     onPressed: _showAddSessionDialog,
//         //   ),
//         //   // IconButton(
//         //   //   icon: const Icon(Icons.notifications),
//         //   //   color: const Color.fromARGB(255, 31, 115, 121),
//         //   //   onPressed: () {},
//         //   // ),
//         //   // IconButton(
//         //   //   icon: const Icon(Icons.person),
//         //   //   color: const Color.fromARGB(255, 0, 0, 0),
//         //   //   onPressed: () {},
//         //   // ),
//         // ],
//       ),
//       body:
//           // SfCalendar(
//           //   key: ValueKey(_calendarView),
//           //   controller: _controller,
//           //   view: _calendarView,
//           //   firstDayOfWeek: 1,
//           //   onTap: (details) {
//           //     if (details.date != null) {
//           //       setState(() {
//           //         _selectedDate = details.date!;
//           //       });
//           //     }
//           //   },
//           //   dataSource: MeetingDataSource(_appointments),
//           //   monthViewSettings: MonthViewSettings(showAgenda: true),
//           // ),
//           //     SfCalendar(
//           //   //controller: _controller,
//           //   key: ValueKey(_calendarView),
//           //   view: _calendarView,
//           //   firstDayOfWeek: 1,
//           //   dataSource: MeetingDataSource(_appointments),
//           //   monthViewSettings: MonthViewSettings(showAgenda: true),
//           //   onTap: (CalendarTapDetails details) {
//           //     if (details.date != null) {
//           //       setState(
//           //         () {
//           //           _selectedDate = details.date!;
//           //           if (_calendarView == CalendarView.month) {
//           //             _calendarView = CalendarView.day;
//           //             _controller.displayDate = _selectedDate;
//           //           }
//           //         },
//           //       );
//           //     }
//           //   },
//           // ),
//           Column(
//         children: [
//           SizedBox(
//             height: 10,
//           ),
//           // Row(
//           //   mainAxisAlignment: _controller.view == CalendarView.day
//           //       ? MainAxisAlignment.spaceAround
//           //       : MainAxisAlignment.center,
//           //   children: [
//           //     Container(
//           //       width: 150,
//           //       padding: const EdgeInsets.symmetric(horizontal: 16),
//           //       decoration: BoxDecoration(
//           //         color: const Color.fromARGB(255, 172, 235, 243),
//           //         borderRadius: BorderRadius.circular(12),
//           //         boxShadow: [
//           //           BoxShadow(
//           //             color: Colors.grey.withOpacity(0.2),
//           //             spreadRadius: 2,
//           //             blurRadius: 5,
//           //             offset: const Offset(0, 3), // shadow direction
//           //           ),
//           //         ],
//           //         border: Border.all(color: Colors.grey.shade300),
//           //       ),
//           //       child: DropdownButtonHideUnderline(
//           //         child: DropdownButton<CalendarView>(
//           //           value: _controller.view,
//           //           onChanged: (CalendarView? newView) {
//           //             if (newView != null) {
//           //               setState(() {
//           //                 _controller.view = newView;
//           //                 if (newView == CalendarView.day &&
//           //                     _selectedDate != null) {
//           //                   _controller.displayDate = _selectedDate;
//           //                 }
//           //               });
//           //             }
//           //           },
//           //           items: const [
//           //             DropdownMenuItem(
//           //                 value: CalendarView.day, child: Text('Day')),
//           //             DropdownMenuItem(
//           //                 value: CalendarView.week, child: Text('Week')),
//           //             DropdownMenuItem(
//           //                 value: CalendarView.month, child: Text('Month')),
//           //           ],
//           //         ),
//           //       ),
//           //     ),
//           //     // IconButton(
//           //     //   icon: const Icon(Icons.add),
//           //     //   onPressed: _showAddSessionDialog,
//           //     // ),

//           //     _controller.view == CalendarView.day
//           //         ? GestureDetector(
//           //             onTap: () {
//           //               _showAddSessionDialog();
//           //             },
//           //             child: Container(
//           //               width: 100,
//           //               child: Text(
//           //                 "Add entry +",
//           //                 style: TextStyle(
//           //                   fontSize: 16,
//           //                   color: Colors.black,
//           //                   fontWeight: FontWeight.w500,
//           //                 ),
//           //               ),
//           //             ),
//           //           )
//           //         : SizedBox.shrink(), // Empty widget if not day view
//           //   ],
//           // ),

//           Row(
//             mainAxisAlignment: _controller.view == calendar.CalendarView.day
//                 ? MainAxisAlignment.spaceAround
//                 : MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 150,
//                 child: DropdownButtonHideUnderline(
//                   child: DropdownButton2<calendar.CalendarView>(
//                     isExpanded: true,
//                     value: _controller.view,
//                     onChanged: (calendar.CalendarView? newView) {
//                       if (newView != null) {
//                         setState(() {
//                           _controller.view = newView;
//                           if (newView == calendar.CalendarView.day &&
//                               _selectedDate != null) {
//                             _controller.displayDate = _selectedDate;
//                           }
//                         });
//                       }
//                     },
//                     items: const [
//                       DropdownMenuItem(
//                         value: calendar.CalendarView.day,
//                         child: Text('Day'),
//                       ),
//                       DropdownMenuItem(
//                         value: calendar.CalendarView.week,
//                         child: Text('Week'),
//                       ),
//                       DropdownMenuItem(
//                         value: calendar.CalendarView.month,
//                         child: Text('Month'),
//                       ),
//                     ],
//                     buttonStyleData: ButtonStyleData(
//                       height: 50,
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       decoration: BoxDecoration(
//                         color: const Color.fromARGB(255, 172, 235, 243),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.grey.shade300),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.2),
//                             blurRadius: 5,
//                             offset: const Offset(0, 3),
//                           ),
//                         ],
//                       ),
//                     ),
//                     dropdownStyleData: DropdownStyleData(
//                       maxHeight: 200,
//                       decoration: BoxDecoration(
//                         color: const Color.fromARGB(255, 208, 243, 248),
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 10,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                     ),
//                     iconStyleData: const IconStyleData(
//                       icon: Icon(Icons.arrow_drop_down, color: Colors.black),
//                       iconSize: 24,
//                     ),
//                     style: const TextStyle(
//                       color: Colors.black,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),

//               // ⬇️ Styled Add Entry Button Matching Dropdown
//               _controller.view == calendar.CalendarView.day
//                   ? GestureDetector(
//                       onTap: _showAddSessionDialog,
//                       child: Container(
//                         width: 150,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 12),
//                         decoration: BoxDecoration(
//                           color: const Color.fromARGB(255, 172, 235, 243),
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.grey.shade300),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.2),
//                               blurRadius: 5,
//                               offset: const Offset(0, 3),
//                             ),
//                           ],
//                         ),
//                         child: const Center(
//                           child: Text(
//                             "Add entry +",
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.black,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                     )
//                   : const SizedBox.shrink(),
//             ],
//           ),
//           // SizedBox(
//           //   height: 8,
//           // ),
//           Expanded(
//             child: calendar.SfCalendar(
//               //backgroundColor: Color.fromARGB(1, 229, 245, 253)
//               //todayHighlightColor: Color.fromARGB(1, 13, 30, 38),
//               //cellBorderColor: Color.fromARGB(1, 3, 26, 38),
//               controller: _controller,
//               key: ValueKey(_controller.view),
//               firstDayOfWeek: 1,
//               dataSource: _dataSource,
//               monthViewSettings:
//                   const calendar.MonthViewSettings(showAgenda: true),
//               // onTap: (CalendarTapDetails details) {
//               //   if (details.targetElement == CalendarElement.appointment &&
//               //       details.appointments != null &&
//               //       details.appointments!.isNotEmpty) {
//               //     final appointment = details.appointments!.first as Appointment;
//               //     showDialog(
//               //       context: context,
//               //       builder: (context) => AlertDialog(
//               //         title: Text("Delete Session"),
//               //         content: Text(
//               //             "Do you want to delete \"${appointment.notes}\" (${appointment.subject})?"),
//               //         actions: [
//               //           TextButton(
//               //             onPressed: () => Navigator.pop(context),
//               //             child: Text("Cancel"),
//               //           ),
//               //           ElevatedButton(
//               //             onPressed: () {
//               //               setState(() {
//               //                 _appointments.remove(appointment);
//               //                 _dataSource = MeetingDataSource(_appointments);
//               //               });
//               //               Navigator.pop(context);
//               //             },
//               //             child: Text("Delete"),
//               //           ),
//               //         ],
//               //       ),
//               //     );
//               //   } else if (details.date != null) {
//               //     setState(() {
//               //       _selectedDate = details.date!;
//               //       if (_controller.view == CalendarView.month) {
//               //         _controller.view = CalendarView.day;
//               //         _controller.displayDate = _selectedDate;
//               //       }
//               //     });
//               //   }
//               // },
//               onTap: (calendar.CalendarTapDetails details) {
//                 if (details.targetElement ==
//                         calendar.CalendarElement.appointment &&
//                     details.appointments != null &&
//                     details.appointments!.isNotEmpty) {
//                   final appointment =
//                       details.appointments!.first as calendar.Appointment;

//                   // Check if appointment is recurring by matching subject
//                   final isRecurring = _appointments
//                       .where((a) =>
//                           a.subject == appointment.subject && a != appointment)
//                       .isNotEmpty;

//                   showDialog(
//                     context: context,
//                     builder: (context) => AlertDialog(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       title: Row(
//                         children: [
//                           const Icon(Icons.delete_forever_rounded,
//                               color: Colors.red),
//                           const SizedBox(width: 8),
//                           const Text(
//                             "Delete Session",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 20,
//                             ),
//                           ),
//                         ],
//                       ),
//                       content: Text(
//                         "Are you sure you want to delete '${appointment.subject}'?",
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                       actionsPadding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 8),
//                       actionsAlignment: MainAxisAlignment.spaceBetween,
//                       actions: [
//                         TextButton.icon(
//                           onPressed: () => Navigator.pop(context),
//                           icon: const Icon(Icons.close, color: Colors.grey),
//                           label: const Text(
//                             "Cancel",
//                             style: TextStyle(color: Colors.grey),
//                           ),
//                         ),
//                         if (isRecurring)
//                           TextButton.icon(
//                             onPressed: () async {
//                               setState(() {
//                                 _appointments.removeWhere(
//                                   (a) => a.subject == appointment.subject,
//                                 );
//                                 _dataSource = MeetingDataSource(_appointments);
//                               });

//                               await deleteAllOccurrencesFromFirestore(
//                                   studentId, appointment);
//                               Navigator.pop(context);
//                             },
//                             icon: const Icon(Icons.cached_rounded,
//                                 color: Colors.orange),
//                             label: const Text(
//                               "Delete All",
//                               style: TextStyle(color: Colors.orange),
//                             ),
//                           ),
//                         ElevatedButton.icon(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.red,
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           onPressed: () async {
//                             setState(() {
//                               _appointments.remove(appointment);
//                               _dataSource = MeetingDataSource(_appointments);
//                             });

//                             await deleteSingleSessionFromFirestore(
//                                 studentId, appointment);
//                             Navigator.pop(context);
//                           },
//                           icon: const Icon(Icons.delete),
//                           label: const Text("Delete"),
//                         ),
//                         ElevatedButton.icon(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor:
//                                 const Color.fromARGB(255, 244, 197, 54),
//                             foregroundColor: Colors.black,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           onPressed: () async {
//                             // showEditStudySessionDialog(context, appointment);
//                             setState(() {
//                               _appointments.remove(appointment);
//                               _dataSource = MeetingDataSource(_appointments);
//                             });

//                             await deleteSingleSessionFromFirestore(
//                                 studentId, appointment);
//                             Navigator.pop(context);
//                           },
//                           icon: const Icon(Icons.edit),
//                           label: const Text("Edit"),
//                         ),
//                       ],
//                     ),
//                   );
//                   // showDialog(
//                   //   context: context,
//                   //   builder: (context) => AlertDialog(
//                   //     shape: RoundedRectangleBorder(
//                   //         borderRadius: BorderRadius.circular(16)),
//                   //     title: const Text(
//                   //       "What do you want to do?",
//                   //       style: TextStyle(fontWeight: FontWeight.w600),
//                   //     ),
//                   //     content: Text(
//                   //       "You selected '${appointment.subject}'.",
//                   //       style: TextStyle(fontSize: 16),
//                   //     ),
//                   //     actions: [
//                   //       TextButton(
//                   //         onPressed: () => Navigator.pop(context),
//                   //         child: const Text("Cancel"),
//                   //       ),
//                   //       TextButton.icon(
//                   //         icon: const Icon(Icons.edit),
//                   //         label: const Text("Edit"),
//                   //         onPressed: () async {
//                   //           Navigator.pop(context); // Close the first dialog

//                   //           // ✅ Delay so dialog completely closes
//                   //           await Future.delayed(
//                   //               const Duration(milliseconds: 200));

//                   //           // ✅ Use parent context instead of dialog's context
//                   //           final parentContext =
//                   //               context; // This is valid as it's from builder

//                   //           final sessionId =
//                   //               appointment.notes; // this is entryId
//                   //           final snapshot = await FirebaseFirestore.instance
//                   //               .collection('timetables')
//                   //               .doc(studentId)
//                   //               .get();

//                   //           final allEntries =
//                   //               snapshot.data()?['entries'] ?? [];

//                   //           final matchedSession = allEntries.firstWhere(
//                   //             (entry) => entry['entryId'] == sessionId,
//                   //             orElse: () => null,
//                   //           );

//                   //           TimeOfDay _timestampToTimeOfDay(
//                   //               Timestamp timestamp) {
//                   //             final dateTime = timestamp.toDate();
//                   //             return TimeOfDay(
//                   //                 hour: dateTime.hour, minute: dateTime.minute);
//                   //           }

//                   //           if (matchedSession != null) {
//                   //             matchedSession['startTime'] =
//                   //                 _timestampToTimeOfDay(
//                   //                     matchedSession['startTime']);
//                   //             matchedSession['endTime'] = _timestampToTimeOfDay(
//                   //                 matchedSession['endTime']);

//                   //             // ✅ Check mounted and show dialog with parent context
//                   //             if (parentContext.mounted) {
//                   //               showEditStudySessionDialog(
//                   //                   parentContext, matchedSession);
//                   //             }
//                   //           }
//                   //         },
//                   //       ),
//                   //       TextButton.icon(
//                   //         icon: const Icon(Icons.delete_outline,
//                   //             color: Colors.red),
//                   //         label: const Text("Delete"),
//                   //         onPressed: () async {
//                   //           setState(() {
//                   //             _appointments.remove(appointment);
//                   //             _dataSource = MeetingDataSource(_appointments);
//                   //           });

//                   //           await deleteSingleSessionFromFirestore(
//                   //               studentId, appointment);
//                   //           Navigator.pop(context);
//                   //         },
//                   //       ),
//                   //       if (isRecurring)
//                   //         TextButton(
//                   //           onPressed: () async {
//                   //             setState(() {
//                   //               _appointments.removeWhere(
//                   //                   (a) => a.subject == appointment.subject);
//                   //               _dataSource = MeetingDataSource(_appointments);
//                   //             });

//                   //             await deleteAllOccurrencesFromFirestore(
//                   //                 studentId, appointment);
//                   //             Navigator.pop(context);
//                   //           },
//                   //           child: const Text("Delete All Occurrences"),
//                   //         ),
//                   //     ],
//                   //   ),
//                   // );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// List<calendar.Appointment> getAppointments() {
//   return [];
// }

// class MeetingDataSource extends calendar.CalendarDataSource {
//   MeetingDataSource(List<calendar.Appointment> source) {
//     appointments = source;
//   }
// }

// InputDecoration _inputDecoration(String label) => InputDecoration(
//       labelText: label,
//       labelStyle:
//           const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
//       filled: true,
//       fillColor: const Color.fromARGB(255, 223, 251, 255),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Colors.black54, width: 1.5),
//       ),
//     );

// BoxDecoration _checkboxContainerDecoration() => BoxDecoration(
//       color: const Color.fromARGB(255, 223, 251, 255),
//       borderRadius: BorderRadius.circular(12),
//       border: Border.all(color: Colors.grey.shade300),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.05),
//           blurRadius: 5,
//           offset: const Offset(0, 2),
//         )
//       ],
//     );

// Widget _timeButton(BuildContext context,
//     {required String label, required VoidCallback onTap}) {
//   return ElevatedButton(
//     style: ElevatedButton.styleFrom(
//       backgroundColor: const Color.fromARGB(255, 58, 183, 183),
//       foregroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//       elevation: 4,
//       textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//     ),
//     onPressed: onTap,
//     child: Text(label),
//   );
// }

// void _showTimeSpinner(BuildContext context, TimeOfDay initial,
//     Function(TimeOfDay) onTimeSelected) {
//   TimeOfDay tempPickedTime = initial;

//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const Text("Pick Time"),
//       content: SizedBox(
//         height: 150,
//         child: TimePickerSpinner(
//           is24HourMode: false,
//           normalTextStyle: const TextStyle(fontSize: 18, color: Colors.grey),
//           highlightedTextStyle:
//               const TextStyle(fontSize: 24, color: Colors.black),
//           spacing: 40,
//           itemHeight: 40,
//           isForce2Digits: true,
//           time: DateTime(0, 0, 0, initial.hour, initial.minute),
//           onTimeChange: (DateTime time) {
//             tempPickedTime = TimeOfDay(hour: time.hour, minute: time.minute);
//           },
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//             onTimeSelected(tempPickedTime);
//           },
//           child: const Text("OK"),
//         ),
//       ],
//     ),
//   );
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../models/timetable.dart';

class CalendarScreenApp extends StatefulWidget {
  const CalendarScreenApp({super.key});

  @override
  _CalendarScreenAppState createState() => _CalendarScreenAppState();
}

class _CalendarScreenAppState extends State<CalendarScreenApp> {
  final CalendarView _calendarView = CalendarView.day;
  List<Appointment> _appointments = [];
  late MeetingDataSource _dataSource;
  final CalendarController _controller = CalendarController();
  DateTime? _selectedDate;
  @override
  void initState() {
    super.initState();
    _controller.view = _calendarView;
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

  Future<void> showEditStudySessionDialog(
      String studentId, Appointment appointment, BuildContext context) async {
    final docRef =
        FirebaseFirestore.instance.collection('timetables').doc(studentId);

    final snapshot = await docRef.get(const GetOptions(source: Source.server));

    if (!snapshot.exists) return;

    final data = snapshot.data();
    if (data == null || !data.containsKey('entries')) return;

    final originalEntries = List<Map<String, dynamic>>.from(data['entries']);

    // Find the entry that matches the appointment id
    Map<String, dynamic>? existingSession;
    for (var entry in originalEntries) {
      if (entry['entryId'] == appointment.id) {
        existingSession = Map<String, dynamic>.from(entry);
        break;
      }
    }

    if (existingSession == null) {
      // No matching session found
      return;
    }
    String? selectedSubject = existingSession['subject'];
    String? sessionTitle = existingSession['title'];
    String? target = existingSession['target'];
    bool repeatWeekly = existingSession['repeatWeekly'] ?? false;
    // TimeOfDay? selectedStartTime = existingSession['startTime'];
    // TimeOfDay? selectedEndTime = existingSession['endTime'];

    TimeOfDay? selectedStartTime = TimeOfDay.fromDateTime(
        (existingSession['startTime'] as Timestamp).toDate());
    TimeOfDay? selectedEndTime = TimeOfDay.fromDateTime(
        (existingSession['endTime'] as Timestamp).toDate());

    final titleController = TextEditingController(text: sessionTitle);
    final targetController = TextEditingController(text: target);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Edit Study Session"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🧠 Subject Dropdown (Pre-filled)
                DropdownButtonFormField2<String>(
                  isExpanded: true,
                  value: selectedSubject,
                  decoration: _inputDecoration("Select Subject"),
                  items: ["Maths", "Physics", "Chemistry", "Biology", "Other"]
                      .map((subject) => DropdownMenuItem<String>(
                            value: subject,
                            child: Text(
                              subject,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedSubject = value);
                  },
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 200,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 217, 251, 255),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  iconStyleData: const IconStyleData(
                    icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                    iconSize: 24,
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                // 🧠 Session Title
                TextField(
                  controller: titleController,
                  decoration: _inputDecoration("Session Title"),
                  onChanged: (value) =>
                      setDialogState(() => sessionTitle = value),
                ),
                const SizedBox(height: 8),

                // 🧠 Target
                TextField(
                  controller: targetController,
                  decoration: _inputDecoration("Target"),
                  onChanged: (value) => setDialogState(() => target = value),
                ),
                const SizedBox(height: 8),

                // 🧠 Repeat Weekly Checkbox
                Container(
                  decoration: _checkboxContainerDecoration(),
                  child: CheckboxListTile(
                    title: const Text("Repeat every week",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16)),
                    value: repeatWeekly,
                    onChanged: (value) =>
                        setDialogState(() => repeatWeekly = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    activeColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                const SizedBox(height: 8),

                // 🧠 Start Time Picker
                _timeButton(
                  context,
                  label: selectedStartTime == null
                      ? "Select Start Time"
                      : "Start: ${selectedStartTime!.format(context)}",
                  onTap: () {
                    _showTimeSpinner(
                      context,
                      selectedStartTime ?? TimeOfDay.now(),
                      (picked) =>
                          setDialogState(() => selectedStartTime = picked),
                    );
                  },
                ),

                const SizedBox(height: 8),

                // 🧠 End Time Picker
                _timeButton(
                  context,
                  label: selectedEndTime == null
                      ? "Select End Time"
                      : "End: ${selectedEndTime!.format(context)}",
                  onTap: () {
                    _showTimeSpinner(
                      context,
                      selectedEndTime ?? TimeOfDay.now(),
                      (picked) =>
                          setDialogState(() => selectedEndTime = picked),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (selectedSubject != null &&
                    sessionTitle != null &&
                    target != null &&
                    selectedStartTime != null &&
                    selectedEndTime != null) {
                  await _editAppointment(
                    existingSession?['entryId'],
                    sessionTitle!,
                    selectedSubject!,
                    target!,
                    selectedStartTime!,
                    selectedEndTime!,
                    repeatWeekly,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showDeleteStudySessionDialog(
      CalendarTapDetails details, BuildContext context) async {
    if (details.targetElement == CalendarElement.appointment &&
        details.appointments != null &&
        details.appointments!.isNotEmpty) {
      final appointment = details.appointments!.first as Appointment;

      // Check if appointment is recurring by matching subject
      final isRecurring = _appointments
          .where((a) => a.subject == appointment.subject && a != appointment)
          .isNotEmpty;

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.delete_forever_rounded, color: Colors.red),
              const SizedBox(width: 8),
              const Text(
                "Delete Session",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Text(
            "Are you sure you want to delete '${appointment.subject}'?",
            style: const TextStyle(fontSize: 16),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.grey),
              label: const Text(
                "Cancel",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            if (isRecurring)
              TextButton.icon(
                onPressed: () async {
                  setState(() {
                    _appointments.removeWhere(
                      (a) => a.subject == appointment.subject,
                    );
                    _dataSource = MeetingDataSource(_appointments);
                  });

                  await deleteAllOccurrencesFromFirestore(
                      studentId, appointment);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.cached_rounded, color: Colors.orange),
                label: const Text(
                  "Delete All",
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                setState(() {
                  _appointments.remove(appointment);
                  _dataSource = MeetingDataSource(_appointments);
                });

                await deleteSingleSessionFromFirestore(studentId, appointment);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete),
              label: const Text("Delete"),
            ),
          ],
        ),
      );
    }
  }

  void _showAddSessionDialog() {
    String? selectedSubject;
    //String? selectedSessionType;
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
          title: const Text("Add Study Session"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // DropdownButtonFormField<String>(
                //   value: selectedSubject,
                //   items: ["Maths", "Physics", "Chemistry", "Biology", "Other"]
                //       .map((subject) {
                //     return DropdownMenuItem(
                //         value: subject, child: Text(subject));
                //   }).toList(),
                //   onChanged: (value) {
                //     setDialogState(() {
                //       selectedSubject = value;
                //     });
                //   },
                //   decoration:
                //       const InputDecoration(labelText: "Select Subject"),
                // ),
                // DropdownButtonFormField<String>(
                //   value: selectedSessionType,
                //   items: ["Study", "Lecture", "Revision", "Practice", "Other"]
                //       .map((type) {
                //     return DropdownMenuItem(value: type, child: Text(type));
                //   }).toList(),
                //   onChanged: (value) {
                //     setDialogState(() {
                //       selectedSessionType = value;
                //     });
                //   },
                //   decoration: const InputDecoration(labelText: "Session Type"),
                // ),
                DropdownButtonFormField2<String>(
                  isExpanded: true,
                  value: selectedSubject,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    labelText: "Select Subject",
                    labelStyle: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 223, 251, 255),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.black54, width: 1.5),
                    ),
                  ),
                  items: ["Maths", "Physics", "Chemistry", "Biology", "Other"]
                      .map((subject) => DropdownMenuItem<String>(
                            value: subject,
                            child: Text(
                              subject,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedSubject = value;
                    });
                  },
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 200,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 217, 251, 255),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  iconStyleData: const IconStyleData(
                    icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                    iconSize: 24,
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

// Session Title TextField
                TextField(
                  decoration: InputDecoration(
                    labelText: "Session Title",
                    labelStyle: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 223, 251, 255),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.black54, width: 1.5),
                    ),
                  ),
                  onChanged: (value) {
                    setDialogState(() {
                      sessionTitle = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                // Target TextField
                TextField(
                  decoration: InputDecoration(
                    labelText: "Target",
                    labelStyle: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 223, 251, 255),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.black54, width: 1.5),
                    ),
                  ),
                  onChanged: (value) {
                    setDialogState(() {
                      target = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                // Styled Checkbox
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 223, 251, 255),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: CheckboxListTile(
                    title: const Text(
                      "Repeat every week",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    value: repeatWeekly,
                    onChanged: (value) {
                      setDialogState(() {
                        repeatWeekly = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    activeColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                // TextField(
                //   decoration: const InputDecoration(labelText: "Session Title"),
                //   onChanged: (value) {
                //     setDialogState(() {
                //       sessionTitle = value;
                //     });
                //   },
                // ),
                // TextField(
                //   decoration: const InputDecoration(labelText: "Target"),
                //   onChanged: (value) {
                //     setDialogState(() {
                //       target = value;
                //     });
                //   },
                // ),
                // CheckboxListTile(
                //   title: const Text("Repeat every week"),
                //   value: repeatWeekly,
                //   onChanged: (value) {
                //     setDialogState(() {
                //       repeatWeekly = value ?? false;
                //     });
                //   },
                // ),
                // ElevatedButton(
                //   onPressed: () async {
                //     TimeOfDay? pickedTime = await showTimePicker(
                //       context: context,
                //       initialTime: TimeOfDay.now(),
                //     );
                //     if (pickedTime != null) {
                //       setDialogState(() {
                //         selectedStartTime = pickedTime;
                //       });
                //     }
                //   },
                //   child: Text(selectedStartTime == null
                //       ? "Select Start Time"
                //       : "Start: ${selectedStartTime!.format(context)}"),
                // ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 86, 206, 206), // custom background
                    foregroundColor: Colors.white, // text & icon color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16), // rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    elevation: 4, // shadow
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        TimeOfDay tempPickedTime =
                            selectedStartTime ?? TimeOfDay.now();

                        return AlertDialog(
                          title: const Text("Pick Time"),
                          content: SizedBox(
                            height: 150,
                            child: TimePickerSpinner(
                              is24HourMode: false,
                              normalTextStyle: const TextStyle(
                                  fontSize: 18, color: Colors.grey),
                              highlightedTextStyle: const TextStyle(
                                  fontSize: 24, color: Colors.black),
                              spacing: 40,
                              itemHeight: 40,
                              isForce2Digits: true,
                              time: DateTime(
                                0,
                                0,
                                0,
                                tempPickedTime.hour,
                                tempPickedTime.minute,
                              ),
                              onTimeChange: (DateTime time) {
                                tempPickedTime = TimeOfDay(
                                    hour: time.hour, minute: time.minute);
                              },
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                setDialogState(() {
                                  selectedStartTime = tempPickedTime;
                                });
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(selectedStartTime == null
                      ? "Select Start Time"
                      : "Start: ${selectedStartTime!.format(context)}"),
                ),
                // ElevatedButton(
                //   onPressed: () async {
                //     TimeOfDay? pickedTime = await showTimePicker(
                //       context: context,
                //       initialTime: TimeOfDay.now(),
                //     );
                //     if (pickedTime != null) {
                //       setDialogState(() {
                //         selectedEndTime = pickedTime;
                //       });
                //     }
                //   },
                //   child: Text(selectedEndTime == null
                //       ? "Select End Time"
                //       : "End: ${selectedEndTime!.format(context)}"),
                // ),
                SizedBox(
                  height: 8,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 58, 183, 183), // custom background
                    foregroundColor: Colors.white, // text & icon color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16), // rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    elevation: 4, // shadow
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        TimeOfDay tempPickedTime =
                            selectedEndTime ?? TimeOfDay.now();

                        return AlertDialog(
                          title: const Text("Pick End Time"),
                          content: SizedBox(
                            height: 150,
                            child: TimePickerSpinner(
                              is24HourMode: false,
                              normalTextStyle: const TextStyle(
                                  fontSize: 18, color: Colors.grey),
                              highlightedTextStyle: const TextStyle(
                                  fontSize: 24, color: Colors.black),
                              spacing: 40,
                              itemHeight: 40,
                              isForce2Digits: true,
                              time: DateTime(
                                0,
                                0,
                                0,
                                tempPickedTime.hour,
                                tempPickedTime.minute,
                              ),
                              onTimeChange: (DateTime time) {
                                tempPickedTime = TimeOfDay(
                                    hour: time.hour, minute: time.minute);
                              },
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                setDialogState(() {
                                  selectedEndTime = tempPickedTime;
                                });
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(selectedEndTime == null
                      ? "Select End Time"
                      : "End: ${selectedEndTime!.format(context)}"),
                ),
              ],
            ),
          ),
          //   actions: [
          //     TextButton(
          //       onPressed: () => Navigator.pop(context),
          //       child: const Text("Cancel"),
          //     ),
          //     ElevatedButton(
          //       onPressed: () {
          //         if (selectedSubject != null &&
          //             selectedStartTime != null &&
          //             selectedEndTime != null &&
          //             sessionTitle != null &&
          //             sessionTitle!.trim().isNotEmpty &&
          //             target != null) {
          //           _addAppointment(
          //             sessionTitle!,
          //             selectedSubject!,
          //             //selectedSessionType!,
          //             target!,
          //             selectedStartTime!,
          //             selectedEndTime!,
          //             repeatWeekly,
          //           );
          //           Navigator.pop(context);
          //         }
          //       },
          //       child: const Text("Add"),
          //     ),
          //   ],
          actions: [
            // Cancel Button (Subtle and clean)
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.black54),
              label: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),

            // Add Button (High Contrast CTA)
            ElevatedButton.icon(
              onPressed: () {
                if (selectedSubject != null &&
                    selectedStartTime != null &&
                    selectedEndTime != null &&
                    sessionTitle != null &&
                    sessionTitle!.trim().isNotEmpty &&
                    target != null) {
                  // Time comparison logic
                  final startMinutes =
                      selectedStartTime!.hour * 60 + selectedStartTime!.minute;
                  final endMinutes =
                      selectedEndTime!.hour * 60 + selectedEndTime!.minute;

                  if (startMinutes >= endMinutes) {
                    // Show error dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Invalid Time"),
                        content:
                            const Text("Start time must be before End time."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );
                    return;
                  }

                  // If time is valid, proceed
                  _addAppointment(
                    sessionTitle!,
                    selectedSubject!,
                    target!,
                    selectedStartTime!,
                    selectedEndTime!,
                    repeatWeekly,
                  );
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text(
                "Add",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B7C2), // Teal shade
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
              ),
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
      id: entry.entryId,
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
  // Future<void> _addAppointment(
  //   String title,
  //   String subject,
  //   String sessionType,
  //   String target,
  //   TimeOfDay startTime,
  //   TimeOfDay endTime,
  //   bool repeatWeekly,
  // ) async {
  //   TimetableEntry newEntry = TimetableEntry(
  //     entryId: DateTime.now().millisecondsSinceEpoch.toString(),
  //     title: title,
  //     subject: subject,
  //     sessionType: sessionType,
  //     target: target,
  //     startTime: DateTime(
  //       DateTime.now().year,
  //       DateTime.now().month,
  //       DateTime.now().day,
  //       startTime.hour,
  //       startTime.minute,
  //     ),
  //     endTime: DateTime(
  //       DateTime.now().year,
  //       DateTime.now().month,
  //       DateTime.now().day,
  //       endTime.hour,
  //       endTime.minute,
  //     ),
  //     repeatWeekly: repeatWeekly,
  //   );

  //   await FirebaseFirestore.instance
  //       .collection('timetables')
  //       .doc(studentId)
  //       .set({
  //     'studentId': studentId,
  //     'entries': FieldValue.arrayUnion([newEntry.toMap()])
  //   }, SetOptions(merge: true));

  //   await _fetchAppointmentsFromFirestore();
  // }
  Future<void> _addAppointment(
    String title,
    String subject,
    //String sessionType,
    String target,
    TimeOfDay startTime,
    TimeOfDay endTime,
    bool repeatWeekly,
  ) async {
    // 🔒 Always get the latest data from server
    final snapshot = await FirebaseFirestore.instance
        .collection('timetables')
        .doc(studentId)
        .get(const GetOptions(source: Source.server));

    List<dynamic> currentEntries = [];
    if (snapshot.exists && snapshot.data()!.containsKey('entries')) {
      currentEntries = snapshot.data()!['entries'];
    }

    TimetableEntry newEntry = TimetableEntry(
      entryId: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      subject: subject,
      sessionType: "",
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
      done: false,
    );

    // ✅ Add to current list
    currentEntries.add(newEntry.toMap());

    // 🔥 Full overwrite — not merge
    await FirebaseFirestore.instance
        .collection('timetables')
        .doc(studentId)
        .set({
      'studentId': studentId,
      'entries': currentEntries,
    }, SetOptions(merge: false));

    // Refresh UI
    await _fetchAppointmentsFromFirestore();
  }

  Future<void> _editAppointment(
    String entryId,
    String title,
    String subject,
    String target,
    TimeOfDay startTime,
    TimeOfDay endTime,
    bool repeatWeekly,
  ) async {
    // 🔒 Get latest data
    final snapshot = await FirebaseFirestore.instance
        .collection('timetables')
        .doc(studentId)
        .get(const GetOptions(source: Source.server));

    List<dynamic> currentEntries = [];
    if (snapshot.exists && snapshot.data()!.containsKey('entries')) {
      currentEntries = snapshot.data()!['entries'];
    }

    // 🧠 Replace the existing entry
    currentEntries = currentEntries.map((entry) {
      if (entry['entryId'] == entryId) {
        return TimetableEntry(
          entryId: entryId,
          title: title,
          subject: subject,
          sessionType: "", // Optional
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
          done: false,
        ).toMap();
      }
      return entry;
    }).toList();

    // 🔥 Save updated list
    await FirebaseFirestore.instance
        .collection('timetables')
        .doc(studentId)
        .set({
      'studentId': studentId,
      'entries': currentEntries,
    }, SetOptions(merge: false));

    // Refresh UI
    await _fetchAppointmentsFromFirestore();
  }

  Future<void> deleteSingleSessionFromFirestore(
      String studentId, Appointment appointment) async {
    final docRef =
        FirebaseFirestore.instance.collection('timetables').doc(studentId);

    final snapshot = await docRef.get(const GetOptions(source: Source.server));

    if (!snapshot.exists) return;

    final data = snapshot.data();
    if (data == null || !data.containsKey('entries')) return;

    final originalEntries = List<Map<String, dynamic>>.from(data['entries']);

    final updatedEntries = originalEntries.where((entry) {
      //print(
//"Firestore entryId: ${entry['entryId']} vs Appointment ID: ${appointment.id}");

      final isMatch = entry['entryId'] == appointment.id;
      if (isMatch) {
        //print("✅ Deleting entryId: ${entry['entryId']}");
      }
      return !isMatch;
    }).toList();

    await docRef.set({
      'studentId': studentId,
      'entries': updatedEntries,
    }, SetOptions(merge: false)); // ✅ Overwrites the entire doc

    // print("Updated entries count: ${updatedEntries.length}");
  }

  Future<void> deleteAllOccurrencesFromFirestore(
      String studentId, Appointment appointment) async {
    final docRef =
        FirebaseFirestore.instance.collection('timetables').doc(studentId);

    final snapshot = await docRef.get(const GetOptions(source: Source.server));

    if (!snapshot.exists) return;

    final data = snapshot.data();
    if (data == null || !data.containsKey('entries')) return;

    final originalEntries = List<Map<String, dynamic>>.from(data['entries']);

    final updatedEntries = originalEntries.where((entry) {
      // final isMatch = entry['subject'] == appointment.subject &&
      //     entry['repeatWeekly'] == true;
      final isMatch = entry["entryId"] == appointment.id;
      if (isMatch) {
        //print("Deleting recurring entry for subject: ${entry['subject']}");
      }
      return !isMatch;
    }).toList();

    await docRef.set({
      'studentId': studentId,
      'entries': updatedEntries,
    }, SetOptions(merge: false)); // ✅ Full replace

    //print("Recurring entries deleted, remaining: ${updatedEntries.length}");
  }

  @override
  Widget build(BuildContext context) {
    //print("Rebuilding UI. Total appointments: ${_appointments.length}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 254, 255, 255),
        title: const Text(
          'Create Timetable',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        // title: DropdownButtonHideUnderline(
        //   child: DropdownButton<CalendarView>(
        //     value: _controller.view,
        //     onChanged: (CalendarView? newView) {
        //       if (newView != null) {
        //         setState(() {
        //           _controller.view = newView;
        //           if (newView == CalendarView.day && _selectedDate != null) {
        //             _controller.displayDate = _selectedDate;
        //           }
        //         });
        //       }
        //     },
        //     items: const [
        //       DropdownMenuItem(value: CalendarView.day, child: Text('Day')),
        //       DropdownMenuItem(value: CalendarView.week, child: Text('Week')),
        //       DropdownMenuItem(value: CalendarView.month, child: Text('Month')),
        //     ],
        //   ),
        //   // DropdownButton<CalendarView>(
        //   //   value: _calendarView,
        //   //   icon: Icon(Icons.arrow_drop_down, color: Colors.white),
        //   //   dropdownColor: Colors.white,
        //   //   onChanged: (CalendarView? newView) {
        //   //     if (newView != null) {
        //   //       setState(() {
        //   //         _calendarView = newView;
        //   //         if (newView == CalendarView.day && _selectedDate != null) {
        //   //           _controller.displayDate = _selectedDate;
        //   //         }
        //   //       });
        //   //     }
        //   //   },
        //   //   items: const [
        //   //     DropdownMenuItem(
        //   //       value: CalendarView.day,
        //   //       child: Text('Day'),
        //   //     ),
        //   //     DropdownMenuItem(
        //   //       value: CalendarView.week,
        //   //       child: Text('Week'),
        //   //     ),
        //   //     DropdownMenuItem(
        //   //       value: CalendarView.month,
        //   //       child: Text('Month'),
        //   //     ),
        //   //   ],
        //   // ),
        // ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.add),
        //     onPressed: _showAddSessionDialog,
        //   ),
        //   // IconButton(
        //   //   icon: const Icon(Icons.notifications),
        //   //   color: const Color.fromARGB(255, 31, 115, 121),
        //   //   onPressed: () {},
        //   // ),
        //   // IconButton(
        //   //   icon: const Icon(Icons.person),
        //   //   color: const Color.fromARGB(255, 0, 0, 0),
        //   //   onPressed: () {},
        //   // ),
        // ],
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
          Column(
        children: [
          SizedBox(
            height: 10,
          ),
          // Row(
          //   mainAxisAlignment: _controller.view == CalendarView.day
          //       ? MainAxisAlignment.spaceAround
          //       : MainAxisAlignment.center,
          //   children: [
          //     Container(
          //       width: 150,
          //       padding: const EdgeInsets.symmetric(horizontal: 16),
          //       decoration: BoxDecoration(
          //         color: const Color.fromARGB(255, 172, 235, 243),
          //         borderRadius: BorderRadius.circular(12),
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.grey.withOpacity(0.2),
          //             spreadRadius: 2,
          //             blurRadius: 5,
          //             offset: const Offset(0, 3), // shadow direction
          //           ),
          //         ],
          //         border: Border.all(color: Colors.grey.shade300),
          //       ),
          //       child: DropdownButtonHideUnderline(
          //         child: DropdownButton<CalendarView>(
          //           value: _controller.view,
          //           onChanged: (CalendarView? newView) {
          //             if (newView != null) {
          //               setState(() {
          //                 _controller.view = newView;
          //                 if (newView == CalendarView.day &&
          //                     _selectedDate != null) {
          //                   _controller.displayDate = _selectedDate;
          //                 }
          //               });
          //             }
          //           },
          //           items: const [
          //             DropdownMenuItem(
          //                 value: CalendarView.day, child: Text('Day')),
          //             DropdownMenuItem(
          //                 value: CalendarView.week, child: Text('Week')),
          //             DropdownMenuItem(
          //                 value: CalendarView.month, child: Text('Month')),
          //           ],
          //         ),
          //       ),
          //     ),
          //     // IconButton(
          //     //   icon: const Icon(Icons.add),
          //     //   onPressed: _showAddSessionDialog,
          //     // ),

          //     _controller.view == CalendarView.day
          //         ? GestureDetector(
          //             onTap: () {
          //               _showAddSessionDialog();
          //             },
          //             child: Container(
          //               width: 100,
          //               child: Text(
          //                 "Add entry +",
          //                 style: TextStyle(
          //                   fontSize: 16,
          //                   color: Colors.black,
          //                   fontWeight: FontWeight.w500,
          //                 ),
          //               ),
          //             ),
          //           )
          //         : SizedBox.shrink(), // Empty widget if not day view
          //   ],
          // ),

          Row(
            mainAxisAlignment: _controller.view == CalendarView.day
                ? MainAxisAlignment.spaceAround
                : MainAxisAlignment.center,
            children: [
              // ⬇️ Modern Dropdown using dropdown_button2
              Container(
                width: 150,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<CalendarView>(
                    isExpanded: true,
                    value: _controller.view,
                    onChanged: (CalendarView? newView) {
                      if (newView != null) {
                        setState(() {
                          _controller.view = newView;
                          if (newView == CalendarView.day &&
                              _selectedDate != null) {
                            _controller.displayDate = _selectedDate;
                          }
                        });
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: CalendarView.day,
                        child: Text('Day'),
                      ),
                      DropdownMenuItem(
                        value: CalendarView.week,
                        child: Text('Week'),
                      ),
                      DropdownMenuItem(
                        value: CalendarView.month,
                        child: Text('Month'),
                      ),
                    ],
                    buttonStyleData: ButtonStyleData(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 172, 235, 243),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 200,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 208, 243, 248),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    iconStyleData: const IconStyleData(
                      icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                      iconSize: 24,
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // ⬇️ Styled Add Entry Button Matching Dropdown
              _controller.view == CalendarView.day
                  ? GestureDetector(
                      onTap: _showAddSessionDialog,
                      child: Container(
                        width: 150,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 172, 235, 243),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "Add entry +",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          // SizedBox(
          //   height: 8,
          // ),
          Expanded(
            child: SfCalendar(
              //backgroundColor: Color.fromARGB(1, 229, 245, 253)
              //todayHighlightColor: Color.fromARGB(1, 13, 30, 38),
              //cellBorderColor: Color.fromARGB(1, 3, 26, 38),
              controller: _controller,
              key: ValueKey(_controller.view),
              firstDayOfWeek: 1,
              dataSource: _dataSource,
              monthViewSettings: const MonthViewSettings(showAgenda: true),
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
                  final appointment =
                      details.appointments!.first as Appointment;

                  // Check if appointment is recurring by matching subject
                  final isRecurring = _appointments
                      .where((a) =>
                          a.subject == appointment.subject && a != appointment)
                      .isNotEmpty;

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Row(
                        children: [
                          const Icon(Icons.delete_forever_rounded,
                              color: Colors.red),
                          const SizedBox(width: 8),
                          const Text(
                            "Alter Session",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      content: Text(
                        "Do you wish to delete or edit '${appointment.subject}'?",
                        style: const TextStyle(fontSize: 16),
                      ),
                      actionsPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      actionsAlignment: MainAxisAlignment.spaceBetween,
                      actions: [
                        TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.grey),
                          label: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        // if (isRecurring)
                        //   TextButton.icon(
                        //     onPressed: () async {
                        //       setState(() {
                        //         _appointments.removeWhere(
                        //           (a) => a.subject == appointment.subject,
                        //         );
                        //         _dataSource = MeetingDataSource(_appointments);
                        //       });

                        //       await deleteAllOccurrencesFromFirestore(
                        //           studentId, appointment);
                        //       Navigator.pop(context);
                        //     },
                        //     icon: const Icon(Icons.cached_rounded,
                        //         color: Colors.orange),
                        //     label: const Text(
                        //       "Delete All",
                        //       style: TextStyle(color: Colors.orange),
                        //     ),
                        //   ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            // setState(() {
                            //   _appointments.remove(appointment);
                            //   _dataSource = MeetingDataSource(_appointments);
                            // });

                            // await deleteSingleSessionFromFirestore(
                            //     studentId, appointment);
                            // Navigator.pop(context);
                            final parentContext =
                                Navigator.of(context).overlay!.context;
                            Navigator.pop(context);
                            await Future.delayed(Duration(milliseconds: 50));
                            await showDeleteStudySessionDialog(
                                details, parentContext);
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text("Delete"),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 246, 184, 39),
                            foregroundColor: const Color.fromARGB(255, 3, 3, 3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final parentContext =
                                Navigator.of(context).overlay!.context;
                            Navigator.pop(context);
                            await Future.delayed(Duration(milliseconds: 50));
                            await showEditStudySessionDialog(
                                studentId, appointment, parentContext);

                            // await deleteSingleSessionFromFirestore(
                            //     studentId, appointment);
                            // Navigator.pop(context);
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text("Edit"),
                        ),
                      ],
                    ),
                  );
                  // showDialog(
                  //   context: context,
                  //   builder: (context) => AlertDialog(
                  //     shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(16)),
                  //     title: const Text(
                  //       "What do you want to do?",
                  //       style: TextStyle(fontWeight: FontWeight.w600),
                  //     ),
                  //     content: Text(
                  //       "You selected '${appointment.subject}'.",
                  //       style: TextStyle(fontSize: 16),
                  //     ),
                  //     actions: [
                  //       TextButton(
                  //         onPressed: () => Navigator.pop(context),
                  //         child: const Text("Cancel"),
                  //       ),
                  //       TextButton.icon(
                  //         icon: const Icon(Icons.edit),
                  //         label: const Text("Edit"),
                  //         onPressed: () async {
                  //           Navigator.pop(context); // Close the first dialog

                  //           // ✅ Delay so dialog completely closes
                  //           await Future.delayed(
                  //               const Duration(milliseconds: 200));

                  //           // ✅ Use parent context instead of dialog's context
                  //           final parentContext =
                  //               context; // This is valid as it's from builder

                  //           final sessionId =
                  //               appointment.notes; // this is entryId
                  //           final snapshot = await FirebaseFirestore.instance
                  //               .collection('timetables')
                  //               .doc(studentId)
                  //               .get();

                  //           final allEntries =
                  //               snapshot.data()?['entries'] ?? [];

                  //           final matchedSession = allEntries.firstWhere(
                  //             (entry) => entry['entryId'] == sessionId,
                  //             orElse: () => null,
                  //           );

                  //           TimeOfDay _timestampToTimeOfDay(
                  //               Timestamp timestamp) {
                  //             final dateTime = timestamp.toDate();
                  //             return TimeOfDay(
                  //                 hour: dateTime.hour, minute: dateTime.minute);
                  //           }

                  //           if (matchedSession != null) {
                  //             matchedSession['startTime'] =
                  //                 _timestampToTimeOfDay(
                  //                     matchedSession['startTime']);
                  //             matchedSession['endTime'] = _timestampToTimeOfDay(
                  //                 matchedSession['endTime']);

                  //             // ✅ Check mounted and show dialog with parent context
                  //             if (parentContext.mounted) {
                  //               showEditStudySessionDialog(
                  //                   parentContext, matchedSession);
                  //             }
                  //           }
                  //         },
                  //       ),
                  //       TextButton.icon(
                  //         icon: const Icon(Icons.delete_outline,
                  //             color: Colors.red),
                  //         label: const Text("Delete"),
                  //         onPressed: () async {
                  //           setState(() {
                  //             _appointments.remove(appointment);
                  //             _dataSource = MeetingDataSource(_appointments);
                  //           });

                  //           await deleteSingleSessionFromFirestore(
                  //               studentId, appointment);
                  //           Navigator.pop(context);
                  //         },
                  //       ),
                  //       if (isRecurring)
                  //         TextButton(
                  //           onPressed: () async {
                  //             setState(() {
                  //               _appointments.removeWhere(
                  //                   (a) => a.subject == appointment.subject);
                  //               _dataSource = MeetingDataSource(_appointments);
                  //             });

                  //             await deleteAllOccurrencesFromFirestore(
                  //                 studentId, appointment);
                  //             Navigator.pop(context);
                  //           },
                  //           child: const Text("Delete All Occurrences"),
                  //         ),
                  //     ],
                  //   ),
                  // );
                }
              },
            ),
          ),
        ],
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

InputDecoration _inputDecoration(String label) => InputDecoration(
      labelText: label,
      labelStyle:
          const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
      filled: true,
      fillColor: const Color.fromARGB(255, 223, 251, 255),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black54, width: 1.5),
      ),
    );

BoxDecoration _checkboxContainerDecoration() => BoxDecoration(
      color: const Color.fromARGB(255, 223, 251, 255),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 5,
          offset: const Offset(0, 2),
        )
      ],
    );

Widget _timeButton(BuildContext context,
    {required String label, required VoidCallback onTap}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 58, 183, 183),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      elevation: 4,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    onPressed: onTap,
    child: Text(label),
  );
}

void _showTimeSpinner(BuildContext context, TimeOfDay initial,
    Function(TimeOfDay) onTimeSelected) {
  TimeOfDay tempPickedTime = initial;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Pick Time"),
      content: SizedBox(
        height: 150,
        child: TimePickerSpinner(
          is24HourMode: false,
          normalTextStyle: const TextStyle(fontSize: 18, color: Colors.grey),
          highlightedTextStyle:
              const TextStyle(fontSize: 24, color: Colors.black),
          spacing: 40,
          itemHeight: 40,
          isForce2Digits: true,
          time: DateTime(0, 0, 0, initial.hour, initial.minute),
          onTimeChange: (DateTime time) {
            tempPickedTime = TimeOfDay(hour: time.hour, minute: time.minute);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onTimeSelected(tempPickedTime);
          },
          child: const Text("OK"),
        ),
      ],
    ),
  );
}
