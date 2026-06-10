import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/features/productivity/presentation/bloc/ai_suggestions_cubit.dart';
import 'package:voclio_app/features/productivity/presentation/bloc/ai_suggestions_state.dart';

class AiSuggestionsWidget extends StatelessWidget {
  const AiSuggestionsWidget({super.key});

  static const _purple = Color(0xFF7C5CFC);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiSuggestionsCubit, AiSuggestionsState>(
      builder: (context, state) {
        if (state is AiSuggestionsLoading) {
          return _buildLoadingState();
        } else if (state is AiSuggestionsLoaded) {
          return _buildInsightCard(state);
        } else if (state is AiSuggestionsError) {
          return _buildFallbackCard();
        }
        return _buildFallbackCard();
      },
    );
  }

  Widget _buildInsightCard(AiSuggestionsLoaded state) {
    final suggestion = state.suggestions.suggestions.isNotEmpty
        ? state.suggestions.suggestions.first
        : 'You tend to be most productive between 9 AM – 12 PM. Schedule your deep work in this time.';

    return _insightContainer(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: _purple, size: 16.sp),
                    SizedBox(width: 4.w),
                    Icon(Icons.auto_awesome, color: _purple.withOpacity(0.6), size: 12.sp),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: _purple.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'New',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: _purple,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  'AI Insight',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  suggestion,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _purple.withOpacity(0.2),
                  _purple.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.diamond_outlined, color: _purple, size: 28.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackCard() {
    return _insightContainer(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: _purple, size: 16.sp),
                    SizedBox(width: 4.w),
                    Icon(Icons.auto_awesome, color: _purple.withOpacity(0.6), size: 12.sp),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: _purple.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'New',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: _purple,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  'AI Insight',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 6.h),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF6B7280),
                      height: 1.5,
                    ),
                    children: const [
                      TextSpan(
                        text: 'You tend to be most productive between ',
                      ),
                      TextSpan(
                        text: '9 AM – 12 PM',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      TextSpan(
                        text: '. Schedule your deep work in this time.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _purple.withOpacity(0.2),
                  _purple.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.diamond_outlined, color: _purple, size: 28.sp),
          ),
        ],
      ),
    );
  }

  Widget _insightContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _purple.withOpacity(0.08),
            _purple.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _purple.withOpacity(0.1)),
      ),
      child: child,
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        color: _purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}
