// Example usage of the new loading and refresh functionality

// 1. Using AuthLoadingOverlay for full-screen loading
/*
AuthLoadingOverlay(
  isLoading: state is AuthLoading,
  loadingMessage: 'Signing you in...',
  child: YourScreenContent(),
)
*/

// 2. Using AuthRefreshIndicator for pull-to-refresh
/*
AuthRefreshIndicator(
  onRefresh: () async {
    context.read<AuthBloc>().add(RefreshAuthEvent());
    await Future.delayed(const Duration(milliseconds: 500));
  },
  child: SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    child: YourContent(),
  ),
)
*/

// 3. Using AuthLoadingWidget for custom loading states
/*
AuthLoadingWidget(
  message: 'Verifying OTP...',
  size: 40.w,
)
*/

// 4. Using AuthShimmerWidget for skeleton loading
/*
AuthShimmerWidget(
  width: double.infinity,
  height: 50.h,
  borderRadius: 12.r,
)
*/
