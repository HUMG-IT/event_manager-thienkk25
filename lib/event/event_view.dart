import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'event_data_source.dart';
import 'event_detail_view.dart';
import 'event_model.dart';
import 'event_service.dart';

class EventView extends StatefulWidget {
  const EventView({super.key});

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  final eventSerice = EventService();
  List<EventModel> items = [];
  final calendarController = CalendarController();
  @override
  void initState() {
    super.initState();
    calendarController.view = CalendarView.day;
    loadEvents();
  }

  Future<void> loadEvents() async {
    final events = await eventSerice.getAllEvents();
    setState(() {
      items = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    final al = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(al!.appTitle),
        actions: [
          PopupMenuButton<CalendarView>(
            onSelected: (value) {
              setState(() {
                calendarController.view = value;
              });
            },
            itemBuilder: (context) => CalendarView.values.map((view) {
              return PopupMenuItem<CalendarView>(
                  value: view,
                  child: ListTile(
                    leading: getCalendarViewIcon(view),
                    title: Text(getVietnameseCalendarViewName(view)),
                  ));
            }).toList(),
            icon: getCalendarViewIcon(calendarController.view!),
          ),
          IconButton(
              onPressed: () {
                calendarController.displayDate = DateTime.now();
              },
              icon: const Icon(Icons.today_outlined)),
          IconButton(
              onPressed: loadEvents, icon: const Icon(Icons.refresh_outlined))
        ],
      ),
      body: SfCalendar(
        controller: calendarController,
        dataSource: EventDataSource(items),
        monthViewSettings: const MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
        onLongPress: (details) {
          if (details.targetElement == CalendarElement.calendarCell) {
            final newEvent = EventModel(
              startTime: details.date!,
              endTime: details.date!.add(const Duration(hours: 1)),
              subject: al.newEvent,
            );

            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                return EventDetailView(event: newEvent);
              }),
            ).then((value) async {
              if (value == true) {
                await loadEvents();
              }
            });
          }
        },
        onTap: (details) {
          if (details.targetElement == CalendarElement.appointment) {
            final EventModel event = details.appointments!.first;

            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return EventDetailView(event: event);
              },
            )).then((value) async {
              if (value == true) {
                await loadEvents();
              }
            });
          }
        },
      ),
    );
  }

  Icon getCalendarViewIcon(CalendarView view) {
    switch (view) {
      case CalendarView.day:
        return const Icon(Icons.calendar_view_day_outlined);
      case CalendarView.week:
        return const Icon(Icons.calendar_view_week_outlined);
      case CalendarView.workWeek:
        return const Icon(Icons.work_history_outlined);
      case CalendarView.month:
        return const Icon(Icons.calendar_view_month_outlined);
      case CalendarView.schedule:
        return const Icon(Icons.schedule_outlined);
      default:
        return const Icon(Icons.calendar_today_outlined);
    }
  }

  String getVietnameseCalendarViewName(CalendarView view) {
    final al = AppLocalizations.of(context);
    switch (view) {
      case CalendarView.day:
        return al!.day;
      case CalendarView.week:
        return al!.week;
      case CalendarView.workWeek:
        return al!.workWeek;
      case CalendarView.month:
        return al!.month;
      case CalendarView.schedule:
        return al!.schedule;
      case CalendarView.timelineDay:
        return al!.timelineDay;
      case CalendarView.timelineWeek:
        return al!.timelineWeek;
      case CalendarView.timelineWorkWeek:
        return al!.timelineWorkWeek;
      case CalendarView.timelineMonth:
        return al!.timelineMonth;
      default:
        return al!.unknown;
    }
  }
}
