// Icon names mirror Material Icons for a drop-in migration.
// ignore_for_file: non_constant_identifier_names

import 'package:flutter/widgets.dart';
import 'package:uicons/uicons.dart';

/// Outlined + filled icon pair for toggled/active UI states.
class AppIconVariants {
  const AppIconVariants({required this.outlined, required this.filled});

  final IconData outlined;
  final IconData filled;

  IconData of(bool active) => active ? filled : outlined;
}

/// Flaticon UIcons (regular rounded + brands) used across Voclio.
///
/// Default icons use [UIcons.regularRounded] (outlined).
/// Active/selected states use [UIcons.solidRounded] (filled) via [AppIconVariants].
class AppIcons {
  AppIcons._();

  static final _r = UIcons.regularRounded;
  static final _s = UIcons.solidRounded;
  static final _b = UIcons.brands;

  static final navHome = AppIconVariants(
    outlined: _r.home,
    filled: _s.home,
  );
  static final navTasks = AppIconVariants(
    outlined: _r.clipboard_list_check,
    filled: _s.clipboard_list_check,
  );
  static final navCalendar = AppIconVariants(
    outlined: _r.calendar,
    filled: _s.calendar,
  );
  static final navNotes = AppIconVariants(
    outlined: _r.notebook,
    filled: _s.notebook,
  );

  static final bottomNav = [navHome, navTasks, navCalendar, navNotes];

  static IconData get access_time => _r.time_oclock;
  static IconData get access_time_rounded => _r.time_oclock;
  static IconData get add => _r.add;
  static IconData get add_circle_outline => _r.add;
  static IconData get add_rounded => _r.add;
  static IconData get add_task_rounded => _r.clipboard_list_check;
  static IconData get alarm => _r.alarm_clock;
  static IconData get alarm_rounded => _r.alarm_clock;
  static IconData get arrow_back_ios_new => _r.angle_small_left;
  static IconData get arrow_back_ios_new_rounded => _r.angle_small_left;
  static IconData get arrow_drop_down => _r.angle_small_down;
  static IconData get arrow_forward_rounded => _r.arrow_small_right;
  static IconData get article_outlined => _r.document;
  static IconData get assignment_outlined => _r.clipboard_list;
  static IconData get auto_awesome => _r.sparkles;
  static IconData get auto_awesome_rounded => _r.sparkles;
  static IconData get bolt_rounded => _r.bolt;
  static IconData get calendar_month => _r.calendar;
  static IconData get calendar_month_outlined => _r.calendar;
  static IconData get calendar_month_rounded => _r.calendar;
  static IconData get calendar_today => _r.calendar;
  static IconData get calendar_today_outlined => _r.calendar;
  static IconData get calendar_today_rounded => _r.calendar;
  static IconData get calendar_view_day => _r.calendar_lines;
  static IconData get calendar_view_week => _r.calendars;
  static IconData get camera_alt => _r.camera;
  static IconData get cancel => _r.cross_circle;
  static IconData get celebration => _r.balloons;
  static IconData get celebration_rounded => _r.balloons;
  static IconData get check => _r.check;
  static IconData get check_circle => _r.badge_check;
  static IconData get check_circle_outline_rounded => _r.checkbox;
  static IconData get check_circle_rounded => _r.badge_check;
  static IconData get check_rounded => _r.check;
  static IconData get checklist_rounded => _r.clipboard_list_check;
  static IconData get chevron_left => _r.angle_small_left;
  static IconData get chevron_right => _r.angle_small_right;
  static IconData get chevron_right_rounded => _r.angle_small_right;
  static IconData get circle_outlined => _r.circle;
  static IconData get clear_all => _r.broom;
  static IconData get close => _r.cross;
  static IconData get cloud_off_rounded => _r.cloud_disabled;
  static IconData get coffee => _r.coffee;
  static IconData get dashboard_customize_rounded => _r.apps;
  static IconData get dashboard_outlined => _r.dashboard;
  static IconData get delete => _r.trash;
  static IconData get delete_forever_rounded => _r.trash;
  static IconData get delete_outline => _r.trash;
  static IconData get delete_outline_rounded => _r.trash;
  static IconData get delete_rounded => _r.trash;
  static IconData get delete_sweep_rounded => _r.broom;
  static IconData get description => _r.document;
  static IconData get description_outlined => _r.document;
  static IconData get done_all_rounded => _r.list_check;
  static IconData get edit => _r.edit;
  static IconData get edit_note_rounded => _r.notebook;
  static IconData get edit_outlined => _r.edit;
  static IconData get edit_rounded => _r.edit;
  static IconData get email => _r.envelope;
  static IconData get email_outlined => _r.envelope;
  static IconData get emoji_events => _r.trophy;
  static IconData get emoji_events_outlined => _r.trophy;
  static IconData get emoji_events_rounded => _r.trophy;
  static IconData get error_outline => _r.exclamation;
  static IconData get error_outline_rounded => _r.exclamation;
  static IconData get error_rounded => _r.cross_circle;
  static IconData get event_available => _r.calendar_check;
  static IconData get event_available_outlined => _r.calendar_check;
  static IconData get event_available_rounded => _r.calendar_check;
  static IconData get event_busy => _r.calendar_exclamation;
  static IconData get event_busy_rounded => _r.calendar_exclamation;
  static IconData get event_note_rounded => _r.calendar_pen;
  static IconData get event_rounded => _r.calendar;
  static IconData get facebook => _b.facebook;
  static IconData get filter_alt_off => _r.filter_slash;
  static IconData get flag_outlined => _r.flag;
  static IconData get flag_rounded => _r.flag;
  static IconData get flash_on_rounded => _r.bolt;
  static IconData get folder_open_rounded => _r.folder;
  static IconData get forest => _r.camping;
  static IconData get grid_view_rounded => _r.grid;
  static IconData get help_rounded => _r.question;
  static IconData get history_rounded => _r.time_past;
  static IconData get home_rounded => _r.home;
  static IconData get image_outlined => _r.picture;
  static IconData get info => _r.info;
  static IconData get info_outline => _r.info;
  static IconData get info_outline_rounded => _r.info;
  static IconData get info_rounded => _r.info;
  static IconData get insights_rounded => _r.chart_line_up;
  static IconData get keyboard_arrow_down => _r.angle_small_down;
  static IconData get keyboard_arrow_down_rounded => _r.angle_small_down;
  static IconData get label => _r.label;
  static IconData get label_off_rounded => _r.label;
  static IconData get label_rounded => _r.label;
  static IconData get language_outlined => _r.globe;
  static IconData get language_rounded => _r.globe;
  static IconData get lightbulb_outline => _r.bulb;
  static IconData get link_off => _r.link_slash;
  static IconData get local_fire_department => _r.flame;
  static IconData get local_fire_department_rounded => _r.flame;
  static IconData get local_offer_outlined => _r.tags;
  static IconData get location_on_outlined => _r.map_marker;
  static IconData get lock_clock_rounded => _r.lock;
  static IconData get lock_outline => _r.lock;
  static IconData get lock_outline_rounded => _r.lock;
  static IconData get lock_reset_rounded => _r.key;
  static IconData get lock_rounded => _r.lock;
  static IconData get login => _r.sign_in_alt;
  static IconData get logout => _r.sign_out_alt;
  static IconData get logout_rounded => _r.sign_out_alt;
  static IconData get looks_one => _r.clock_one;
  static IconData get message_outlined => _r.comment;
  static IconData get mic => _r.microphone;
  static IconData get mic_filled => _s.microphone;
  static IconData get mic_off_rounded => _r.ban;
  static IconData get mic_rounded => _r.microphone;
  static IconData get more_horiz_rounded => _r.menu_dots;
  static IconData get more_vert => _r.menu_dots_vertical;
  static IconData get music_note => _r.music;
  static IconData get note_add_outlined => _r.add_document;
  static IconData get note_add_rounded => _r.add_document;
  static IconData get note_alt_outlined => _r.notebook;
  static IconData get note_alt_rounded => _r.notebook;
  static IconData get notes_rounded => _r.notebook;
  static IconData get notification_important => _r.alarm_exclamation;
  static IconData get notifications_active => _r.bell_ring;
  static IconData get notifications_active_outlined => _r.bell;
  static IconData get notifications_active_rounded => _r.bell_ring;
  static IconData get notifications_off_outlined => _r.bell;
  static IconData get notifications_outlined => _r.bell;
  static IconData get notifications_rounded => _r.bell;
  static IconData get palette_outlined => _r.palette;
  static IconData get pending_actions_rounded => _r.hourglass;
  static IconData get pending_rounded => _r.hourglass;
  static IconData get percent_rounded => _r.badge_percent;
  static IconData get person => _r.user;
  static IconData get person_outline => _r.user;
  static IconData get person_outline_rounded => _r.user;
  static IconData get person_rounded => _r.user;
  static IconData get phone_outlined => _r.smartphone;
  static IconData get play_arrow_rounded => _r.play;
  static IconData get privacy_tip_outlined => _r.shield;
  static IconData get public_outlined => _r.world;
  static IconData get push_pin_outlined => _r.thumbtack;
  static IconData get refresh => _r.refresh;
  static IconData get refresh_rounded => _r.refresh;
  static IconData get repeat => _r.arrows_repeat;
  static IconData get rocket_launch_outlined => _r.rocket;
  static IconData get schedule_rounded => _r.calendar_clock;
  static IconData get search_off_rounded => _r.search;
  static IconData get search_rounded => _r.search;
  static IconData get settings => _r.settings;
  static IconData get settings_outlined => _r.settings;
  static IconData get settings_rounded => _r.settings;
  static IconData get share_outlined => _r.share;
  static IconData get shield_rounded => _r.shield;
  static IconData get snooze => _r.alarm_snooze;
  static IconData get stars_rounded => _r.stars;
  static IconData get sticky_note_2_outlined => _r.notebook;
  static IconData get stop_rounded => _r.stop;
  static IconData get summarize => _r.document;
  static IconData get swipe_left_rounded => _r.hand;
  static IconData get tag => _r.tags;
  static IconData get task_alt => _r.clipboard_list_check;
  static IconData get task_alt_outlined => _r.clipboard_list_check;
  static IconData get task_alt_rounded => _r.clipboard_list_check;
  static IconData get text_fields => _r.text;
  static IconData get text_fields_rounded => _r.text;
  static IconData get timer => _r.stopwatch;
  static IconData get timer_outlined => _r.stopwatch;
  static IconData get timer_rounded => _r.stopwatch;
  static IconData get tips_and_updates_rounded => _r.bulb;
  static IconData get title => _r.text;
  static IconData get today => _r.calendar;
  static IconData get today_outlined => _r.calendar;
  static IconData get today_rounded => _r.calendar;
  static IconData get transcribe_rounded => _r.subtitles;
  static IconData get trending_up_rounded => _r.arrow_trend_up;
  static IconData get upcoming_rounded => _r.time_forward;
  static IconData get video_call => _r.video_camera;
  static IconData get video_call_outlined => _r.video_camera;
  static IconData get video_call_rounded => _r.video_camera;
  static IconData get videocam_rounded => _r.video_camera;
  static IconData get view_list_rounded => _r.list;
  static IconData get visibility => _r.eye;
  static IconData get visibility_off => _r.eye_crossed;
  static IconData get visibility_off_rounded => _r.eye_crossed;
  static IconData get visibility_rounded => _r.eye;
  static IconData get volume_off => _r.ban;
  static IconData get warning_amber => _r.triangle;
  static IconData get warning_amber_rounded => _r.exclamation;
  static IconData get warning_rounded => _r.triangle;
  static IconData get water_drop => _r.water;
  static IconData get waves => _r.water;
  static IconData get widgets_outlined => _r.apps;
  static IconData get widgets_rounded => _r.apps;
  static IconData get wifi_off_rounded => _r.signal_alt_1;
}
