import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/centrix_page_header.dart';

import '../../auth/viewmodels/auth_view_model.dart';
import '../models/ticket.dart';
import '../viewmodels/department_tickets_view_model.dart';

class DepartmentTicketsView extends StatelessWidget {
  const DepartmentTicketsView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthViewModel>();
    final viewModel = context.watch<DepartmentTicketsViewModel>();
    final token = auth.session!.token;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets por departamento'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed:
                viewModel.selectedDepartmentId == null ||
                    viewModel.isLoadingTickets
                ? null
                : () => viewModel.loadTickets(token),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: _content(context, viewModel, auth, token),
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    DepartmentTicketsViewModel viewModel,
    AuthViewModel auth,
    String token,
  ) {
    if (viewModel.isLoadingDepartments) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.departmentError != null) {
      return _StatusMessage(
        icon: Icons.cloud_off_outlined,
        title: viewModel.requiresLogin
            ? 'Sesión vencida'
            : 'No pudimos cargar los departamentos',
        message: viewModel.departmentError!,
        buttonLabel: viewModel.requiresLogin
            ? 'Volver a iniciar sesión'
            : 'Reintentar',
        onPressed: viewModel.requiresLogin
            ? auth.logout
            : () => viewModel.loadDepartments(token),
      );
    }
    if (viewModel.departments.isEmpty) {
      return _StatusMessage(
        icon: Icons.apartment_outlined,
        title: 'No hay departamentos disponibles',
        message: 'Necesitas un departamento para consultar sus tickets.',
        buttonLabel: 'Actualizar',
        onPressed: () => viewModel.loadDepartments(token),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CentrixPageHeader(
            title: 'Consulta de incidencias',
            description: 'Selecciona un departamento para revisar sus tickets.',
            icon: Icons.view_list_rounded,
            eyebrow: 'TICKETS',
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            key: const Key('tickets-department'),
            initialValue: viewModel.selectedDepartmentId,
            decoration: const InputDecoration(
              labelText: 'Departamento',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final department in viewModel.departments)
                DropdownMenuItem(
                  value: department.departmentId,
                  child: Text(department.name),
                ),
            ],
            onChanged: (value) {
              if (value != null) viewModel.selectDepartment(value, token);
            },
          ),
          const SizedBox(height: 20),
          Expanded(child: _ticketContent(context, viewModel, auth, token)),
        ],
      ),
    );
  }

  Widget _ticketContent(
    BuildContext context,
    DepartmentTicketsViewModel viewModel,
    AuthViewModel auth,
    String token,
  ) {
    if (viewModel.isLoadingTickets) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.ticketError != null) {
      return _StatusMessage(
        icon: Icons.cloud_off_outlined,
        title: viewModel.requiresLogin
            ? 'Sesión vencida'
            : 'No pudimos cargar los tickets',
        message: viewModel.ticketError!,
        buttonLabel: viewModel.requiresLogin
            ? 'Volver a iniciar sesión'
            : 'Reintentar',
        onPressed: viewModel.requiresLogin
            ? auth.logout
            : () => viewModel.loadTickets(token),
      );
    }
    if (viewModel.tickets.isEmpty) {
      return _StatusMessage(
        icon: Icons.confirmation_number_outlined,
        title: 'Sin tickets en este departamento',
        message: 'Cuando se registren incidencias, aparecerán aquí.',
        buttonLabel: 'Actualizar',
        onPressed: () => viewModel.loadTickets(token),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${viewModel.tickets.length} tickets',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => viewModel.loadTickets(token),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: viewModel.tickets.length,
              itemBuilder: (context, index) {
                return _TicketCard(
                  ticket: viewModel.tickets[index],
                  onOpen: () async {
                    await context.push(
                      '/tickets/${Uri.encodeComponent(viewModel.tickets[index].ticketId)}',
                    );
                    if (context.mounted) viewModel.loadTickets(token);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, required this.onOpen});

  final Ticket ticket;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final createdAt = ticket.createdAt;
    final dateLabel = createdAt == null
        ? null
        : MaterialLocalizations.of(context)
              .formatMediumDate(createdAt.toLocal());
    final priorityLabel = ticket.priority == 'Critica'
        ? 'Crítica'
        : ticket.priority;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onOpen,
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
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(label: Text(ticket.status)),
                ],
              ),
              const SizedBox(height: 8),
              Text(ticket.description),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(Icons.flag_outlined, size: 18),
                    label: Text(priorityLabel),
                  ),
                  if (dateLabel != null)
                    Chip(
                      avatar: const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                      ),
                      label: Text(dateLabel),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text('Reportado por: ${ticket.authorName}'),
              Text('Asignado a: ${ticket.assignedToName}'),
              const SizedBox(height: 8),
              SelectableText(
                'ID: ${ticket.ticketId}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(onPressed: onPressed, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}
