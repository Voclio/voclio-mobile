import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/common/dialogs/voclio_dialog.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_widgets.dart';

import '../../domain/entities/tag_entity.dart';
import '../bloc/tags_cubit.dart';
import '../bloc/tags_state.dart';

class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TagsCubit>().loadTags();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TagsCubit, TagsState>(
      listener: (context, state) {
        if (state is TagsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is TagCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tag created successfully')),
          );
        }
        if (state is TagDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tag deleted successfully')),
          );
        }
      },
      builder: (context, state) {
        final tagCount = state is TagsLoaded ? state.tags.length : 0;

        return HomeSecondaryScaffold(
          title: 'Tags',
          subtitle: tagCount == 0 ? 'Organize your tasks' : '$tagCount tags',
          icon: Icons.label_rounded,
          accent: HomeSystemTokens.green,
          showBack: Navigator.canPop(context),
          actions: [
            HomeIconButton(
              icon: Icons.add_rounded,
              color: HomeSystemTokens.green,
              onTap: () => _showCreateTagDialog(context),
            ),
          ],
          body: _TagsBody(
            state: state,
            onCreateTag: () => _showCreateTagDialog(context),
            onEditTag: (tag) => _showUpdateTagDialog(context, tag),
            onDeleteTag: (id) => _confirmDelete(context, id),
          ),
        );
      },
    );
  }

  void _showCreateTagDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    Color selectedColor = HomeSystemTokens.purple;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Tag'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Tag Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 8.w,
              children: [
                HomeSystemTokens.coral,
                HomeSystemTokens.orange,
                HomeSystemTokens.green,
                HomeSystemTokens.blue,
                HomeSystemTokens.purple,
              ].map((color) {
                return GestureDetector(
                  onTap: () {
                    selectedColor = color;
                  },
                  child: Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final tag = TagEntity(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  color:
                      '#${selectedColor.toARGB32().toRadixString(16).substring(2)}',
                  description: descController.text.isEmpty
                      ? null
                      : descController.text,
                  createdAt: DateTime.now(),
                );
                context.read<TagsCubit>().createTag(tag);
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: HomeSystemTokens.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showUpdateTagDialog(BuildContext context, TagEntity tag) {
    // Similar to create dialog but with pre-filled values
  }

  void _confirmDelete(BuildContext context, String id) {
    VoclioDialog.showConfirm(
      context: context,
      title: 'Delete Tag',
      message:
          'Are you sure you want to delete this tag? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      onConfirm: () {
        context.read<TagsCubit>().deleteTag(id);
        Navigator.pop(context);
      },
    );
  }
}

class _TagsBody extends StatelessWidget {
  final TagsState state;
  final VoidCallback onCreateTag;
  final void Function(TagEntity tag) onEditTag;
  final void Function(String id) onDeleteTag;

  const _TagsBody({
    required this.state,
    required this.onCreateTag,
    required this.onEditTag,
    required this.onDeleteTag,
  });

  @override
  Widget build(BuildContext context) {
    final currentState = state;

    if (currentState is TagsLoading) {
      return Center(
        child: CircularProgressIndicator(color: HomeSystemTokens.green),
      );
    }

    if (currentState is TagsLoaded) {
      final tags = currentState.tags;
      if (tags.isEmpty) {
        return HomeEmptyState(
          icon: Icons.label_off_rounded,
          title: 'No tags yet',
          message: 'Create tags to organize and filter your tasks',
          actionLabel: 'Create Tag',
          onAction: onCreateTag,
          accent: HomeSystemTokens.green,
        );
      }

      return ListView.separated(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        itemCount: tags.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (context, index) {
          final tag = tags[index];
          final tagColor = Color(
            int.parse(tag.color.replaceFirst('#', '0xFF')),
          );

          return HomeSectionCard(
            padding: EdgeInsets.zero,
            child: HomeMenuTile(
              icon: Icons.label_rounded,
              title: tag.name,
              subtitle: tag.description,
              iconColor: tagColor,
              showDivider: false,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HomeIconButton(
                    icon: Icons.edit_rounded,
                    color: HomeSystemTokens.blue,
                    onTap: () => onEditTag(tag),
                  ),
                  SizedBox(width: 8.w),
                  HomeIconButton(
                    icon: Icons.delete_rounded,
                    color: HomeSystemTokens.coral,
                    onTap: () => onDeleteTag(tag.id),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return const SizedBox();
  }
}
