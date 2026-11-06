import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/centrix_theme.dart';
import '../../../core/widgets/centrix_page_header.dart';

import '../../auth/viewmodels/auth_view_model.dart';
import '../viewmodels/ticket_list_view_model.dart';

class TicketListView extends StatelessWidget {
  const TicketListView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthViewModel>();
    final viewModel = context.watch<TicketListViewModel>();
    final token = auth.session!.token;
    final isPending = viewModel.mode == TicketListMode.pending;
    final title = isPending ? 'Tickets pendientes' : 'Mis tickets';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: viewModel.isLoading ? null : () => viewModel.load(token),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: _content(context, viewModel, auth, token, isPending),
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    TicketListViewModel viewModel,
    AuthViewModel auth,
    String token,
    bool isPending,
  ) {
    if (viewModel.isLoading && viewModel.tickets.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.errorMessage != null && viewModel.tickets.isEmpty) {
      return _Message(
        icon: Icons.cloud_off_outlined,
        title: viewModel.requiresLogin
            ? 'Sesión vencida'
            : 'No pudimos cargar los tickets',
        message: viewModel.errorMessage!,
        label: viewModel.requiresLogin ? 'Iniciar sesión' : 'Reintentar',
        onPressed: viewModel.requiresLogin
            ? auth.logout
            : () => viewModel.load(token),
      );
    }
    if (viewModel.tickets.isEmpty) {
      return _Message(
        icon: Icons.confirmation_number_outlined,
        title: isPending
            ? 'No hay tickets pendientes'
            : 'Aún no tienes tickets',
        message: isPending
            ? 'Los tickets abiertos o en revisión aparecerán aquí.'
            : 'Los tickets que crees aparecerán aquí.',
        label: 'Actualizar',
        onPressed: () => viewModel.load(token),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.load(token),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: viewModel.tickets.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: CentrixPageHeader(
                title: isPending ? 'Tickets pendientes' : 'Mis tickets',
                description: isPending
                    ? 'Revisa las incidencias que esperan atención.'
                    : 'Da seguimiento a las incidencias que has reportado.',
                icon: isPending
                    ? Icons.pending_actions_rounded
                    : Icons.confirmation_number_rounded,
                eyebrow: 'SEGUIMIENTO',
              ),
            );
          }
          final ticket = viewModel.tickets[index - 1];
          return Card(
            key: Key('ticket-card-${ticket.ticketId}'),
            margin: const EdgeInsets.only(bottom: 12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () async {
                await context.push(
                  '/tickets/${Uri.encodeComponent(ticket.ticketId)}',
                );
                if (context.mounted) viewModel.load(token);
              },
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ticket.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_outward_rounded,
                          color: CentrixColors.leaf,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ticket.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: CentrixColors.forest),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text(ticket.status)),
                        Chip(label: Text('Prioridad: ${ticket.priority}')),
                      ],
                    ),
                    const Divider(height: 20),
                    Text(
                      'Reportado por ${ticket.authorName}  ·  Asignado a ${ticket.assignedToName}',
                      style: const TextStyle(
                        color: CentrixColors.forest,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.message,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onPressed, child: Text(label)),
        ],
      ),
    ),
  );
}
