import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

class DateRangePicker extends StatefulWidget {
  final Function(DateTime, DateTime) onDateRangeSelected;
  final String selectedLanguage;

  const DateRangePicker({
    super.key,
    required this.onDateRangeSelected,
    required this.selectedLanguage,
  });

  @override
  State<DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  DateTime? _startDate;
  DateTime? _endDate;
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDateSelector(
                  _getStartDateText(widget.selectedLanguage),
                  _startDate,
                  true,
                ),
              ),
              Container(
                height: 30,
                width: 1,
                color: Colors.grey.shade300,
              ),
              Expanded(
                child: _buildDateSelector(
                  _getEndDateText(widget.selectedLanguage),
                  _endDate,
                  false,
                ),
              ),
            ],
          ),
          if (_startDate != null && _endDate != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                _getDurationText(widget.selectedLanguage),
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime? selectedDate, bool isStartDate) {
    return InkWell(
      onTap: () => _selectDate(isStartDate),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  selectedDate != null
                      ? _dateFormat.format(selectedDate)
                      : _getSelectDateText(widget.selectedLanguage),
                  style: TextStyle(
                    fontSize: 14,
                    color: selectedDate != null
                        ? AppTheme.textPrimary
                        : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = now;
    final DateTime lastDate = now.add(const Duration(days: 365));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? _startDate ?? now
          : _endDate ?? (_startDate != null ? _startDate!.add(const Duration(days: 1)) : now.add(const Duration(days: 1))),
      firstDate: isStartDate ? firstDate : (_startDate ?? firstDate),
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          // If end date is before start date, reset end date
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = pickedDate;
        }

        if (_startDate != null && _endDate != null) {
          widget.onDateRangeSelected(_startDate!, _endDate!);
        }
      });
    }
  }

  String _getDurationText(String languageCode) {
    if (_startDate == null || _endDate == null) return '';
    
    final days = _endDate!.difference(_startDate!).inDays + 1;
    
    switch (languageCode) {
      case AppConstants.hindi:
        return '$days दिन की अवधि';
      case AppConstants.marathi:
        return '$days दिवसांचा कालावधी';
      default:
        return '$days days duration';
    }
  }

  // Multilingual text getters
  String _getStartDateText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'प्रारंभ तिथि';
      case AppConstants.marathi:
        return 'प्रारंभ तारीख';
      default:
        return 'Start Date';
    }
  }

  String _getEndDateText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'अंतिम तिथि';
      case AppConstants.marathi:
        return 'अंतिम तारीख';
      default:
        return 'End Date';
    }
  }

  String _getSelectDateText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'तिथि चुनें';
      case AppConstants.marathi:
        return 'तारीख निवडा';
      default:
        return 'Select date';
    }
  }
}