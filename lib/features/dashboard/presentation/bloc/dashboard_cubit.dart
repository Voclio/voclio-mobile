import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voclio_app/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:voclio_app/features/dashboard/domain/usecases/get_quick_stats_usecase.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final GetDashboardStatsUseCase getDashboardStatsUseCase;
  final GetQuickStatsUseCase getQuickStatsUseCase;

  DashboardCubit({
    required this.getDashboardStatsUseCase,
    required this.getQuickStatsUseCase,
  }) : super(DashboardInitial());

  Future<void> loadDashboardStats({bool force = false}) async {
    if (!force && state is DashboardStatsLoaded) return;
    if (!force && state is DashboardLoading) return;

    emit(DashboardLoading());

    final result = await getDashboardStatsUseCase();

    result.fold(
      (failure) => emit(DashboardError('Failed to load dashboard stats')),
      (stats) => emit(DashboardStatsLoaded(stats)),
    );
  }

  Future<void> loadQuickStats() async {
    emit(DashboardLoading());

    final result = await getQuickStatsUseCase();

    result.fold(
      (failure) => emit(DashboardError('Failed to load quick stats')),
      (stats) => emit(QuickStatsLoaded(stats)),
    );
  }

  Future<void> refresh() async {
    await loadDashboardStats(force: true);
  }
}
