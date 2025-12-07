import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/tag_entity.dart';
import '../../domain/usecases/get_tags_usecase.dart';
import '../../domain/usecases/create_tag_usecase.dart';
import '../../domain/usecases/update_tag_usecase.dart';
import '../../domain/usecases/delete_tag_usecase.dart';

part 'tag_state.dart';

class TagCubit extends Cubit<TagState> {
  final GetTagsUseCase getTagsUseCase;
  final CreateTagUseCase createTagUseCase;
  final UpdateTagUseCase updateTagUseCase;
  final DeleteTagUseCase deleteTagUseCase;

  TagCubit({
    required this.getTagsUseCase,
    required this.createTagUseCase,
    required this.updateTagUseCase,
    required this.deleteTagUseCase,
  }) : super(TagInitial());

  Future<void> loadTags() async {
    emit(TagLoading());
    final result = await getTagsUseCase();
    result.fold(
      (failure) => emit(TagError(failure.toString())),
      (tags) => emit(TagLoaded(tags)),
    );
  }

  Future<void> createTag(String name, String color) async {
    final result = await createTagUseCase(name, color);
    result.fold(
      (failure) => emit(TagError(failure.toString())),
      (_) => loadTags(),
    );
  }

  Future<void> updateTag(String id, String name, String color) async {
    final result = await updateTagUseCase(id, name, color);
    result.fold(
      (failure) => emit(TagError(failure.toString())),
      (_) => loadTags(),
    );
  }

  Future<void> deleteTag(String id) async {
    final result = await deleteTagUseCase(id);
    result.fold(
      (failure) => emit(TagError(failure.toString())),
      (_) => loadTags(),
    );
  }
}
