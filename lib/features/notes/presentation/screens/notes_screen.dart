import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_widgets.dart';
import 'package:voclio_app/features/notes/presentation/bloc/note_state.dart';
import 'package:voclio_app/features/notes/presentation/screens/note_details_screen.dart';
import 'package:voclio_app/features/notes/presentation/widgets/add_note_bottom_sheet.dart';
import '../bloc/notes_cubit.dart';
import '../widgets/note_card.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

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

  void _showAddNoteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<NotesCubit>(),
        child: const AddNoteBottomSheet(),
      ),
    );
  }

  bool _isCompletelyEmpty(NotesState state) {
    return state.notes.isEmpty &&
        _searchQuery.isEmpty &&
        _selectedTagName == null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      primary: false,
      backgroundColor: HomeSystemTokens.canvas,
      body: HomeCanvas(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: BlocBuilder<NotesCubit, NotesState>(
              builder: (context, state) {
                final completelyEmpty = _isCompletelyEmpty(state);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),
                    _buildHeader(context, state),
                    if (!completelyEmpty) ...[
                      SizedBox(height: 18.h),
                      _buildStatsRow(state),
                      SizedBox(height: 16.h),
                      HomeSearchField(
                        hint: 'Search notes...',
                        onChanged: (val) {
                          setState(() => _searchQuery = val);
                          context.read<NotesCubit>().getNotes(search: val);
                        },
                      ),
                      SizedBox(height: 14.h),
                      _buildTagFilters(state),
                      SizedBox(height: 16.h),
                    ] else
                      SizedBox(height: 8.h),
                    if (state.status == NotesStatus.loading &&
                        state.notes.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: LinearProgressIndicator(
                          minHeight: 2.h,
                          backgroundColor:
                              theme.colorScheme.primary.withOpacity(0.1),
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    Expanded(
                      child: _buildNotesBody(context, theme, state),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, NotesState state) {
    final totalWords = state.notes.fold<int>(
      0,
      (sum, note) =>
          sum +
          note.content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length,
    );

    return HomeScreenHeader(
      title: 'Notes',
      subtitle: '${state.notes.length} notes · ${_formatNumber(totalWords)} words',
      icon: AppIcons.note_alt_rounded,
      accent: HomeSystemTokens.purple,
      actions: [
        HomeIconButton(
          icon: AppIcons.add_rounded,
          color: HomeSystemTokens.purple,
          onTap: () => _showAddNoteSheet(context),
        ),
        SizedBox(width: 8.w),
        HomeIconButton(
          icon: _isGridMode
              ? AppIcons.view_list_rounded
              : AppIcons.grid_view_rounded,
          color: HomeSystemTokens.inkSoft,
          onTap: () => setState(() => _isGridMode = !_isGridMode),
        ),
      ],
    );
  }

  Widget _buildStatsRow(NotesState state) {
    final totalWords = state.notes.fold<int>(
      0,
      (sum, note) =>
          sum +
          note.content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length,
    );
    final tagCount = state.availableTags.length;

    return Row(
      children: [
        Expanded(
          child: HomeStatTile(
            icon: AppIcons.folder_open_rounded,
            color: HomeSystemTokens.purple,
            label: 'Notes',
            value: state.notes.length.toString(),
            subtitle: 'Total saved',
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: HomeStatTile(
            icon: AppIcons.text_fields_rounded,
            color: HomeSystemTokens.purple,
            label: 'Words',
            value: _formatNumber(totalWords),
            subtitle: 'Written',
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: HomeStatTile(
            icon: AppIcons.local_offer_outlined,
            color: HomeSystemTokens.orange,
            label: 'Tags',
            value: tagCount.toString(),
            subtitle: 'Categories',
          ),
        ),
      ],
    );
  }

  Widget _buildTagFilters(NotesState state) {
    return SizedBox(
      height: 32.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          HomeCountedFilterPill(
            label: 'All',
            count: state.notes.length,
            selected: _selectedTagName == null,
            onTap: () => setState(() => _selectedTagName = null),
          ),
          ...state.availableTags.map(
            (tagEntity) => HomeCountedFilterPill(
              label: tagEntity.name,
              count: state.notes
                  .where((n) => n.tags.contains(tagEntity.name))
                  .length,
              selected: _selectedTagName == tagEntity.name,
              onTap: () => setState(() => _selectedTagName = tagEntity.name),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesBody(
    BuildContext context,
    ThemeData theme,
    NotesState state,
  ) {
    return BlocListener<NotesCubit, NotesState>(
      listenWhen: (previous, current) => previous.status != current.status,
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
          if (state.status == NotesStatus.loading && state.notes.isEmpty) {
            return _buildLoadingState(context, theme);
          }

          if (state.status == NotesStatus.failure && state.notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.error_outline,
                    color: theme.colorScheme.error,
                    size: 48.r,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    state.errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  TextButton(
                    onPressed: () => context.read<NotesCubit>().getNotes(
                      search: _searchQuery,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredNotes = state.notes.where((note) {
            final matchesTag =
                _selectedTagName == null ||
                note.tags.contains(_selectedTagName);
            return matchesTag;
          }).toList();

          if (filteredNotes.isEmpty) {
            final completelyEmpty = _isCompletelyEmpty(state);

            if (completelyEmpty) {
              return RefreshIndicator(
                onRefresh: () => context.read<NotesCubit>().getNotes(),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 96.h),
                          child: Center(
                            child: _buildEmptyState(
                              context,
                              theme,
                              compact: true,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<NotesCubit>().getNotes(
                search: _searchQuery,
              ),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 40.h),
                  _buildEmptyState(context, theme),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<NotesCubit>().getNotes(
              search: _searchQuery,
            ),
            child: _isGridMode
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = (constraints.maxWidth - 12.w) / 2;
                      final childAspectRatio = cardWidth / 168.h;

                      return GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.only(bottom: 100.h),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: filteredNotes.length,
                        itemBuilder: (context, index) => NoteCard(
                          key: ValueKey(filteredNotes[index].id),
                          note: filteredNotes[index],
                          compact: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<NotesCubit>(),
                                  child: NoteDetailScreen(
                                    note: filteredNotes[index],
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
                    separatorBuilder: (_, __) => SizedBox(height: 16.h),
                    itemBuilder: (context, index) => NoteCard(
                      key: ValueKey(filteredNotes[index].id),
                      note: filteredNotes[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<NotesCubit>(),
                              child: NoteDetailScreen(
                                note: filteredNotes[index],
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

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme, {
    bool compact = false,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final hasSearchOrFilter = _searchQuery.isNotEmpty || _selectedTagName != null;
    final illustrationSize = compact ? 108.r : 140.r;
    final mainIconSize = compact ? 52.sp : 64.sp;
    final sectionGap = compact ? 20.h : 32.h;
    final descGap = compact ? 8.h : 12.h;
    final actionGap = compact ? 20.h : 32.h;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: illustrationSize,
          height: illustrationSize,
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
              if (!compact)
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
              Icon(
                hasSearchOrFilter
                    ? AppIcons.search_off_rounded
                    : AppIcons.note_alt_outlined,
                size: mainIconSize,
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
              if (!compact)
                Positioned(
                  bottom: 25.r,
                  left: 20.r,
                  child: Icon(
                    AppIcons.edit_note_rounded,
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

        SizedBox(height: sectionGap),

        Text(
          hasSearchOrFilter
              ? 'No matching notes'
              : 'Start capturing your ideas',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: compact ? 20.sp : null,
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .slideY(begin: 0.3, end: 0),

        SizedBox(height: descGap),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 12.w : 40.w),
          child: Text(
            hasSearchOrFilter
                ? "Try adjusting your search or filters to find what you're looking for"
                : 'Create your first note to organize thoughts, ideas, and important information',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              height: 1.4,
              fontSize: compact ? 13.sp : null,
            ),
            textAlign: TextAlign.center,
            maxLines: compact ? 3 : null,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 300.ms)
            .slideY(begin: 0.3, end: 0),

        SizedBox(height: actionGap),

        if (!hasSearchOrFilter)
          ElevatedButton.icon(
            onPressed: () => _showAddNoteSheet(context),
            icon: Icon(AppIcons.add, size: compact ? 18 : 20),
            label: const Text('Create Note'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 22.w : 28.w,
                vertical: compact ? 12.h : 14.h,
              ),
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
          TextButton.icon(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _selectedTagName = null;
              });
              context.read<NotesCubit>().getNotes();
            },
            icon: Icon(AppIcons.clear_all, size: 20.sp),
            label: const Text('Clear Filters'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 400.ms),

        if (!hasSearchOrFilter) ...[
          SizedBox(height: compact ? 12.h : 16.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: compact ? 0 : 40.w),
            padding: EdgeInsets.all(compact ? 12.r : 16.r),
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
                  AppIcons.lightbulb_outline,
                  size: compact ? 18.sp : 20.sp,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Tip: Use tags to organize notes by topics or projects',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontSize: compact ? 11.sp : null,
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
      ],
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
