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
