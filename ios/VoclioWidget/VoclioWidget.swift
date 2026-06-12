import SwiftUI
import WidgetKit

private let widgetGroupId = "group.com.example.voclio_app"

private let purple = Color(red: 0.49, green: 0.36, blue: 0.99)
private let green = Color(red: 0.20, green: 0.78, blue: 0.35)
private let ink = Color(red: 0.07, green: 0.09, blue: 0.15)
private let inkMuted = Color(red: 0.61, green: 0.64, blue: 0.69)
private let canvas = Color(red: 0.96, green: 0.97, blue: 0.98)

struct WeekDayItem: Codable {
  let dow: String
  let day: Int
  let today: Bool
  let tasks: Int
  let notes: Int
}

struct WidgetListItem: Codable {
  let title: String
  let time: String
}

struct VoclioWidgetEntry: TimelineEntry {
  let date: Date
  let monthLabel: String
  let dayLabel: String
  let weekDays: [WeekDayItem]
  let tasks: [WidgetListItem]
  let notes: [WidgetListItem]
}

struct VoclioWidgetProvider: TimelineProvider {
  func placeholder(in context: Context) -> VoclioWidgetEntry {
    VoclioWidgetEntry(
      date: Date(),
      monthLabel: "June 2026",
      dayLabel: "Today",
      weekDays: [],
      tasks: [],
      notes: []
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (VoclioWidgetEntry) -> Void) {
    completion(loadEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<VoclioWidgetEntry>) -> Void) {
    let entry = loadEntry()
    let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
    completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
  }

  private func loadEntry() -> VoclioWidgetEntry {
    let prefs = UserDefaults(suiteName: widgetGroupId)
    let monthLabel = prefs?.string(forKey: "month_label") ?? ""
    let dayLabel = prefs?.string(forKey: "widget_title") ?? "Today"
    let weekDays = decodeWeekDays(prefs?.string(forKey: "week_days"))
    let tasks = decodeListItems(prefs?.string(forKey: "tasks"))
    let notes = decodeListItems(prefs?.string(forKey: "notes"))

    return VoclioWidgetEntry(
      date: Date(),
      monthLabel: monthLabel,
      dayLabel: dayLabel,
      weekDays: weekDays,
      tasks: tasks,
      notes: notes
    )
  }

  private func decodeWeekDays(_ json: String?) -> [WeekDayItem] {
    guard let json, let data = json.data(using: .utf8),
          let items = try? JSONDecoder().decode([WeekDayItem].self, from: data) else {
      return []
    }
    return items
  }

  private func decodeListItems(_ json: String?) -> [WidgetListItem] {
    guard let json, let data = json.data(using: .utf8),
          let items = try? JSONDecoder().decode([WidgetListItem].self, from: data) else {
      return []
    }
    return items
  }
}

struct VoclioWidgetEntryView: View {
  var entry: VoclioWidgetEntry
  @Environment(\.widgetFamily) private var family

  var body: some View {
  Group {
    switch family {
    case .systemMedium, .systemLarge:
      mediumLayout
    default:
      smallLayout
    }
  }
  .widgetURL(URL(string: "voclio://home"))
  }

  private var header: some View {
    HStack {
      Text("Voclio")
        .font(.system(size: 13, weight: .bold))
        .foregroundColor(purple)
      Text(entry.monthLabel)
        .font(.system(size: 12))
        .foregroundColor(inkMuted)
        .lineLimit(1)
      Spacer()
      Text(entry.dayLabel)
        .font(.system(size: 12, weight: .semibold))
        .foregroundColor(ink)
        .lineLimit(1)
    }
  }

  private var weekStrip: some View {
    HStack(spacing: 4) {
      ForEach(Array(entry.weekDays.enumerated()), id: \.offset) { _, day in
        VStack(spacing: 3) {
          Text(day.dow)
            .font(.system(size: 10))
            .foregroundColor(inkMuted)
          Text("\(day.day)")
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(day.today ? .white : ink)
            .frame(width: 28, height: 28)
            .background(
              Circle()
                .fill(day.today ? purple : Color.clear)
                .overlay(
                  Circle()
                    .stroke(day.today ? purple : Color.clear, lineWidth: 1)
                )
            )
          HStack(spacing: 2) {
            if day.tasks > 0 {
              Circle().fill(purple).frame(width: 4, height: 4)
            }
            if day.notes > 0 {
              Circle().fill(green).frame(width: 4, height: 4)
            }
          }
          .frame(height: 6)
        }
        .frame(maxWidth: .infinity)
      }
    }
  }

  private var listsSection: some View {
    HStack(alignment: .top, spacing: 10) {
      VStack(alignment: .leading, spacing: 6) {
        Text("Tasks")
          .font(.system(size: 11, weight: .bold))
          .foregroundColor(purple)
        if entry.tasks.isEmpty {
          Text("No tasks today")
            .font(.system(size: 11))
            .foregroundColor(inkMuted)
        } else {
          ForEach(Array(entry.tasks.enumerated()), id: \.offset) { _, task in
            listRow(title: task.title, time: task.time, accent: purple)
          }
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      Rectangle()
        .fill(Color.black.opacity(0.06))
        .frame(width: 1)

      VStack(alignment: .leading, spacing: 6) {
        Text("Notes")
          .font(.system(size: 11, weight: .bold))
          .foregroundColor(green)
        if entry.notes.isEmpty {
          Text("No notes yet")
            .font(.system(size: 11))
            .foregroundColor(inkMuted)
        } else {
          ForEach(Array(entry.notes.enumerated()), id: \.offset) { _, note in
            listRow(title: note.title, time: note.time, accent: green)
          }
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private func listRow(title: String, time: String, accent: Color) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title)
        .font(.system(size: 12, weight: .semibold))
        .foregroundColor(ink)
        .lineLimit(2)
      Text(time)
        .font(.system(size: 10))
        .foregroundColor(inkMuted)
    }
    .padding(8)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(accent.opacity(0.08))
    )
  }

  private var mediumLayout: some View {
    VStack(alignment: .leading, spacing: 10) {
      header
      weekStrip
      Divider().opacity(0.15)
      listsSection
    }
    .padding(14)
  }

  private var smallLayout: some View {
    VStack(alignment: .leading, spacing: 8) {
      header
      if let today = entry.weekDays.first(where: { $0.today }) {
        HStack {
          Text("Today")
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(inkMuted)
          Spacer()
          if today.tasks > 0 {
            labelChip("\(today.tasks) tasks", color: purple)
          }
          if today.notes > 0 {
            labelChip("\(today.notes) notes", color: green)
          }
        }
      }
      if let firstTask = entry.tasks.first {
        listRow(title: firstTask.title, time: firstTask.time, accent: purple)
      } else if let firstNote = entry.notes.first {
        listRow(title: firstNote.title, time: firstNote.time, accent: green)
      } else {
        Text("Open Voclio to sync")
          .font(.system(size: 11))
          .foregroundColor(inkMuted)
      }
    }
    .padding(12)
  }

  private func labelChip(_ text: String, color: Color) -> some View {
    Text(text)
      .font(.system(size: 10, weight: .semibold))
      .foregroundColor(color)
      .padding(.horizontal, 6)
      .padding(.vertical, 2)
      .background(Capsule().fill(color.opacity(0.12)))
  }
}

@main
struct VoclioWidget: Widget {
  let kind: String = "VoclioWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: VoclioWidgetProvider()) { entry in
      if #available(iOSApplicationExtension 17.0, *) {
        VoclioWidgetEntryView(entry: entry)
          .containerBackground(.white, for: .widget)
      } else {
        VoclioWidgetEntryView(entry: entry)
          .background(Color.white)
      }
    }
    .configurationDisplayName("Voclio")
    .description("Calendar, tasks, and notes at a glance.")
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
  }
}
