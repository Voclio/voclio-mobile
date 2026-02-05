package com.example.voclio_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import android.view.View
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject

class VoclioWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Called when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Called when the last widget is removed
    }

    companion object {
        private const val PREFS_NAME = "HomeWidgetPreferences"
        
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.voclio_widget)

            // Get tasks data from SharedPreferences
            val tasksJson = widgetData.getString("tasks", "[]")
            val title = widgetData.getString("widget_title", "Today's Tasks")
            
            views.setTextViewText(R.id.widget_title, title)

            try {
                val tasks = JSONArray(tasksJson)
                val taskCount = tasks.length()
                
                views.setTextViewText(R.id.widget_count, taskCount.toString())
                
                // Show/hide task items based on data
                if (taskCount == 0) {
                    views.setViewVisibility(R.id.empty_state, View.VISIBLE)
                    views.setViewVisibility(R.id.task_item_1, View.GONE)
                    views.setViewVisibility(R.id.task_item_2, View.GONE)
                    views.setViewVisibility(R.id.task_item_3, View.GONE)
                } else {
                    views.setViewVisibility(R.id.empty_state, View.GONE)
                    
                    // Task 1
                    if (taskCount >= 1) {
                        val task1 = tasks.getJSONObject(0)
                        views.setViewVisibility(R.id.task_item_1, View.VISIBLE)
                        views.setTextViewText(R.id.task_1_title, task1.getString("title"))
                        views.setTextViewText(R.id.task_1_time, task1.optString("time", ""))
                    } else {
                        views.setViewVisibility(R.id.task_item_1, View.GONE)
                    }
                    
                    // Task 2
                    if (taskCount >= 2) {
                        val task2 = tasks.getJSONObject(1)
                        views.setViewVisibility(R.id.task_item_2, View.VISIBLE)
                        views.setTextViewText(R.id.task_2_title, task2.getString("title"))
                        views.setTextViewText(R.id.task_2_time, task2.optString("time", ""))
                    } else {
                        views.setViewVisibility(R.id.task_item_2, View.GONE)
                    }
                    
                    // Task 3
                    if (taskCount >= 3) {
                        val task3 = tasks.getJSONObject(2)
                        views.setViewVisibility(R.id.task_item_3, View.VISIBLE)
                        views.setTextViewText(R.id.task_3_title, task3.getString("title"))
                        views.setTextViewText(R.id.task_3_time, task3.optString("time", ""))
                    } else {
                        views.setViewVisibility(R.id.task_item_3, View.GONE)
                    }
                }
            } catch (e: Exception) {
                // Show empty state on error
                views.setViewVisibility(R.id.empty_state, View.VISIBLE)
                views.setViewVisibility(R.id.task_item_1, View.GONE)
                views.setViewVisibility(R.id.task_item_2, View.GONE)
                views.setViewVisibility(R.id.task_item_3, View.GONE)
                views.setTextViewText(R.id.widget_count, "0")
            }

            // Set up click to open app
            val intent = Intent(context, MainActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
