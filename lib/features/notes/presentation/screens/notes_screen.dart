import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';
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
      create: (_) => GetIt.I<NotesCubit>()..init(),
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
  String? _selectedTagName; // null = All

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
                          Row(
                            children: [
                              Text("Notes", style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              )),
                              SizedBox(width: 8.w),
                              Icon(
                                Icons.note_alt_rounded,
                                size: 22.sp,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          BlocBuilder<NotesCubit, NotesState>(
                            builder: (context, state) {
                              final totalWords = state.notes.fold<int>(
                                0,
                                (sum, note) => sum + note.content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length,
                              );
                              return Text(
                                "${state.notes.length} notes • ${_formatNumber(totalWords)} words",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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
                      ),
                ],
              ),

              SizedBox(height: 20.h),

              // 2. Search Bar
              TextField(
                    onChanged: (val) {
                      setState(() => _searchQuery = val);
                      // Trigger server-side search
                      // Debounce could be added here for better performance
                      context.read<NotesCubit>().getNotes(search: val);
                    },
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
                  ),

              SizedBox(height: 20.h),

              // 3. Filter Chips
              BlocBuilder<NotesCubit, NotesState>(
                builder: (context, state) {
                  return SizedBox(
                        height: 40.h,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildFilterChip("All", null),
                            ...state.availableTags.map(
                              (tagEntity) => _buildFilterChip(
                                tagEntity.name,
                                tagEntity.name,
                              ),
                            ),
                          ],
                        ),
                      );
                },
              ),

              SizedBox(height: 20.h),

              // Top Loading Indicator
              BlocBuilder<NotesCubit, NotesState>(
                builder: (context, state) {
                  if (state.status == NotesStatus.loading &&
                      state.notes.isNotEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child:
                          LinearProgressIndicator(
                            minHeight: 2.h,
                            backgroundColor: theme.colorScheme.primary
                                .withOpacity(0.1),
                            color: theme.colorScheme.primary,
                          ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // 4. Notes List/Grid
              Expanded(
                child: BlocListener<NotesCubit, NotesState>(
                  listenWhen:
                      (previous, current) => previous.status != current.status,
                  listener: (context, state) {
                    if (state.status == NotesStatus.failure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage),
                          backgroundColor: theme.colorScheme.error,
                        ),
                      );
                    }
                  },
                  child: BlocBuilder<NotesCubit, NotesState>(
                    builder: (context, state) {
                      if (state.status == NotesStatus.loading &&
                          state.notes.isEmpty) {
                        return _buildLoadingState(context, theme);
                      }

                      if (state.status == NotesStatus.failure &&
                          state.notes.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: theme.colorScheme.error,
                                size: 48.r,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                state.errorMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                              TextButton(
                                onPressed:
                                    () => context.read<NotesCubit>().getNotes(
                                      search: _searchQuery,
                                    ),
                                child: const Text("Retry"),
                              ),
                            ],
                          ),
                        );
                      }

                      // Filter Logic
                      final filteredNotes =
                          state.notes.where((note) {
                            // Search is now server-side, but we keep local filtering for tags
                            final matchesTag =
                                _selectedTagName == null ||
                                note.tags.contains(_selectedTagName);
                            return matchesTag;
                          }).toList();

                      if (filteredNotes.isEmpty) {
                        return RefreshIndicator(
                          onRefresh:
                              () => context.read<NotesCubit>().getNotes(
                                search: _searchQuery,
                              ),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: 80.h),
                              _buildEmptyState(context, theme),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh:
                            () => context.read<NotesCubit>().getNotes(
                              search: _searchQuery,
                            ),
                        child:
                            _isGridMode
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
                                    final double desiredCardHeight = 230.h;
                                    final double childAspectRatio =
                                        cardWidth / desiredCardHeight;

                                    return GridView.builder(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(
                                            parent: BouncingScrollPhysics(),
                                          ),
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
                                                key: ValueKey(filteredNotes[index].id),
                                                note: filteredNotes[index],
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (
                                                            _,
                                                          ) => BlocProvider.value(
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
                                              ),
                                    );
                                  },
                                )
                                : ListView.separated(
                                  physics: const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics(),
                                  ),
                                  itemCount: filteredNotes.length,
                                  padding: EdgeInsets.only(bottom: 100.h),

                                  separatorBuilder:
                                      (_, __) => SizedBox(height: 16.h),
                                  itemBuilder:
                                      (context, index) => NoteCard(
                                            key: ValueKey(filteredNotes[index].id),
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
                                          ),
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

  Widget _buildLoadingState(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
      children: [
        SizedBox(height: 40.h),
        // Shimmer-like loading cards
        ...List.generate(3, (index) {
          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: isDark
                  ? Border.all(color: Colors.white.withOpacity(0.05))
                  : Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 150.w,
                            height: 14.h,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            width: 80.w,
                            height: 10.h,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: 200.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          )
              .animate(
                onPlay: (controller) => controller.repeat(),
              )
              .shimmer(
                duration: 1500.ms,
                delay: Duration(milliseconds: 100 * index),
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.shade100,
              );
        }),
      ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? tagName) {
    final theme = Theme.of(context);
    final isSelected = _selectedTagName == tagName;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _selectedTagName = tagName),
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
              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final hasSearchOrFilter = _searchQuery.isNotEmpty || _selectedTagName != null;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration Container
          Container(
            width: 140.r,
            height: 140.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.15),
                  theme.colorScheme.secondary.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle decoration
                Positioned(
                  top: 20.r,
                  right: 20.r,
                  child: Container(
                    width: 30.r,
                    height: 30.r,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Main icon
                Icon(
                  hasSearchOrFilter
                      ? Icons.search_off_rounded
                      : Icons.note_alt_outlined,
                  size: 64.sp,
                  color: theme.colorScheme.primary.withOpacity(0.7),
                ),
                // Small floating elements
                Positioned(
                  bottom: 25.r,
                  left: 20.r,
                  child: Icon(
                    Icons.edit_note_rounded,
                    size: 24.sp,
                    color: theme.colorScheme.secondary.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

          SizedBox(height: 32.h),

          // Title
          Text(
            hasSearchOrFilter
                ? "No matching notes"
                : "Start capturing your ideas",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideY(begin: 0.3, end: 0),

          SizedBox(height: 12.h),

          // Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              hasSearchOrFilter
                  ? "Try adjusting your search or filters to find what you're looking for"
                  : "Create your first note to organize thoughts, ideas, and important information",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 300.ms)
                .slideY(begin: 0.3, end: 0),
          ),

          SizedBox(height: 32.h),

          // CTA Button
          if (!hasSearchOrFilter)
            ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => BlocProvider.value(
                    value: context.read<NotesCubit>(),
                    child: const AddNoteBottomSheet(),
                  ),
                );
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text("Create Note"),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                elevation: 0,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .slideY(begin: 0.3, end: 0)
          else
            // Clear filters button
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedTagName = null;
                });
                context.read<NotesCubit>().getNotes();
              },
              icon: Icon(Icons.clear_all, size: 20.sp),
              label: const Text("Clear Filters"),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 400.ms),

          SizedBox(height: 16.h),

          // Quick tips
          if (!hasSearchOrFilter)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40.w),
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : theme.colorScheme.primary.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 20.sp,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      "Tip: Use tags to organize notes by topics or projects",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 500.ms)
                .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
