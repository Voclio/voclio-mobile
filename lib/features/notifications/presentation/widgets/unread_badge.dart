import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voclio_app/core/extentions/color_extentions.dart';
import '../cubit/notifications_cubit.dart';

class UnreadBadge extends StatelessWidget {
  const UnreadBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        if (state is NotificationsLoaded) {
          final unreadCount = state.notifications.where((n) => !n.isRead).length;
          
          if (unreadCount > 0) {
            return Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).extension<MyColors>()!.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: TextStyle(
                  color: Theme.of(context).extension<MyColors>()!.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }
        }
        return const SizedBox();
      },
    );
  }
}
