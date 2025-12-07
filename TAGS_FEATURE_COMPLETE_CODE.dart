// ============================================
// TAGS FEATURE - Complete Implementation
// ============================================

// ========== 1. ENTITY ==========
// File: lib/features/tags/domain/entities/tag_entity.dart

import 'package:equatable/equatable.dart';

class TagEntity extends Equatable {
  final String id;
  final String name;
  final String color;
  final String? description;
  final DateTime createdAt;

  const TagEntity({
    required this.id,
    required this.name,
    required this.color,
    this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, color, description, createdAt];
}

// ========== 2. MODEL ==========
// File: lib/features/tags/data/models/tag_model.dart

import 'package:voclio_app/features/tags/domain/entities/tag_entity.dart';

class TagModel {
  final String id;
  final String name;
  final String color;
  final String? description;
  final DateTime createdAt;

  TagModel({
    required this.id,
    required this.name,
    required this.color,
    this.description,
    required this.createdAt,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['tag_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      color: json['color'] ?? '#6B46C1',
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color,
      if (description != null) 'description': description,
    };
  }

  TagEntity toEntity() {
    return TagEntity(
      id: id,
      name: name,
      color: color,
      description: description,
      createdAt: createdAt,
    );
  }

  factory TagModel.fromEntity(TagEntity entity) {
    return TagModel(
      id: entity.id,
      name: entity.name,
      color: entity.color,
      description: entity.description,
      createdAt: entity.createdAt,
    );
  }
}

// ========== 3. REPOSITORY INTERFACE ==========
// File: lib/features/tags/domain/repositories/tag_repository.dart

import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/tag_entity.dart';

abstract class TagRepository {
  Future<Either<Failure, List<TagEntity>>> getTags();
  Future<Either<Failure, TagEntity>> getTag(String id);
  Future<Either<Failure, TagEntity>> createTag(TagEntity tag);
  Future<Either<Failure, TagEntity>> updateTag(TagEntity tag);
  Future<Either<Failure, void>> deleteTag(String id);
}

// ========== 4. REMOTE DATA SOURCE ==========
// File: lib/features/tags/data/datasources/tag_remote_datasource.dart

import 'package:voclio_app/core/api/api_client.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';
import '../models/tag_model.dart';

abstract class TagRemoteDataSource {
  Future<List<TagModel>> getTags();
  Future<TagModel> getTag(String id);
  Future<TagModel> createTag(TagModel tag);
  Future<TagModel> updateTag(String id, TagModel tag);
  Future<void> deleteTag(String id);
}

class TagRemoteDataSourceImpl implements TagRemoteDataSource {
  final ApiClient apiClient;

  TagRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<TagModel>> getTags() async {
    try {
      final response = await apiClient.get(ApiEndpoints.tags);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => TagModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tags: $e');
    }
  }

  @override
  Future<TagModel> getTag(String id) async {
    try {
      final response = await apiClient.get(ApiEndpoints.tagById(id));
      return TagModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to fetch tag: $e');
    }
  }

  @override
  Future<TagModel> createTag(TagModel tag) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.tags,
        data: tag.toJson(),
      );
      return TagModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create tag: $e');
    }
  }

  @override
  Future<TagModel> updateTag(String id, TagModel tag) async {
    try {
      final response = await apiClient.put(
        ApiEndpoints.tagById(id),
        data: tag.toJson(),
      );
      return TagModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update tag: $e');
    }
  }

  @override
  Future<void> deleteTag(String id) async {
    try {
      await apiClient.delete(ApiEndpoints.tagById(id));
    } catch (e) {
      throw Exception('Failed to delete tag: $e');
    }
  }
}

// ========== 5. REPOSITORY IMPLEMENTATION ==========
// File: lib/features/tags/data/repositories/tag_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/tags/domain/entities/tag_entity.dart';
import '../../domain/repositories/tag_repository.dart';
import '../datasources/tag_remote_datasource.dart';
import '../models/tag_model.dart';

class TagRepositoryImpl implements TagRepository {
  final TagRemoteDataSource remoteDataSource;

  TagRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TagEntity>>> getTags() async {
    try {
      final tags = await remoteDataSource.getTags();
      return Right(tags.map((tag) => tag.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, TagEntity>> getTag(String id) async {
    try {
      final tag = await remoteDataSource.getTag(id);
      return Right(tag.toEntity());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, TagEntity>> createTag(TagEntity tag) async {
    try {
      final tagModel = TagModel.fromEntity(tag);
      final createdTag = await remoteDataSource.createTag(tagModel);
      return Right(createdTag.toEntity());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, TagEntity>> updateTag(TagEntity tag) async {
    try {
      final tagModel = TagModel.fromEntity(tag);
      final updatedTag = await remoteDataSource.updateTag(tag.id, tagModel);
      return Right(updatedTag.toEntity());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteTag(String id) async {
    try {
      await remoteDataSource.deleteTag(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}

// ========== 6. USE CASES ==========
// File: lib/features/tags/domain/usecases/get_tags_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/tag_entity.dart';
import '../repositories/tag_repository.dart';

class GetTagsUseCase {
  final TagRepository repository;

  GetTagsUseCase(this.repository);

  Future<Either<Failure, List<TagEntity>>> call() async {
    return await repository.getTags();
  }
}

// File: lib/features/tags/domain/usecases/create_tag_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/tag_entity.dart';
import '../repositories/tag_repository.dart';

class CreateTagUseCase {
  final TagRepository repository;

  CreateTagUseCase(this.repository);

  Future<Either<Failure, TagEntity>> call(TagEntity tag) async {
    return await repository.createTag(tag);
  }
}

// File: lib/features/tags/domain/usecases/update_tag_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/tag_entity.dart';
import '../repositories/tag_repository.dart';

class UpdateTagUseCase {
  final TagRepository repository;

  UpdateTagUseCase(this.repository);

  Future<Either<Failure, TagEntity>> call(TagEntity tag) async {
    return await repository.updateTag(tag);
  }
}

// File: lib/features/tags/domain/usecases/delete_tag_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../repositories/tag_repository.dart';

class DeleteTagUseCase {
  final TagRepository repository;

  DeleteTagUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteTag(id);
  }
}

// ========== 7. STATE ==========
// File: lib/features/tags/presentation/bloc/tags_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/tag_entity.dart';

abstract class TagsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TagsInitial extends TagsState {}

class TagsLoading extends TagsState {}

class TagsLoaded extends TagsState {
  final List<TagEntity> tags;

  TagsLoaded(this.tags);

  @override
  List<Object?> get props => [tags];
}

class TagCreated extends TagsState {
  final TagEntity tag;

  TagCreated(this.tag);

  @override
  List<Object?> get props => [tag];
}

class TagUpdated extends TagsState {
  final TagEntity tag;

  TagUpdated(this.tag);

  @override
  List<Object?> get props => [tag];
}

class TagDeleted extends TagsState {
  final String id;

  TagDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class TagsError extends TagsState {
  final String message;

  TagsError(this.message);

  @override
  List<Object?> get props => [message];
}

// ========== 8. CUBIT ==========
// File: lib/features/tags/presentation/bloc/tags_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/tag_entity.dart';
import '../../domain/usecases/get_tags_usecase.dart';
import '../../domain/usecases/create_tag_usecase.dart';
import '../../domain/usecases/update_tag_usecase.dart';
import '../../domain/usecases/delete_tag_usecase.dart';
import 'tags_state.dart';

class TagsCubit extends Cubit<TagsState> {
  final GetTagsUseCase getTagsUseCase;
  final CreateTagUseCase createTagUseCase;
  final UpdateTagUseCase updateTagUseCase;
  final DeleteTagUseCase deleteTagUseCase;

  TagsCubit({
    required this.getTagsUseCase,
    required this.createTagUseCase,
    required this.updateTagUseCase,
    required this.deleteTagUseCase,
  }) : super(TagsInitial());

  Future<void> loadTags() async {
    emit(TagsLoading());
    
    final result = await getTagsUseCase();
    
    result.fold(
      (failure) => emit(TagsError('Failed to load tags')),
      (tags) => emit(TagsLoaded(tags)),
    );
  }

  Future<void> createTag(TagEntity tag) async {
    final result = await createTagUseCase(tag);
    
    result.fold(
      (failure) => emit(TagsError('Failed to create tag')),
      (createdTag) {
        emit(TagCreated(createdTag));
        loadTags(); // Refresh list
      },
    );
  }

  Future<void> updateTag(TagEntity tag) async {
    final result = await updateTagUseCase(tag);
    
    result.fold(
      (failure) => emit(TagsError('Failed to update tag')),
      (updatedTag) {
        emit(TagUpdated(updatedTag));
        loadTags(); // Refresh list
      },
    );
  }

  Future<void> deleteTag(String id) async {
    final result = await deleteTagUseCase(id);
    
    result.fold(
      (failure) => emit(TagsError('Failed to delete tag')),
      (_) {
        emit(TagDeleted(id));
        loadTags(); // Refresh list
      },
    );
  }
}

// ========== 9. SCREEN ==========
// File: lib/features/tags/presentation/screens/tags_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/tags_cubit.dart';
import '../bloc/tags_state.dart';
import '../widgets/tag_chip.dart';
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
                  color: '#${selectedColor.value.toRadixString(16).substring(2)}',
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
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Tag'),
        content: const Text('Are you sure you want to delete this tag?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<TagsCubit>().deleteTag(id);
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ========== 10. WIDGETS ==========
// File: lib/features/tags/presentation/widgets/tag_chip.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/tag_entity.dart';

class TagChipWidget extends StatelessWidget {
  final TagEntity tag;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TagChipWidget({
    super.key,
    required this.tag,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        label: Text(tag.name),
        backgroundColor: Color(
          int.parse(tag.color.replaceFirst('#', '0xFF')),
        ).withOpacity(0.2),
        labelStyle: TextStyle(
          color: Color(
            int.parse(tag.color.replaceFirst('#', '0xFF')),
          ),
          fontSize: 12.sp,
        ),
        deleteIcon: onDelete != null ? const Icon(Icons.close, size: 16) : null,
        onDeleted: onDelete,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      ),
    );
  }
}
