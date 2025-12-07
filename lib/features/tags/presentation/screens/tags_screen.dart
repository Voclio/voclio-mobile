import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart';
import '../cubit/tag_cubit.dart';
import '../widgets/tag_item.dart';
import '../widgets/tag_dialog.dart';

class TagsScreen extends StatelessWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TagCubit>()..loadTags(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Tags')),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (dialogContext) => TagDialog(
                    onSave: (name, color) {
                      context.read<TagCubit>().createTag(name, color);
                    },
                  ),
            );
          },
          child: const Icon(Icons.add),
        ),
        body: BlocBuilder<TagCubit, TagState>(
          builder: (context, state) {
            if (state is TagLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is TagError) {
              return Center(child: Text(state.message));
            }

            if (state is TagLoaded) {
              if (state.tags.isEmpty) {
                return const Center(child: Text('No tags yet'));
              }

              return ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: state.tags.length,
                itemBuilder: (context, index) {
                  final tag = state.tags[index];
                  return TagItem(
                    tag: tag,
                    onEdit: () {
                      showDialog(
                        context: context,
                        builder:
                            (dialogContext) => TagDialog(
                              tag: tag,
                              onSave: (name, color) {
                                context.read<TagCubit>().updateTag(
                                  tag.id,
                                  name,
                                  color,
                                );
                              },
                            ),
                      );
                    },
                    onDelete: () {
                      context.read<TagCubit>().deleteTag(tag.id);
                    },
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
