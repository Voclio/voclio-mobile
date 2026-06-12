import 'package:translator/translator.dart';

/// Normalizes Arabic API text to English for an English-only app.
class ApiArabicToEnglish {
  ApiArabicToEnglish._();

  static final RegExp _arabic = RegExp(r'[\u0600-\u06FF]');
  static final GoogleTranslator _translator = GoogleTranslator();
  static final Map<String, String> _cache = {};

  static bool containsArabic(String text) => _arabic.hasMatch(text);

  static Future<dynamic> localizeJson(dynamic value) async {
    if (value is String) {
      return localizeString(value);
    }
    if (value is List) {
      final localized = <dynamic>[];
      for (final item in value) {
        localized.add(await localizeJson(item));
      }
      return localized;
    }
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      final processedTextKeys = <String>{};

      if (map['title'] is String && map['message'] is String) {
        var title = map['title'] as String;
        var message = map['message'] as String;
        final pair = localizeNotificationCopy(title, message);
        title = pair.$1;
        message = pair.$2;
        if (containsArabic(title)) {
          title = await localizeString(title);
        }
        if (containsArabic(message)) {
          message = await localizeString(message);
        }
        map['title'] = title;
        map['message'] = message;
        processedTextKeys.addAll({'title', 'message'});
      }

      final result = <String, dynamic>{};
      for (final entry in map.entries) {
        final key = entry.key.toString();
        if (_shouldSkipKey(key)) {
          result[key] = entry.value;
          continue;
        }
        if (processedTextKeys.contains(key)) {
          result[key] = entry.value;
          continue;
        }
        if (entry.value is String) {
          result[key] = await localizeString(entry.value as String);
          continue;
        }
        result[key] = await localizeJson(entry.value);
      }
      return result;
    }
    return value;
  }

  static Future<String> localizeString(String text) async {
    if (text.isEmpty || !containsArabic(text)) {
      return text;
    }

    final cached = _cache[text];
    if (cached != null) {
      return cached;
    }

    final known = _knownExactPhrases[text];
    if (known != null) {
      _cache[text] = known;
      return known;
    }

    try {
      final translated = await _translator.translate(text, from: 'ar', to: 'en');
      final result = translated.text.trim().isEmpty ? text : translated.text;
      _cache[text] = result;
      return result;
    } catch (_) {
      return text;
    }
  }

  static (String title, String message) localizeNotificationCopy(
    String title,
    String message,
  ) {
    final localizedTitle = _notificationTitleToEnglish[title] ?? title;
    final type = _arabicTitleToType[title];
    if (type == null) {
      return (localizedTitle, message);
    }

    final parser = _notificationMessageParsers[type];
    if (parser != null) {
      final match = parser.pattern.firstMatch(message);
      if (match != null) {
        return (localizedTitle, parser.toEnglish(match));
      }
    }

    final staticEnglish = _notificationStaticEnglish[type];
    if (staticEnglish != null &&
        _notificationStaticArabic[type] == message) {
      return (localizedTitle, staticEnglish);
    }

    return (localizedTitle, message);
  }

  static bool _shouldSkipKey(String key) {
    final lower = key.toLowerCase();
    const skipKeys = {
      'name',
      'full_name',
      'fullname',
      'email',
      'password',
      'token',
      'access_token',
      'refresh_token',
      'avatar',
      'image',
      'photo',
      'url',
      'language',
      'locale',
      'timezone',
    };
    if (skipKeys.contains(lower)) return true;
    if (lower.endsWith('_id') || lower == 'id') return true;
    return false;
  }

  static const Map<String, String> _knownExactPhrases = {
    'بدون عنوان': 'Untitled',
    'لديك تذكير': 'You have a reminder',
    'تم إنشاء تذكير جديد': 'A new reminder was created',
    'تم تحويل التسجيل الصوتي إلى نص بنجاح':
        'Your voice recording was transcribed successfully',
    'تم تغيير كلمة المرور الخاصة بك بنجاح':
        'Your password was changed successfully',
    'تم تأكيد بريدك الإلكتروني بنجاح':
        'Your email address was verified successfully',
  };

  static const Map<String, String> _notificationTitleToEnglish = {
    'مهمة جديدة': 'New task',
    'تحديث مهمة': 'Task updated',
    '✅ مهمة مكتملة': '✅ Task completed',
    '⏰ موعد المهمة قريب': '⏰ Task due soon',
    '⚠️ مهمة متأخرة': '⚠️ Overdue task',
    '🔔 تذكير': '🔔 Reminder',
    'تذكير جديد': 'New reminder',
    '📝 ملاحظة جديدة': '📝 New note',
    '🎤 تم معالجة التسجيل الصوتي': '🎤 Voice recording processed',
    '✨ تم إنشاء مهمة من الصوت': '✨ Task created from voice',
    '🏆 إنجاز جديد!': '🏆 New achievement!',
    '🔥 سلسلة إنجازات!': '🔥 Streak milestone!',
    '⏱️ جلسة تركيز مكتملة': '⏱️ Focus session complete',
    '👋 مرحباً بك في Voclio': '👋 Welcome to Voclio',
    '🔒 تم تغيير كلمة المرور': '🔒 Password changed',
    '✅ تم تأكيد البريد الإلكتروني': '✅ Email verified',
  };

  static final Map<String, String> _arabicTitleToType = {
    for (final entry in _notificationTitleToEnglish.entries)
      entry.key: _notificationTypeForEnglishTitle(entry.value),
  };

  static String _notificationTypeForEnglishTitle(String englishTitle) {
    return switch (englishTitle) {
      'New task' => 'taskCreated',
      'Task updated' => 'taskUpdated',
      '✅ Task completed' => 'taskCompleted',
      '⏰ Task due soon' => 'taskDueSoon',
      '⚠️ Overdue task' => 'taskOverdue',
      '🔔 Reminder' => 'reminderTriggered',
      'New reminder' => 'reminderCreated',
      '📝 New note' => 'noteCreated',
      '🎤 Voice recording processed' => 'voiceProcessed',
      '✨ Task created from voice' => 'voiceToTaskCreated',
      '🏆 New achievement!' => 'achievementEarned',
      '🔥 Streak milestone!' => 'streakMilestone',
      '⏱️ Focus session complete' => 'focusSessionCompleted',
      '👋 Welcome to Voclio' => 'welcome',
      '🔒 Password changed' => 'passwordChanged',
      '✅ Email verified' => 'emailVerified',
      _ => 'unknown',
    };
  }

  static const Map<String, String> _notificationStaticArabic = {
    'reminderTriggered': 'لديك تذكير',
    'reminderCreated': 'تم إنشاء تذكير جديد',
    'voiceProcessed': 'تم تحويل التسجيل الصوتي إلى نص بنجاح',
    'passwordChanged': 'تم تغيير كلمة المرور الخاصة بك بنجاح',
    'emailVerified': 'تم تأكيد بريدك الإلكتروني بنجاح',
  };

  static const Map<String, String> _notificationStaticEnglish = {
    'reminderTriggered': 'You have a reminder',
    'reminderCreated': 'A new reminder was created',
    'voiceProcessed': 'Your voice recording was transcribed successfully',
    'passwordChanged': 'Your password was changed successfully',
    'emailVerified': 'Your email address was verified successfully',
  };

  static final Map<String, _NotificationMessageParser> _notificationMessageParsers =
      {
        'taskCreated': _NotificationMessageParser(
          RegExp(r'^تم إنشاء مهمة جديدة: (.+)$'),
          (m) => 'A new task was created: ${m.group(1)}',
        ),
        'taskUpdated': _NotificationMessageParser(
          RegExp(r'^تم تحديث المهمة: (.+)$'),
          (m) => 'Task updated: ${m.group(1)}',
        ),
        'taskCompleted': _NotificationMessageParser(
          RegExp(r'^أحسنت! تم إكمال المهمة: (.+)$'),
          (m) => 'Nice work! You completed: ${m.group(1)}',
        ),
        'taskDueSoon': _NotificationMessageParser(
          RegExp(r'^المهمة "(.+)" موعدها بعد (\d+) ساعة$'),
          (m) {
            final hours = int.parse(m.group(2)!);
            final label = hours == 1 ? '1 hour' : '$hours hours';
            return 'Task "${m.group(1)}" is due in $label';
          },
        ),
        'taskOverdue': _NotificationMessageParser(
          RegExp(r'^المهمة "(.+)" تجاوزت موعدها$'),
          (m) => 'Task "${m.group(1)}" is past its due date',
        ),
        'reminderTriggered': _NotificationMessageParser(
          RegExp(r'^تذكير بالمهمة: (.+)$'),
          (m) => 'Reminder for task: ${m.group(1)}',
        ),
        'noteCreated': _NotificationMessageParser(
          RegExp(r'^تم إنشاء ملاحظة: (.+)$'),
          (m) {
            final title = m.group(1)!;
            final display = title == 'بدون عنوان' ? 'Untitled' : title;
            return 'Note created: $display';
          },
        ),
        'voiceToTaskCreated': _NotificationMessageParser(
          RegExp(r'^تم إنشاء المهمة: (.+)$'),
          (m) => 'Task created: ${m.group(1)}',
        ),
        'achievementEarned': _NotificationMessageParser(
          RegExp(r'^تهانينا! حصلت على: (.+)$'),
          (m) => 'Congratulations! You earned: ${m.group(1)}',
        ),
        'streakMilestone': _NotificationMessageParser(
          RegExp(r'^رائع! وصلت إلى (\d+) يوم متتالي$'),
          (m) => 'Amazing! You reached a ${m.group(1)}-day streak',
        ),
        'focusSessionCompleted': _NotificationMessageParser(
          RegExp(r'^أحسنت! أكملت جلسة تركيز لمدة (\d+) دقيقة$'),
          (m) {
            final minutes = int.parse(m.group(1)!);
            final label = minutes == 1 ? '1 minute' : '$minutes minutes';
            return 'Great job! You finished a $label focus session';
          },
        ),
        'welcome': _NotificationMessageParser(
          RegExp(r'^أهلاً (.+)! نحن سعداء بانضمامك$'),
          (m) => "Hi ${m.group(1)}! We're glad you're here",
        ),
      };
}

class _NotificationMessageParser {
  const _NotificationMessageParser(this.pattern, this.toEnglish);

  final RegExp pattern;
  final String Function(RegExpMatch match) toEnglish;
}
