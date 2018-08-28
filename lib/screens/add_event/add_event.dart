import 'package:flutter/material.dart';
import 'package:myagenda/models/course.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/settings/list_tile_color.dart';
import 'package:uuid/uuid.dart';

class AddEventScreen extends StatefulWidget {
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final DateTime _firstDate = DateTime.now();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  Locale _locale;
  bool _isCustomColor = false;

  DateTime _eventDateStart;
  DateTime _eventDateEnd;
  Color _eventColor;

  @override
  void initState() {
    super.initState();
    _eventDateStart = DateTime.now();
    _eventDateEnd = DateTime.now().add(Duration(hours: 1));
    _eventColor = Colors.red[500];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _onDateTap() async {
    DateTime dateStart = await showDatePicker(
      context: context,
      initialDate: _eventDateStart,
      firstDate: _firstDate,
      lastDate: DateTime(2030),
      locale: _locale,
    );

    if (dateStart != null) {
      final newStart = DateTime(dateStart.year, dateStart.month, dateStart.day,
          _eventDateStart.hour, _eventDateStart.minute);

      _updateTimes(newStart, _eventDateEnd);
    }
  }

  void _onStartTimeTap() async {
    TimeOfDay timeStart = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_eventDateStart),
    );

    if (timeStart != null) {
      final newStart = DateTime(_eventDateStart.year, _eventDateStart.month,
          _eventDateStart.day, timeStart.hour, timeStart.minute);

      _updateTimes(newStart, _eventDateEnd);
    }
  }

  void _onEndTimeTap() async {
    TimeOfDay timeEnd = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_eventDateStart),
    );

    if (timeEnd != null) {
      final newEnd = DateTime(_eventDateStart.year, _eventDateStart.month,
          _eventDateStart.day, timeEnd.hour, timeEnd.minute);

      _updateTimes(_eventDateStart, newEnd);
    }
  }

  void _updateTimes(DateTime start, DateTime end) {
    setState(() {
      _eventDateStart = start;
      _eventDateEnd = end;
    });
  }

  Widget _buildDateTimeField(
      String title, String value, GestureTapCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: TextField(
        enabled: false,
        autofocus: false,
        controller: TextEditingController(text: value),
        decoration: InputDecoration(labelText: title, border: InputBorder.none),
      ),
    );
  }

  String _validateTextField(String value) {
    if (value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  void _onSubmit(BuildContext context) {
    if (_formKey.currentState.validate()) {
      final course = CustomCourse(
        Uuid().v1(),
        _titleController.text,
        _descController.text,
        _locationController.text,
        _eventDateStart,
        _eventDateEnd,
        [],
        (_isCustomColor && _eventColor != null) ? _eventColor : null,
      );

      Preferences.addCustomEvent(course).then((_) {
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _locale = Translations.of(context).locale;

    return AppbarPage(
      title: "Add event",
      actions: [
        IconButton(
            icon: const Icon(Icons.check), onPressed: () => _onSubmit(context))
      ],
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.title),
                title: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration.collapsed(hintText: "Title"),
                  validator: _validateTextField,
                ),
              ),
              Divider(height: 4.0),
              ListTile(
                leading: const Icon(Icons.description),
                title: TextFormField(
                  controller: _descController,
                  decoration:
                      InputDecoration.collapsed(hintText: "Description"),
                  validator: _validateTextField,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
              ),
              Divider(height: 4.0),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration.collapsed(hintText: "Location"),
                  validator: _validateTextField,
                ),
              ),
              Divider(height: 4.0),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: _buildDateTimeField(
                  "Date",
                  Date.extractDate(_eventDateStart, _locale),
                  _onDateTap,
                ),
              ),
              Divider(height: 4.0),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: _buildDateTimeField(
                        "Heure début",
                        Date.extractTime(_eventDateStart, _locale),
                        _onStartTimeTap,
                      ),
                    ),
                  ),
                  Container(width: 16.0),
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: _buildDateTimeField(
                        "Heure fin",
                        Date.extractTime(_eventDateEnd, _locale),
                        _onEndTimeTap,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(height: 4.0),
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: Text("Custom color"),
                trailing: Switch(
                    value: _isCustomColor,
                    activeColor: Theme.of(context).accentColor,
                    onChanged: (value) {
                      setState(() {
                        _isCustomColor = value;
                      });
                    }),
              ),
              _isCustomColor
                  ? ListTileColor(
                      title: "Event color",
                      description: "Custom color of this event",
                      defaultColor: _eventColor,
                      onColorChange: (color) {
                        setState(() {
                          _eventColor = color;
                        });
                      },
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}