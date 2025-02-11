import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'constants/constants.dart';
import 'widgets/datetime_picker_ios.dart';

enum DateMode {
  time,
  date,
}

class DateTimeFieldPlatform extends StatefulWidget {
  const DateTimeFieldPlatform({
    Key? key,
    required this.maximumDate,
    required this.minimumDate,
    this.initialDate,
    this.decoration = const InputDecoration(),
    this.mode = DateMode.date,
    this.title = "Select",
    this.textCancel = "Cancel",
    this.textConfirm = "Confirm",
    this.onCancel,
    this.validator,
    this.onConfirm,
    this.inputStyle,
    this.titleStyle,
    this.controller,
    this.textCancelStyle,
    this.textConfirmStyle,
    this.dateFormatter = dateFormat,
    this.timeFormatter = timeFormat,
  }) : super(key: key);

  final DateMode mode;
  final String? title;
  final String? dateFormatter;
  final String? timeFormatter;
  final String? textCancel;
  final String? textConfirm;
  final DateTime? initialDate;
  final DateTime maximumDate;
  final DateTime minimumDate;
  final TextStyle? inputStyle;
  final TextStyle? titleStyle;
  final TextStyle? textCancelStyle;
  final TextStyle? textConfirmStyle;
  final InputDecoration? decoration;
  final VoidCallback? onCancel;
  final Function(DateTime)? onConfirm;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;

  @override
  State<DateTimeFieldPlatform> createState() => _DateTimeFieldPlatformState();
}

class _DateTimeFieldPlatformState extends State<DateTimeFieldPlatform> {
  late DateTime selectedDate;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    selectedDate = widget.initialDate ?? DateTime.now();
    _controller.text = DateFormat(_getFormattedDate()).format(selectedDate);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tootlePicker,
      child: AbsorbPointer(
        child: TextFormField(
          controller: _controller,
          style: widget.inputStyle,
          validator: widget.validator,
          decoration: widget.decoration,
        ),
      ),
    );
  }

  String _getFormattedDate() {
    return widget.mode == DateMode.date 
      ? (widget.dateFormatter ?? 'dd/MM/yyyy') 
      : (widget.timeFormatter ?? 'hh:mm aa');
  }

  void tootlePicker() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        showPickerDateTimeIOS();
        break;
      default:
        showPickerDateTimeAndroid();
    }
  }

  Future<void> showPickerDateTimeAndroid() async {
    switch (widget.mode) {
      case DateMode.time:
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(selectedDate),
          cancelText: widget.textCancel,
          confirmText: widget.textConfirm,
          helpText: widget.title,
        );
        if (picked != null) {
          final parseSelectedDate = _parseSelectedDate(picked);
          _controller.text = DateFormat(_getFormattedDate()).format(parseSelectedDate);
          selectedDate = parseSelectedDate;
          widget.onConfirm?.call(parseSelectedDate);
        }
        break;
      default:
        final DateTime? picked = await showDatePicker(
          context: context,
          cancelText: widget.textCancel,
          confirmText: widget.textConfirm,
          helpText: widget.title,
          initialDate: selectedDate,
          firstDate: widget.minimumDate,
          lastDate: widget.maximumDate,
        );
        if (picked != null) {
          selectedDate = picked;
          _controller.text = DateFormat(_getFormattedDate()).format(selectedDate);
          widget.onConfirm?.call(selectedDate);
        }
    }
  }

  void showPickerDateTimeIOS() {
    showModalBottomSheet(
      context: context,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.35,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      builder: (context) => _renderDatetimeIOS(),
    );
  }

  Widget _renderDatetimeIOS() {
    DateTime changeDate = selectedDate;

    return DateTimePickerIOS(
      mode: widget.mode,
      title: widget.title ?? "Select",
      textCancel: widget.textCancel ?? "Cancel",
      textConfirm: widget.textConfirm ?? "Confirm",
      onCancel: () {
        widget.onCancel?.call();
        Navigator.of(context).pop();
      },
      onConfirm: () {
        _controller.text = DateFormat(_getFormattedDate()).format(changeDate);
        selectedDate = changeDate;
        widget.onConfirm?.call(changeDate);
        Navigator.of(context).pop();
      },
      onDateTimeChanged: (value) {
        changeDate = value;
      },
      initialDateTime: selectedDate,
      minimumDate: widget.minimumDate,
      maximumDate: widget.maximumDate,
      titleStyle: widget.titleStyle,
      textCancelStyle: widget.textCancelStyle,
      textConfirmStyle: widget.textConfirmStyle,
    );
  }

  DateTime _parseSelectedDate(TimeOfDay selectedTime) {
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }
}
