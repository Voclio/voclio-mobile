import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'home_system_tokens.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

class HomeCanvas extends StatelessWidget {
  final Widget child;

  const HomeCanvas({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: HomeSystemTokens.canvas,
      child: child,
    );
  }
}

class HomeScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final Color accent;
  final List<Widget> actions;
  final bool compact;

  const HomeScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.accent = HomeSystemTokens.purple,
    this.actions = const [],
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleSize = compact ? 20.sp : 22.sp;
    final subtitleSize = compact ? 12.sp : 13.sp;
    final iconBox = compact ? 36.r : 40.r;
    final iconSize = compact ? 18.sp : 20.sp;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Container(
            width: iconBox,
            height: iconBox,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius:
                  BorderRadius.circular(HomeSystemTokens.radiusSm.r),
            ),
            child: Icon(icon, color: accent, size: iconSize),
          ),
          SizedBox(width: 10.w),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                  color: HomeSystemTokens.ink,
                  letterSpacing: -0.3,
                  height: 1.15,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: HomeSystemTokens.inkMuted,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        ...actions,
      ],
    );
  }
}

class HomeStatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String subtitle;

  const HomeStatTile({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: HomeSystemTokens.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 14.sp),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: HomeSystemTokens.inkMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: HomeSystemTokens.ink,
                height: 1,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class HomeSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const HomeSectionCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: HomeSystemTokens.cardDecoration(),
      child: child,
    );
  }
}

class HomeSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const HomeSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return HomeSectionCard(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(fontSize: 15.sp, color: HomeSystemTokens.ink),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: HomeSystemTokens.inkMuted,
            fontSize: 15.sp,
          ),
          prefixIcon: Icon(
            AppIcons.search_rounded,
            color: HomeSystemTokens.inkMuted,
            size: 22.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }
}

/// Filter chip with label + circular count badge (calendar style).
class HomeCountedFilterPill extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const HomeCountedFilterPill({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: selected
              ? HomeSystemTokens.purple.withValues(alpha: 0.1)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(
            color: selected ? HomeSystemTokens.purple : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? HomeSystemTokens.purple
                    : HomeSystemTokens.inkSoft,
              ),
            ),
            SizedBox(width: 6.w),
            Container(
              width: 18.r,
              height: 18.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? HomeSystemTokens.purple
                    : const Color(0xFFE5E7EB),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : HomeSystemTokens.inkSoft,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeSectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  const HomeSectionTitle({
    super.key,
    required this.title,
    this.trailing,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w, bottom: 8.h),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: HomeSystemTokens.ink,
              letterSpacing: -0.2,
            ),
          ),
          const Spacer(),
          if (trailing != null)
            GestureDetector(
              onTap: onTrailingTap,
              child: Text(
                trailing!,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: HomeSystemTokens.purple,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class HomeBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const HomeBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: HomeIconButton(
        icon: AppIcons.arrow_back_ios_new_rounded,
        color: HomeSystemTokens.inkSoft,
        onTap: onTap ?? () => Navigator.maybePop(context),
      ),
    );
  }
}

class HomeSecondaryScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color accent;
  final Widget body;
  final List<Widget> actions;
  final bool showBack;
  final bool compact;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? bottom;

  const HomeSecondaryScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.icon,
    this.accent = HomeSystemTokens.purple,
    this.actions = const [],
    this.showBack = true,
    this.compact = true,
    this.floatingActionButton,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeSystemTokens.canvas,
      floatingActionButton: floatingActionButton,
      body: HomeCanvas(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  showBack ? 8.w : 20.w,
                  4.h,
                  20.w,
                  8.h,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (showBack && Navigator.canPop(context))
                      const HomeBackButton(),
                    Expanded(
                      child: HomeScreenHeader(
                        title: title,
                        subtitle: subtitle ?? '',
                        icon: icon,
                        accent: accent,
                        actions: actions,
                        compact: compact,
                      ),
                    ),
                  ],
                ),
              ),
              if (bottom != null) bottom!,
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color accent;

  const HomeEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.accent = HomeSystemTokens.purple,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.r,
              height: 100.r,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48.sp, color: accent),
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: HomeSystemTokens.ink,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: HomeSystemTokens.inkMuted,
                height: 1.5,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class HomeMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showDivider;

  const HomeMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor = HomeSystemTokens.purple,
    this.onTap,
    this.trailing,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              child: Row(
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(icon, color: iconColor, size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: HomeSystemTokens.ink,
                          ),
                        ),
                        if (subtitle != null) ...[
                          SizedBox(height: 2.h),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: HomeSystemTokens.inkMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  trailing ??
                      Icon(
                        AppIcons.chevron_right_rounded,
                        color: HomeSystemTokens.inkMuted,
                        size: 22.sp,
                      ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 66.w,
            color: HomeSystemTokens.inkMuted.withValues(alpha: 0.15),
          ),
      ],
    );
  }
}

class HomeSettingsGroup extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const HomeSettingsGroup({
    super.key,
    this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
            child: Text(
              title!.toUpperCase(),
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: HomeSystemTokens.inkMuted,
                letterSpacing: 1.1,
              ),
            ),
          ),
        HomeSectionCard(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class HomeIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const HomeIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeSystemTokens.card,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: HomeSystemTokens.cardShadow(opacity: 0.03),
          ),
          child: Icon(
            icon,
            color: color ?? HomeSystemTokens.purple,
            size: 22.sp,
          ),
        ),
      ),
    );
  }
}
