import SwiftUI
import WidgetKit

private let widgetGroupId = "group.com.example.voclio_app"

private let purple = Color(red: 0.49, green: 0.36, blue: 0.99)
private let green = Color(red: 0.20, green: 0.78, blue: 0.35)
private let ink = Color(red: 0.07, green: 0.09, blue: 0.15)
private let inkMuted = Color(red: 0.61, green: 0.64, blue: 0.69)

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

struct WidgetGlassBackground: View {
  var body: some View {
    ZStack {
      LinearGradient(
        colors: [
          Color(red: 0.93, green: 0.94, blue: 0.99),
          Color(red: 0.86, green: 0.88, blue: 0.97),
          purple.opacity(0.14),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      Rectangle().fill(.ultraThinMaterial)
      LinearGradient(
        colors: [Color.white.opacity(0.42), Color.clear],
        startPoint: .topLeading,
        endPoint: .center
      )
    }
  }
}

struct VoclioWidgetProvider: TimelineProvider {
  func placeholder(in context: Context) -> VoclioWidgetEntry {
    sampleEntry()
  }

  func getSnapshot(in context: Context, completion: @escaping (VoclioWidgetEntry) -> Void) {
    if context.isPreview {
      completion(sampleEntry())
      return
    }
    completion(loadEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<VoclioWidgetEntry>) -> Void) {
    let entry = loadEntry()
    let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
    completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
  }

  private func sampleEntry() -> VoclioWidgetEntry {
    VoclioWidgetEntry(
      date: Date(),
      monthLabel: "June 2026",
      dayLabel: "Today",
      weekDays: [
        WeekDayItem(dow: "M", day: 9, today: false, tasks: 1, notes: 0),
        WeekDayItem(dow: "T", day: 10, today: false, tasks: 0, notes: 1),
        WeekDayItem(dow: "W", day: 11, today: false, tasks: 2, notes: 0),
        WeekDayItem(dow: "T", day: 12, today: false, tasks: 0, notes: 0),
        WeekDayItem(dow: "F", day: 13, today: true, tasks: 3, notes: 1),
        WeekDayItem(dow: "S", day: 14, today: false, tasks: 1, notes: 0),
        WeekDayItem(dow: "S", day: 15, today: false, tasks: 0, notes: 2),
      ],
      tasks: [
        WidgetListItem(title: "Review project plan", time: "9:00 AM"),
        WidgetListItem(title: "Team standup", time: "2:00 PM"),
      ],
      notes: [
        WidgetListItem(title: "Meeting notes", time: "Jun 13"),
      ]
    )
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
      case .systemLarge:
        largeLayout
      case .systemMedium:
        mediumLayout
      default:
        smallLayout
      }
    }
    .widgetURL(URL(string: "voclio://home"))
  }

  private var brandMark: some View {
    HStack(spacing: 6) {
      Image("VoclioLogo")
        .resizable()
        .scaledToFit()
        .frame(width: 20, height: 20)
      Text("Voclio")
        .font(.system(size: 13, weight: .bold))
        .foregroundColor(purple)
    }
  }

  private var header: some View {
    HStack {
      brandMark
      Text(entry.monthLabel)
        .font(.system(size: 12))
        .foregroundColor(inkMuted)
        .lineLimit(1)
        .padding(.leading, 4)
      Spacer()
      Text(entry.dayLabel)
        .font(.system(size: 12, weight: .semibold))
        .foregroundColor(ink)
        .lineLimit(1)
    }
  }

  private var weekStrip: some View {
    let days = entry.weekDays.isEmpty ? placeholderWeekDays() : entry.weekDays
    return HStack(spacing: 4) {
      ForEach(Array(days.enumerated()), id: \.offset) { _, day in
        VStack(spacing: 3) {
          Text(day.dow)
            .font(.system(size: 10))
            .foregroundColor(inkMuted)
          Text("\(day.day)")
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(day.today ? .white : ink)
            .frame(width: 28, height: 28)
            .background(dayCircle(for: day.today))
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

  private func dayCircle(for isToday: Bool) -> some View {
    Circle()
      .fill(isToday ? purple.opacity(0.88) : Color.white.opacity(0.38))
      .overlay(
        Circle()
          .stroke(
            isToday ? purple.opacity(0.55) : Color.white.opacity(0.62),
            lineWidth: 1
          )
      )
  }

  private func glassPanel(accent: Color) -> some View {
    RoundedRectangle(cornerRadius: 10, style: .continuous)
      .fill(Color.white.opacity(0.42))
      .overlay(
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .stroke(Color.white.opacity(0.68), lineWidth: 0.5)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .fill(accent.opacity(0.08))
      )
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
        .fill(Color.white.opacity(0.35))
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
    .background(glassPanel(accent: accent))
  }

  private var mediumLayout: some View {
    VStack(alignment: .leading, spacing: 8) {
      header
      weekStrip
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

  private var largeLayout: some View {
    VStack(alignment: .leading, spacing: 10) {
      header
      weekStrip
      Rectangle()
        .fill(Color.white.opacity(0.35))
        .frame(height: 1)
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
      .background(
        Capsule()
          .fill(Color.white.opacity(0.45))
          .overlay(Capsule().stroke(Color.white.opacity(0.65), lineWidth: 0.5))
          .overlay(Capsule().fill(color.opacity(0.12)))
      )
  }

  private func placeholderWeekDays() -> [WeekDayItem] {
    let calendar = Calendar.current
    let today = Date()
    let monday = calendar.date(
      from: calendar.dateComponents(
        [.yearForWeekOfYear, .weekOfYear],
        from: today
      )
    ) ?? today

    return (0..<7).compactMap { offset in
      guard let date = calendar.date(byAdding: .day, value: offset, to: monday) else {
        return nil
      }
      let formatter = DateFormatter()
      formatter.dateFormat = "EEEEE"
      return WeekDayItem(
        dow: formatter.string(from: date),
        day: calendar.component(.day, from: date),
        today: calendar.isDate(date, inSameDayAs: today),
        tasks: 0,
        notes: 0
      )
    }
  }
}

@main
struct VoclioWidget: Widget {
  let kind: String = "VoclioWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: VoclioWidgetProvider()) { entry in
      if #available(iOSApplicationExtension 17.0, *) {
        VoclioWidgetEntryView(entry: entry)
          .containerBackground(for: .widget) {
            WidgetGlassBackground()
          }
      } else {
        VoclioWidgetEntryView(entry: entry)
          .background(WidgetGlassBackground())
      }
    }
    .configurationDisplayName("Voclio")
    .description("Calendar, tasks, and notes at a glance.")
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
  }
}
