import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'event_model.dart';
import 'event_service.dart';

class EventDetailView extends StatefulWidget {
  final EventModel event;
  const EventDetailView({super.key, required this.event});

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> {
  final subjectController = TextEditingController();
  final notesController = TextEditingController();
  final eventService = EventService();
  @override
  void initState() {
    super.initState();
    subjectController.text = widget.event.subject;
    notesController.text = widget.event.notes ?? '';
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final pickDate = await showDatePicker(
        context: context,
        initialDate: isStart ? widget.event.startTime : widget.event.endTime,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101));
    if (pickDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
            isStart ? widget.event.startTime : widget.event.endTime),
      );
      if (pickedTime != null) {
        setState(() {
          final newDateTime = DateTime(pickDate.year, pickDate.month,
              pickDate.day, pickDate.hour, pickDate.minute);
          if (isStart) {
            widget.event.startTime = newDateTime;
            if (widget.event.startTime.isAfter(widget.event.endTime)) {
              widget.event.endTime =
                  widget.event.startTime.add(const Duration(hours: 1));
            }
          } else {
            widget.event.endTime = newDateTime;
          }
        });
      }
    }
  }

  Future<void> _saveEvent() async {
    widget.event.subject = subjectController.text;
    widget.event.notes = notesController.text;
    await eventService.saveEvent(widget.event);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _deleteEvent() async {
    await eventService.deleteEvent(widget.event);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final al = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.id == null ? al!.addEvent : al!.evenDetail),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: subjectController,
                decoration: InputDecoration(labelText: al.eventName),
              ),
              const SizedBox(
                height: 16,
              ),
              ListTile(
                title: Text(al.allDayEvent),
                trailing: Switch(
                    value: widget.event.isAllDay,
                    onChanged: (value) {
                      setState(() {
                        widget.event.isAllDay = value;
                      });
                    }),
              ),
              if (!widget.event.isAllDay) ...[
                const SizedBox(
                  height: 16,
                ),
                ListTile(
                  title: Text(
                      '${al.start}: ${widget.event.formatedStartTimeString}'),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () => _pickDateTime(isStart: true),
                ),
                const SizedBox(
                  height: 16,
                ),
                ListTile(
                  title:
                      Text('${al.end}: ${widget.event.formatedEndTimeString}'),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () => _pickDateTime(isStart: false),
                ),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(labelText: al.eventNotes),
                  maxLines: 3,
                ),
                const SizedBox(
                  height: 24,
                ),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (widget.event.id != null)
                    FilledButton.tonalIcon(
                        onPressed: _deleteEvent, label: Text(al.deleteEvent)),
                  FilledButton.icon(
                      onPressed: _saveEvent, label: Text(al.saveEvent))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
