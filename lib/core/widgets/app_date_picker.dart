import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_text_styles.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';
import 'app_button.dart';

class AppDatePicker {
  AppDatePicker._();

  /// Opens a modern, interactive custom segmented Date Picker bottom sheet
  /// with dedicated Day, Month, and Year tabs and interactive chips.
  /// If [onlyYear] is true, only year selection is shown and returned.
  /// If [allowFutureDates] is false, the latest selectable date is [DateTime.now()].
  /// If [allowFutureDates] is true, future dates up to [lastDate] (default +50 years) are selectable.
  static Future<DateTime?> pickDate({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    bool allowFutureDates = false,
    bool onlyYear = false,
    String? title,
    String? helpText,
  }) async {
    final now = DateTime.now();

    final effectiveFirstDate = firstDate ?? DateTime(1900);
    final effectiveLastDate = allowFutureDates
        ? (lastDate ?? DateTime(now.year + 50, 12, 31))
        : (lastDate != null && lastDate.isBefore(now) ? lastDate : now);

    DateTime effectiveInitialDate = initialDate ?? now;

    // Boundary clamp
    if (effectiveInitialDate.isBefore(effectiveFirstDate)) {
      effectiveInitialDate = effectiveFirstDate;
    } else if (effectiveInitialDate.isAfter(effectiveLastDate)) {
      effectiveInitialDate = effectiveLastDate;
    }

    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UniqueDatePickerBottomSheet(
        title: title ?? helpText ?? (onlyYear ? "Select Year" : "Select Date"),
        initialDate: effectiveInitialDate,
        firstDate: effectiveFirstDate,
        lastDate: effectiveLastDate,
        onlyYear: onlyYear,
      ),
    );
  }

  /// Formats a [DateTime] object into a standard string like 'dd/MM/yyyy' or custom [pattern].
  static String format(DateTime date, {String pattern = 'dd/MM/yyyy'}) {
    return DateFormat(pattern).format(date);
  }
}

enum _PickerTab { day, month, year }

class _UniqueDatePickerBottomSheet extends StatefulWidget {
  final String title;
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final bool onlyYear;

  const _UniqueDatePickerBottomSheet({
    required this.title,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.onlyYear = false,
  });

  @override
  State<_UniqueDatePickerBottomSheet> createState() =>
      _UniqueDatePickerBottomSheetState();
}

class _UniqueDatePickerBottomSheetState
    extends State<_UniqueDatePickerBottomSheet> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  _PickerTab _currentTab = _PickerTab.year;

  final ScrollController _yearScrollController = ScrollController();
  final ScrollController _dayScrollController = ScrollController();

  String get _localeName => Localizations.localeOf(context).toString();

  /// Short month name in the app's language, e.g. "Jan".
  String _monthName(int month) =>
      DateFormat.MMM(_localeName).format(DateTime(2000, month));

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
    _selectedDay = widget.initialDate.day;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedYear();
    });
  }

  @override
  void dispose() {
    _yearScrollController.dispose();
    _dayScrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedYear() {
    if (!_yearScrollController.hasClients) return;
    final years = _getAvailableYears();
    final index = years.indexOf(_selectedYear);
    if (index != -1) {
      final targetOffset = (index ~/ 4) * 48.0;
      _yearScrollController.animateTo(
        targetOffset.clamp(0.0, _yearScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  List<int> _getAvailableYears() {
    final startYear = widget.firstDate.year;
    final endYear = widget.lastDate.year;
    final List<int> years = [];
    for (int y = endYear; y >= startYear; y--) {
      years.add(y);
    }
    return years;
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  DateTime get _currentDate {
    final maxDays = _daysInMonth(_selectedYear, _selectedMonth);
    final validDay = _selectedDay > maxDays ? maxDays : _selectedDay;
    var date = DateTime(_selectedYear, _selectedMonth, validDay);
    if (date.isAfter(widget.lastDate)) {
      date = widget.lastDate;
    }
    if (date.isBefore(widget.firstDate)) {
      date = widget.firstDate;
    }
    return date;
  }

  bool _isDateValid(int year, int month, int day) {
    final date = DateTime(year, month, day);
    return !date.isAfter(widget.lastDate) && !date.isBefore(widget.firstDate);
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = _currentDate;

    return Container(
      constraints: BoxConstraints(maxHeight: context.height * 0.82),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Pill
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              16.hBox,

              // Header
              Row(
                children: [
                  Text(
                    widget.title,
                    style: AppTextStyles.textStyle_600_14.copyWith(
                      fontSize: 18,
                      color: AppColors.textCharcoal,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.08),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              16.hBox,

              // Interactive Segmented Date Header Card
              if (!widget.onlyYear) ...[
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildSegmentButton(
                        tab: _PickerTab.year,
                        title: "Year",
                        value: '$_selectedYear',
                      ),
                      8.wBox,
                      _buildSegmentButton(
                        tab: _PickerTab.month,
                        title: "Month",
                        value: _monthName(_selectedMonth),
                      ),
                      8.wBox,
                      _buildSegmentButton(
                        tab: _PickerTab.day,
                        title: "Day",
                        value: _selectedDay.toString().padLeft(2, '0'),
                      ),
                    ],
                  ),
                ),
                16.hBox,
              ],

              // Date Formatted Preview Pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.event_available_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    6.wBox,
                    Flexible(
                      child: Text(
                        widget.onlyYear
                            ? '$_selectedYear'
                            : DateFormat(
                                'EEEE, dd MMMM yyyy',
                                _localeName,
                              ).format(currentDate),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.textStyle_600_14.copyWith(
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    8.wBox,
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 20.r,
                        height: 20.r,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              14.hBox,

              // Dynamic Segment Content
              Expanded(
                child: widget.onlyYear
                    ? _buildYearGrid()
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _buildTabContent(),
                      ),
              ),
              16.hBox,

              // Action Button
              AppButton(
                label: "Done",
                isBlack: true,
                onTap: () {
                  if (widget.onlyYear) {
                    Navigator.of(context).pop(DateTime(_selectedYear));
                  } else {
                    Navigator.of(context).pop(_currentDate);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required _PickerTab tab,
    required String title,
    required String value,
  }) {
    final isSelected = _currentTab == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentTab = tab;
          });
          if (tab == _PickerTab.year) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToSelectedYear();
            });
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                title.toUpperCase(),
                style: AppTextStyles.textStyle_400_14.copyWith(
                  fontSize: 10,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.fieldTextColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              4.hBox,
              Text(
                value,
                style: AppTextStyles.textStyle_600_14.copyWith(
                  fontSize: 16,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textCharcoal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTab) {
      case _PickerTab.year:
        return _buildYearGrid();
      case _PickerTab.month:
        return _buildMonthGrid();
      case _PickerTab.day:
        return _buildDayGrid();
    }
  }

  Widget _buildYearGrid() {
    final years = _getAvailableYears();

    return GridView.builder(
      key: const ValueKey('year_grid'),
      controller: _yearScrollController,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 2.1,
      ),
      itemCount: years.length,
      itemBuilder: (context, index) {
        final year = years[index];
        final isSelected = year == _selectedYear;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedYear = year;
              _currentTab = _PickerTab.month;
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.fieldBgColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.fieldBorderColor,
              ),
            ),
            child: Text(
              '$year',
              style: AppTextStyles.textStyle_500_14.copyWith(
                fontSize: 14,
                color: isSelected ? AppColors.white : AppColors.textCharcoal,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthGrid() {
    return GridView.builder(
      key: const ValueKey('month_grid'),
      padding: EdgeInsets.symmetric(vertical: 8.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 2.2,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final monthNumber = index + 1;
        final monthName = _monthName(index + 1);
        final isSelected = monthNumber == _selectedMonth;

        final isFuture =
            _selectedYear == widget.lastDate.year &&
            monthNumber > widget.lastDate.month;
        final isPast =
            _selectedYear == widget.firstDate.year &&
            monthNumber < widget.firstDate.month;
        final isDisabled = isFuture || isPast;

        return GestureDetector(
          onTap: isDisabled
              ? null
              : () {
                  setState(() {
                    _selectedMonth = monthNumber;
                    _currentTab = _PickerTab.day;
                  });
                },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : (isDisabled
                        ? AppColors.fieldBgColor.withValues(alpha: 0.5)
                        : AppColors.fieldBgColor),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.fieldBorderColor,
              ),
            ),
            child: Text(
              monthName,
              style: AppTextStyles.textStyle_500_14.copyWith(
                fontSize: 14,
                color: isSelected
                    ? AppColors.white
                    : (isDisabled
                          ? AppColors.fieldTextColor.withValues(alpha: 0.5)
                          : AppColors.textCharcoal),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayGrid() {
    final daysInMonth = _daysInMonth(_selectedYear, _selectedMonth);

    return GridView.builder(
      key: const ValueKey('day_grid'),
      controller: _dayScrollController,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        final day = index + 1;
        final isSelected = day == _selectedDay;
        final isValid = _isDateValid(_selectedYear, _selectedMonth, day);

        return GestureDetector(
          onTap: !isValid
              ? null
              : () {
                  setState(() {
                    _selectedDay = day;
                  });
                },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : (isValid
                        ? AppColors.fieldBgColor
                        : AppColors.fieldBgColor.withValues(alpha: 0.4)),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : (isValid
                          ? AppColors.fieldBorderColor
                          : Colors.transparent),
              ),
            ),
            child: Text(
              '$day',
              style: AppTextStyles.textStyle_500_14.copyWith(
                fontSize: 13,
                color: isSelected
                    ? AppColors.white
                    : (isValid
                          ? AppColors.textCharcoal
                          : AppColors.fieldTextColor.withValues(alpha: 0.4)),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      },
    );
  }
}
