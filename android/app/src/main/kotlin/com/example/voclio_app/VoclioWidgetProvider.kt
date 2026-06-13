package com.example.voclio_app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar

class VoclioWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId, widgetData)
        }
    }

    companion object {
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            widgetData: SharedPreferences
        ) {
            val views = RemoteViews(context.packageName, R.layout.voclio_widget)

            val monthLabel = widgetData.getString("month_label", "") ?: ""
            val dayLabel = widgetData.getString("widget_title", "Today") ?: "Today"
            var weekJson = widgetData.getString("week_days", "[]") ?: "[]"
            val tasksJson = widgetData.getString("tasks", "[]") ?: "[]"
            val notesJson = widgetData.getString("notes", "[]") ?: "[]"

            if (weekJson == "[]" || weekJson.isBlank()) {
                weekJson = placeholderWeekJson()
            }

            val effectiveMonth =
                if (monthLabel.isBlank()) placeholderMonthLabel() else monthLabel

            views.setTextViewText(R.id.widget_month, effectiveMonth)
            views.setTextViewText(R.id.widget_title, dayLabel)

            bindWeekStrip(views, weekJson)
            bindListSection(
                views,
                JSONArray(tasksJson),
                R.id.task_item_1_title,
                R.id.task_item_2_title,
                R.id.tasks_empty
            )
            bindListSection(
                views,
                JSONArray(notesJson),
                R.id.note_item_1_title,
                R.id.note_item_2_title,
                R.id.notes_empty
            )

            val pendingIntent =
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun placeholderMonthLabel(): String {
            val cal = Calendar.getInstance()
            val month = cal.getDisplayName(Calendar.MONTH, Calendar.LONG, java.util.Locale.getDefault())
            return "$month ${cal.get(Calendar.YEAR)}"
        }

        private fun placeholderWeekJson(): String {
            val cal = Calendar.getInstance()
            cal.firstDayOfWeek = Calendar.MONDAY
            val dayOfWeek = cal.get(Calendar.DAY_OF_WEEK)
            val daysFromMonday = (dayOfWeek + 5) % 7
            cal.add(Calendar.DAY_OF_MONTH, -daysFromMonday)

            val days = JSONArray()
            val dowLabels = arrayOf("M", "T", "W", "T", "F", "S", "S")
            val today = Calendar.getInstance()

            for (index in 0 until 7) {
                val day = JSONObject()
                day.put("dow", dowLabels[index])
                day.put("day", cal.get(Calendar.DAY_OF_MONTH))
                day.put(
                    "today",
                    cal.get(Calendar.YEAR) == today.get(Calendar.YEAR) &&
                        cal.get(Calendar.DAY_OF_YEAR) == today.get(Calendar.DAY_OF_YEAR)
                )
                day.put("tasks", 0)
                day.put("notes", 0)
                days.put(day)
                cal.add(Calendar.DAY_OF_MONTH, 1)
            }
            return days.toString()
        }

        private fun bindWeekStrip(views: RemoteViews, weekJson: String) {
            try {
                val days = JSONArray(weekJson)
                for (index in 0 until 7) {
                    val dowId = dayId("dow", index)
                    val numId = dayId("num", index)
                    val taskDotId = dayId("task_dot", index)
                    val noteDotId = dayId("note_dot", index)

                    if (index >= days.length()) {
                        views.setViewVisibility(taskDotId, View.GONE)
                        views.setViewVisibility(noteDotId, View.GONE)
                        continue
                    }

                    val day = days.getJSONObject(index)
                    views.setTextViewText(dowId, day.optString("dow", ""))
                    views.setTextViewText(numId, day.optInt("day", 0).toString())

                    val isToday = day.optBoolean("today", false)
                    views.setInt(
                        numId,
                        "setBackgroundResource",
                        if (isToday) R.drawable.widget_day_today else R.drawable.widget_day_default
                    )
                    views.setTextColor(
                        numId,
                        if (isToday) 0xFFFFFFFF.toInt() else 0xFF111827.toInt()
                    )

                    val hasTasks = day.optInt("tasks", 0) > 0
                    val hasNotes = day.optInt("notes", 0) > 0
                    views.setViewVisibility(
                        taskDotId,
                        if (hasTasks) View.VISIBLE else View.GONE
                    )
                    views.setViewVisibility(
                        noteDotId,
                        if (hasNotes) View.VISIBLE else View.GONE
                    )
                }
            } catch (_: Exception) {
                // Keep default week layout on parse errors.
            }
        }

        private fun bindListSection(
            views: RemoteViews,
            items: JSONArray,
            firstId: Int,
            secondId: Int,
            emptyId: Int
        ) {
            try {
                if (items.length() == 0) {
                    views.setViewVisibility(firstId, View.GONE)
                    views.setViewVisibility(secondId, View.GONE)
                    views.setViewVisibility(emptyId, View.VISIBLE)
                    return
                }

                views.setViewVisibility(emptyId, View.GONE)
                views.setViewVisibility(firstId, View.VISIBLE)
                val first = items.getJSONObject(0)
                views.setTextViewText(firstId, first.optString("title", ""))

                if (items.length() >= 2) {
                    views.setViewVisibility(secondId, View.VISIBLE)
                    val second = items.getJSONObject(1)
                    views.setTextViewText(secondId, second.optString("title", ""))
                } else {
                    views.setViewVisibility(secondId, View.GONE)
                }
            } catch (_: Exception) {
                views.setViewVisibility(firstId, View.GONE)
                views.setViewVisibility(secondId, View.GONE)
                views.setViewVisibility(emptyId, View.VISIBLE)
            }
        }

        private fun dayId(suffix: String, index: Int): Int {
            return when (suffix) {
                "dow" -> when (index) {
                    0 -> R.id.day_0_dow
                    1 -> R.id.day_1_dow
                    2 -> R.id.day_2_dow
                    3 -> R.id.day_3_dow
                    4 -> R.id.day_4_dow
                    5 -> R.id.day_5_dow
                    else -> R.id.day_6_dow
                }
                "num" -> when (index) {
                    0 -> R.id.day_0_num
                    1 -> R.id.day_1_num
                    2 -> R.id.day_2_num
                    3 -> R.id.day_3_num
                    4 -> R.id.day_4_num
                    5 -> R.id.day_5_num
                    else -> R.id.day_6_num
                }
                "task_dot" -> when (index) {
                    0 -> R.id.day_0_task_dot
                    1 -> R.id.day_1_task_dot
                    2 -> R.id.day_2_task_dot
                    3 -> R.id.day_3_task_dot
                    4 -> R.id.day_4_task_dot
                    5 -> R.id.day_5_task_dot
                    else -> R.id.day_6_task_dot
                }
                else -> when (index) {
                    0 -> R.id.day_0_note_dot
                    1 -> R.id.day_1_note_dot
                    2 -> R.id.day_2_note_dot
                    3 -> R.id.day_3_note_dot
                    4 -> R.id.day_4_note_dot
                    5 -> R.id.day_5_note_dot
                    else -> R.id.day_6_note_dot
                }
            }
        }
    }
}
