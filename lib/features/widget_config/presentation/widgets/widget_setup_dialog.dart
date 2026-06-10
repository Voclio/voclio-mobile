import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/widget_preference.dart';
import '../bloc/widget_config_cubit.dart';
import '../bloc/widget_config_state.dart';

/// A popup dialog that allows users to configure which widgets they want to see
class WidgetSetupDialog extends StatefulWidget {
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;
  final bool isEditMode;

  const WidgetSetupDialog({
    super.key,
    this.onComplete,
    this.onSkip,
    this.isEditMode = false,
  });

  /// Show the widget setup dialog
  static Future<bool?> show(
    BuildContext context, {
    WidgetConfigCubit? cubit,
    bool isEditMode = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: isEditMode,
      builder: (context) {
        final dialog = WidgetSetupDialog(
          isEditMode: isEditMode,
          onComplete: () => Navigator.of(context).pop(true),
          onSkip: () => Navigator.of(context).pop(false),
        );
        if (cubit != null) {
          return BlocProvider.value(value: cubit, child: dialog);
        }
        return dialog;
      },
    );
  }

  @override
  State<WidgetSetupDialog> createState() => _WidgetSetupDialogState();
}

class _WidgetSetupDialogState extends State<WidgetSetupDialog> {
  final Map<WidgetType, bool> _selectedWidgets = {};
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode) {
      final preferences = context.read<WidgetConfigCubit>().state.preferences;
      for (final config in preferences.widgets) {
        _selectedWidgets[config.type] = config.isEnabled;
      }
      _currentPage = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(1);
        }
      });
    } else {
      for (final type in WidgetType.values) {
        _selectedWidgets[type] =
            type == WidgetType.todayTasks || type == WidgetType.upcomingTasks;
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveAndComplete();
    }
  }

  Future<void> _saveAndComplete() async {
    final cubit = context.read<WidgetConfigCubit>();
    cubit.updateWidgetSelections(_selectedWidgets);

    final success = widget.isEditMode
        ? await cubit.savePreferences()
        : await cubit.completeSetup();

    if (success && mounted) {
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
          child: Container(
            constraints: BoxConstraints(maxHeight: 600.h),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(theme),

                if (!widget.isEditMode) _buildPageIndicator(theme),

                // Content
                Expanded(
                  child: widget.isEditMode
                      ? _buildWidgetSelectionPage(theme)
                      : PageView(
                          controller: _pageController,
                          onPageChanged: (index) =>
                              setState(() => _currentPage = index),
                          children: [
                            _buildWelcomePage(theme),
                            _buildWidgetSelectionPage(theme),
                          ],
                        ),
                ),

                // Actions
                _buildActions(theme),
              ],
            ),
          ),
        )
        .animate()
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 300.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 200.ms);
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.widgets_rounded,
              color: Colors.white,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isEditMode
                      ? 'Home Widgets'
                      : 'Personalize Your Home',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.isEditMode
                      ? 'Choose what appears on your home screen'
                      : 'Choose what you want to see',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(2, (index) {
          final isActive = _currentPage == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            width: isActive ? 24.w : 8.w,
            height: 8.h,
            decoration: BoxDecoration(
              color: isActive ? theme.primaryColor : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4.r),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWelcomePage(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor.withOpacity(0.1),
                  theme.primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.dashboard_customize_rounded,
              size: 60.sp,
              color: theme.primaryColor,
            ),
          ).animate().scale(delay: 200.ms, duration: 400.ms),
          SizedBox(height: 24.h),
          Text(
            'Welcome! 🎉',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ).animate().fadeIn(delay: 300.ms),
          SizedBox(height: 12.h),
          Text(
            'Let\'s set up your home screen widgets to show the information that matters most to you.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 400.ms),
          SizedBox(height: 32.h),
          _buildFeatureItem(
            theme,
            Icons.task_alt_rounded,
            'Quick Task Overview',
            'See your upcoming tasks at a glance',
          ).animate().slideX(begin: -0.2, delay: 500.ms),
          SizedBox(height: 16.h),
          _buildFeatureItem(
            theme,
            Icons.calendar_month_rounded,
            'Calendar Events',
            'Never miss an important event',
          ).animate().slideX(begin: -0.2, delay: 600.ms),
          SizedBox(height: 16.h),
          _buildFeatureItem(
            theme,
            Icons.note_alt_rounded,
            'Quick Notes',
            'Access your recent notes instantly',
          ).animate().slideX(begin: -0.2, delay: 700.ms),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: theme.primaryColor, size: 22.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetSelectionPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          Text(
            'Select your widgets',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Tap to enable or disable',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
          ),
          SizedBox(height: 16.h),
          ...WidgetType.values.map((type) => _buildWidgetOption(theme, type)),
        ],
      ),
    );
  }

  Widget _buildWidgetOption(ThemeData theme, WidgetType type) {
    final isSelected = _selectedWidgets[type] ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedWidgets[type] = !isSelected;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color:
              isSelected ? theme.primaryColor.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isSelected ? theme.primaryColor : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                _getIconForWidgetType(type),
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.displayName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected
                              ? theme.primaryColor
                              : theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    type.description,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? theme.primaryColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? theme.primaryColor : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child:
                  isSelected
                      ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForWidgetType(WidgetType type) {
    switch (type) {
      case WidgetType.upcomingTasks:
        return Icons.upcoming_rounded;
      case WidgetType.todayTasks:
        return Icons.today_rounded;
      case WidgetType.calendar:
        return Icons.calendar_month_rounded;
      case WidgetType.notes:
        return Icons.note_alt_rounded;
      case WidgetType.reminders:
        return Icons.notifications_active_rounded;
      case WidgetType.productivity:
        return Icons.insights_rounded;
      case WidgetType.quickActions:
        return Icons.flash_on_rounded;
    }
  }

  Widget _buildActions(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          if (!widget.isEditMode && _currentPage == 0)
            TextButton(
              onPressed: () {
                context.read<WidgetConfigCubit>().skipSetup();
                widget.onSkip?.call();
              },
              child: Text(
                'Skip',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
              ),
            ),
          if (!widget.isEditMode && _currentPage > 0)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Text(
                'Back',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
              ),
            ),
          if (widget.isEditMode)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
              ),
            ),
          const Spacer(),
          BlocBuilder<WidgetConfigCubit, WidgetConfigState>(
            builder: (context, state) {
              final isLoading = state.status == WidgetConfigStatus.saving;
              return ElevatedButton(
                onPressed: isLoading
                    ? null
                    : widget.isEditMode
                        ? _saveAndComplete
                        : _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 28.w,
                    vertical: 14.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child:
                    isLoading
                        ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                        : Text(
                          widget.isEditMode
                              ? 'Save'
                              : (_currentPage == 0 ? 'Next' : 'Done'),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              );
            },
          ),
        ],
      ),
    );
  }
}
