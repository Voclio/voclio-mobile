import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/features/productivity/presentation/bloc/ai_suggestions_cubit.dart';
import 'package:voclio_app/features/productivity/presentation/bloc/ai_suggestions_state.dart';

class AiSuggestionsWidget extends StatelessWidget {
  const AiSuggestionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiSuggestionsCubit, AiSuggestionsState>(
      builder: (context, state) {
        if (state is AiSuggestionsLoading) {
          return _buildLoadingState();
        }
        if (state is AiSuggestionsLoaded) {
          final suggestion = state.suggestions.suggestions.isNotEmpty
              ? state.suggestions.suggestions.first
              : _defaultMessage;
          return _buildCard(suggestion);
        }
        return _buildCard(_defaultMessage);
      },
    );
  }

  static const _defaultMessage =
      'Set specific times each day to focus on important tasks and improve your completion rate.';

  Widget _buildCard(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: HomeSystemTokens.cardDecoration(
        tint: HomeSystemTokens.purple.withValues(alpha: 0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: HomeSystemTokens.purple.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(HomeSystemTokens.radiusSm.r),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: HomeSystemTokens.purple,
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'AI Insight',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: HomeSystemTokens.ink,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: HomeSystemTokens.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'New',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: HomeSystemTokens.purple,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 13.sp,
              color: HomeSystemTokens.inkSoft,
              height: 1.45,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 96.h,
      decoration: HomeSystemTokens.cardDecoration(),
      child: Center(
        child: SizedBox(
          width: 22.w,
          height: 22.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: HomeSystemTokens.purple,
          ),
        ),
      ),
    );
  }
}
