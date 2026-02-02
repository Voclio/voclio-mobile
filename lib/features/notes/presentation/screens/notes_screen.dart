import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';
import 'package:voclio_app/core/enums/enums.dart'; // Adjust path
import 'package:voclio_app/features/notes/presentation/bloc/note_state.dart';
import 'package:voclio_app/features/notes/presentation/screens/note_details_screen.dart';
import 'package:voclio_app/features/notes/presentation/widgets/add_note_bottom_sheet.dart';
import '../bloc/notes_cubit.dart';
import '../widgets/note_card.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<NotesCubit>()..getNotes(),
      child: const _NotesDashboardView(),
    );
  }
}

class _NotesDashboardView extends StatefulWidget {
  const _NotesDashboardView();

  @override
  State<_NotesDashboardView> createState() => _NotesDashboardViewState();
}

class _NotesDashboardViewState extends State<_NotesDashboardView> {
  bool _isGridMode = false; // Toggle state
  String _searchQuery = '';
  AppTag? _selectedTag; // null = All

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              // 1. Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Notes", style: theme.textTheme.headlineSmall),
                          BlocBuilder<NotesCubit, NotesState>(
                            builder: (context, state) {
                              return Text(
                                "${state.notes.length} total notes",
                                style: theme.textTheme.bodyMedium,
                              );
                            },
                          ),
                        ],
                      )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),
                  // Grid/List Toggle
                  Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.list),
                              color:
                                  !_isGridMode
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.secondary,
                              onPressed:
                                  () => setState(() => _isGridMode = false),
                            ),
                            IconButton(
                              icon: const Icon(Icons.grid_view),
                              color:
                                  _isGridMode
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.secondary,
                              onPressed:
                                  () => setState(() => _isGridMode = true),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 100.ms)
                      .scale(begin: const Offset(0.8, 0.8)),
                ],
              ),

              SizedBox(height: 20.h),

              // 2. Search Bar
              TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: "Search notes...",
                      hintStyle: TextStyle(color: theme.colorScheme.secondary),
                      prefixIcon: Icon(
                        Icons.search,
                        color: theme.colorScheme.secondary,
                      ),
                      filled: true,
                      fillColor:
                          isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .slideY(begin: 0.2, end: 0),

              SizedBox(height: 20.h),

              // 3. Filter Chips
              SizedBox(
                    height: 40.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip("All ", null),
                        ...AppTag.values.map(
                          (tag) => _buildFilterChip(tag.label, tag),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 300.ms)
                  .slideX(begin: -0.2, end: 0),

              SizedBox(height: 20.h),

              // 4. Notes List/Grid
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context.read<NotesCubit>().getNotes(),
                  child: BlocBuilder<NotesCubit, NotesState>(
                    builder: (context, state) {
                      if (state.status == NotesStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Filter Logic
                      final filteredNotes =
                          state.notes.where((note) {
                            final matchesSearch =
                                note.title.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ) ||
                                note.content.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                );
                            final matchesTag =
                                _selectedTag == null ||
                                note.tags.contains(_selectedTag);
                            return matchesSearch && matchesTag;
                          }).toList();

                      if (filteredNotes.isEmpty) {
                        return Center(
                          child: Text(
                            "No notes found",
                            style: theme.textTheme.bodyMedium,
                          ),
                        );
                      }

                      return _isGridMode
                          ? Builder(
                            builder: (context) {
                              // 1. Calculate dynamic aspect ratio
                              // We want the card to have a fixed height (e.g., 200.h) regardless of width
                              // Formula: Ratio = Width / DesiredHeight

                              final double screenWidth =
                                  MediaQuery.of(context).size.width;
                              // Total Horizontal Padding = 20.w (left) + 20.w (right) + 16.w (middle gap)
                              final double totalPadding = 56.w;
                              final double cardWidth =
                                  (screenWidth - totalPadding) / 2;

                              // Adjust this value (210.h) until your content fits perfectly
                              final double desiredCardHeight = 210.h;
                              final double childAspectRatio =
                                  cardWidth / desiredCardHeight;

                              return GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.only(bottom: 100.h),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16.w,
                                      mainAxisSpacing: 16.h,
                                      // 2. Use the calculated ratio
                                      childAspectRatio: childAspectRatio,
                                    ),
                                itemCount: filteredNotes.length,
                                itemBuilder:
                                    (context, index) => NoteCard(
                                          note: filteredNotes[index],
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => BlocProvider.value(
                                                      value:
                                                          context
                                                              .read<
                                                                NotesCubit
                                                              >(),
                                                      child: NoteDetailScreen(
                                                        note:
                                                            filteredNotes[index],
                                                      ),
                                                    ),
                                              ),
                                            );
                                          },
                                        )
                                        .animate()
                                        .fadeIn(
                                          duration: 400.ms,
                                          delay: Duration(
                                            milliseconds: 50 * index,
                                          ),
                                        )
                                        .slideY(
                                          begin: 0.2,
                                          end: 0,
                                          duration: 400.ms,
                                          delay: Duration(
                                            milliseconds: 50 * index,
                                          ),
                                        ),
                              );
                            },
                          )
                          // ... existing list view code ...
                          : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: filteredNotes.length,
                            padding: EdgeInsets.only(bottom: 100.h),

                            separatorBuilder: (_, __) => SizedBox(height: 16.h),
                            itemBuilder:
                                (context, index) => NoteCard(
                                      note: filteredNotes[index],
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => BlocProvider.value(
                                                  value:
                                                      context
                                                          .read<NotesCubit>(),

                                                  child: NoteDetailScreen(
                                                    note: filteredNotes[index],
                                                  ),
                                                ),
                                          ),
                                        );
                                      }, // Todo: Navigate to details
                                    )
                                    .animate()
                                    .fadeIn(
                                      duration: 400.ms,
                                      delay: Duration(milliseconds: 50 * index),
                                    )
                                    .slideY(
                                      begin: 0.2,
                                      end: 0,
                                      duration: 400.ms,
                                      delay: Duration(milliseconds: 50 * index),
                                    ),
                          );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 85.h),
        child: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true, // Required for full height
              backgroundColor:
                  Colors.transparent, // Required for rounded corners
              builder:
                  (_) => BlocProvider.value(
                    value: context.read<NotesCubit>(), // Pass the Cubit
                    child: const AddNoteBottomSheet(),
                  ),
            );
          },
          backgroundColor: theme.colorScheme.primary,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, AppTag? tag) {
    final theme = Theme.of(context);
    final isSelected = _selectedTag == tag;
    final isDark = theme.brightness == Brightness.dark;

    return label == 'All'
        ? SizedBox.shrink()
        : GestureDetector(
          onTap: () => setState(() => _selectedTag = tag),
          child: Container(
            margin: EdgeInsets.only(right: 10.w),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? theme.colorScheme.primary
                      : (isDark ? Colors.transparent : Colors.white),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color:
                    isSelected
                        ? theme.colorScheme.primary
                        : (isDark ? Colors.white24 : Colors.grey.shade300),
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color:
                      isSelected ? Colors.white : theme.colorScheme.onSurface,
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
  }
}
