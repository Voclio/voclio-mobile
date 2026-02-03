import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/common/dialogs/voclio_dialog.dart';
import '../bloc/tags_cubit.dart';
import '../bloc/tags_state.dart';
import '../../domain/entities/tag_entity.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateTagDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<TagsCubit, TagsState>(
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
          if (state is TagsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TagsLoaded) {
            if (state.tags.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.label_off, size: 64.sp, color: Colors.grey),
                    SizedBox(height: 16.h),
                    Text(
                      'No tags yet',
                      style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                    ),
                    SizedBox(height: 8.h),
                    ElevatedButton.icon(
                      onPressed: () => _showCreateTagDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Tag'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: state.tags.length,
              itemBuilder: (context, index) {
                final tag = state.tags[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12.h),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(
                        int.parse(tag.color.replaceFirst('#', '0xFF')),
                      ),
                      child: const Icon(Icons.label, color: Colors.white),
                    ),
                    title: Text(tag.name),
                    subtitle: tag.description != null ? Text(tag.description!) : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showUpdateTagDialog(context, tag),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(context, tag.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  void _showCreateTagDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    Color selectedColor = Colors.purple;

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
            // Simple color picker (you can use flutter_colorpicker package)
            Wrap(
              spacing: 8.w,
              children: [
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.purple,
                Colors.pink,
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
                  color: '#${selectedColor.toARGB32().toRadixString(16).substring(2)}',
                  description: descController.text.isEmpty ? null : descController.text,
                  createdAt: DateTime.now(),
                );
                context.read<TagsCubit>().createTag(tag);
                Navigator.pop(dialogContext);
              }
            },
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
      message: 'Are you sure you want to delete this tag? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      onConfirm: () {
        context.read<TagsCubit>().deleteTag(id);
        Navigator.pop(context);
      },
    );
  }
}
