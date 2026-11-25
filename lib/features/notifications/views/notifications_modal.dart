import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/centrix_theme.dart';
import '../../../core/widgets/centrix_glass.dart';
import '../../auth/viewmodels/auth_view_model.dart';
import '../models/notification_item.dart';
import '../viewmodels/notification_view_model.dart';

class NotificationsModal extends StatelessWidget {
  const NotificationsModal({super.key});

  static Future<void> show(BuildContext context) {
    final auth = context.read<AuthViewModel>();
    final session = auth.session;
    if (session != null) {
      context.read<NotificationViewModel>().load(session.token);
    }
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationsModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthViewModel>();
    final notificationVm = context.watch<NotificationViewModel>();
    final token = auth.session?.token ?? '';
    final notifications = notificationVm.notifications;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return CentrixGlass(
          radius: 24,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: CentrixColors.sage.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.notifications_active,
                          color: CentrixColors.leaf,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Notificaciones',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: CentrixColors.ink,
                              ),
                        ),
                      ],
                    ),
                    if (notificationVm.unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: CentrixColors.leaf,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${notificationVm.unreadCount} nuevas',
                          style: const TextStyle(
                            color: CentrixColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const Divider(height: 24, color: CentrixColors.mint),
                Expanded(
                  child: notificationVm.isLoading && notifications.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : notifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_none,
                                size: 56,
                                color: CentrixColors.sage.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No tienes notificaciones pendientes',
                                style: TextStyle(
                                  color: CentrixColors.ink.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: notifications.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = notifications[index];
                            return _NotificationTile(
                              item: item,
                              onTap: () async {
                                if (!item.isRead && token.isNotEmpty) {
                                  await notificationVm.markAsRead(
                                    item.id,
                                    token,
                                  );
                                }
                                if (item.ticketId != null &&
                                    item.ticketId!.isNotEmpty &&
                                    context.mounted) {
                                  Navigator.of(context).pop();
                                  context.push('/tickets/${item.ticketId}');
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});

  final NotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: item.isRead
              ? CentrixColors.canvas.withValues(alpha: 0.5)
              : CentrixColors.mint.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isRead
                ? CentrixColors.sage.withValues(alpha: 0.2)
                : CentrixColors.leaf.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 10),
              child: Icon(
                item.type == 'ticket_assigned'
                    ? Icons.assignment_ind
                    : item.type == 'status_changed'
                    ? Icons.sync
                    : Icons.notifications,
                color: item.isRead ? CentrixColors.sage : CentrixColors.leaf,
                size: 22,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: item.isRead
                                ? FontWeight.w600
                                : FontWeight.bold,
                            fontSize: 14,
                            color: CentrixColors.ink,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: const BoxDecoration(
                            color: CentrixColors.leaf,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: TextStyle(
                      fontSize: 13,
                      color: CentrixColors.ink.withValues(alpha: 0.8),
                    ),
                  ),
                  if (item.ticketId != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          const Text(
                            'Toca para ver ticket',
                            style: TextStyle(
                              fontSize: 11,
                              color: CentrixColors.leaf,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                            color: CentrixColors.leaf,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
