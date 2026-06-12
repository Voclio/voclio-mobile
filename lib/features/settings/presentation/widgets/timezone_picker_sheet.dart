import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

class TimezonePickerSheet extends StatefulWidget {
  final String currentTimezone;

  const TimezonePickerSheet({super.key, required this.currentTimezone});

  static const List<String> supportedTimezones = [
    'UTC',
    'Africa/Cairo',
    'Africa/Casablanca',
    'Africa/Johannesburg',
    'America/Chicago',
    'America/Los_Angeles',
    'America/New_York',
    'America/Sao_Paulo',
    'Asia/Dubai',
    'Asia/Kolkata',
    'Asia/Riyadh',
    'Asia/Singapore',
    'Asia/Tokyo',
    'Australia/Sydney',
    'Europe/Berlin',
    'Europe/Istanbul',
    'Europe/London',
    'Europe/Paris',
  ];

  static Future<String?> show(BuildContext context, String current) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TimezonePickerSheet(currentTimezone: current),
    );
  }

  @override
  State<TimezonePickerSheet> createState() => _TimezonePickerSheetState();
}

class _TimezonePickerSheetState extends State<TimezonePickerSheet> {
  late final TextEditingController _searchController;
  late List<String> _filtered;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filtered = List<String>.from(TimezonePickerSheet.supportedTimezones);
    if (!_filtered.contains(widget.currentTimezone)) {
      _filtered = [widget.currentTimezone, ..._filtered];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    final lower = query.trim().toLowerCase();
    setState(() {
      _filtered = TimezonePickerSheet.supportedTimezones
          .where((tz) => tz.toLowerCase().contains(lower))
          .toList();
      if (widget.currentTimezone.toLowerCase().contains(lower) &&
          !_filtered.contains(widget.currentTimezone)) {
        _filtered = [widget.currentTimezone, ..._filtered];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h + bottomSafe),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      decoration: HomeSystemTokens.cardDecoration().copyWith(
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: HomeSystemTokens.inkMuted.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
            child: Text(
              'Choose timezone',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: HomeSystemTokens.ink,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: TextField(
              controller: _searchController,
              onChanged: _filter,
              decoration: InputDecoration(
                hintText: 'Search timezone',
                prefixIcon: Icon(
                  AppIcons.search_rounded,
                  color: HomeSystemTokens.inkMuted,
                  size: 20.sp,
                ),
                filled: true,
                fillColor: HomeSystemTokens.canvas,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => SizedBox(height: 4.h),
              itemBuilder: (context, index) {
                final tz = _filtered[index];
                final selected = tz == widget.currentTimezone;
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  tileColor: selected
                      ? HomeSystemTokens.purple.withValues(alpha: 0.08)
                      : null,
                  title: Text(
                    tz.replaceAll('_', ' '),
                    style: TextStyle(
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      color: HomeSystemTokens.ink,
                    ),
                  ),
                  trailing: selected
                      ? Icon(
                          AppIcons.check_rounded,
                          color: HomeSystemTokens.purple,
                        )
                      : null,
                  onTap: () => Navigator.pop(context, tz),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
