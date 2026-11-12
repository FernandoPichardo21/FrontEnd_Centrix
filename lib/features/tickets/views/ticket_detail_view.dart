import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/centrix_theme.dart';
import '../../../core/widgets/centrix_glass.dart';
import '../../../core/widgets/centrix_page_header.dart';
import '../../auth/viewmodels/auth_view_model.dart';
import '../models/ticket_status.dart';
import '../models/ticket_evidence.dart';
import '../viewmodels/ticket_detail_view_model.dart';

class TicketDetailView extends StatelessWidget {
  const TicketDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthViewModel>();
    final viewModel = context.watch<TicketDetailViewModel>();
    final token = auth.session!.token;
    final ticket = viewModel.ticket;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del ticket'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: viewModel.isLoading || viewModel.isSaving
                ? null
                : () => viewModel.load(token),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: viewModel.isLoading && ticket == null
              ? const Center(child: CircularProgressIndicator())
              : ticket == null
              ? _NoTicket(
                  message:
                      viewModel.errorMessage ?? 'No se encontró el ticket.',
                  onRetry: viewModel.requiresLogin
                      ? auth.logout
                      : () => viewModel.load(token),
                  label: viewModel.requiresLogin
                      ? 'Iniciar sesión'
                      : 'Reintentar',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  children: [
                    CentrixPageHeader(
                      title: ticket.title,
                      description: 'Consulta los datos y el seguimiento de esta incidencia.',
                      icon: Icons.confirmation_number_rounded,
                      eyebrow: 'DETALLE DEL TICKET',
                    ),
                    const SizedBox(height: 18),
                    CentrixGlass(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resumen',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Chip(label: Text(ticket.status)),
                                Chip(
                                  label: Text('Prioridad: ${ticket.priority}'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(ticket.description),
                            const Divider(height: 28),
                            Text('Reportado por: ${ticket.authorName}'),
                            const SizedBox(height: 5),
                            Text('Asignado a: ${ticket.assignedToName}'),
                            if (ticket.createdAt != null) ...[
                              const SizedBox(height: 5),
                              Text(
                                'Creado: ${MaterialLocalizations.of(context).formatMediumDate(ticket.createdAt!.toLocal())}',
                              ),
                            ],
                            const SizedBox(height: 12),
                            SelectableText(
                              'ID: ${ticket.ticketId}',
                              style: const TextStyle(
                                color: CentrixColors.forest,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (viewModel.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        viewModel.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    _EvidenceCard(viewModel: viewModel, token: token),
                    if (viewModel.canManage) ...[
                      const SizedBox(height: 18),
                      CentrixGlass(
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Gestionar ticket',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Asigna a una persona y actualiza el avance del ticket.',
                                style: TextStyle(color: CentrixColors.forest),
                              ),
                              const SizedBox(height: 22),
                              const Text('Asignar a un usuario'),
                              if (viewModel.assigneesError != null) ...[
                                Text(viewModel.assigneesError!),
                                TextButton(
                                  onPressed: () =>
                                      viewModel.loadAssignees(token),
                                  child: const Text('Reintentar usuarios'),
                                ),
                              ],
                              if (viewModel.assignees.isNotEmpty)
                                _SelectionFrame(
                                  child: DropdownButton<String>(
                                    key: const Key('ticket-assignee'),
                                    isExpanded: true,
                                    underline: const SizedBox.shrink(),
                                    hint: const Text('Selecciona un usuario'),
                                    value: viewModel.selectedAssigneeId,
                                    items: [
                                      for (final user in viewModel.assignees)
                                        DropdownMenuItem(
                                          value: user.id,
                                          child: Text(
                                            '${user.fullName} (${user.email})',
                                          ),
                                        ),
                                    ],
                                    onChanged:
                                        viewModel.isSaving ||
                                            !viewModel.canAssign
                                        ? null
                                        : viewModel.selectAssignee,
                                  ),
                                ),
                              const SizedBox(height: 10),
                              FilledButton(
                                key: const Key('assign-ticket'),
                                onPressed:
                                    viewModel.isSaving ||
                                        !viewModel.canAssign ||
                                        viewModel.selectedAssigneeId == null
                                    ? null
                                    : () => viewModel.assign(token),
                                child: const Text('Asignar ticket'),
                              ),
                              const Divider(height: 36),
                              const Text('Cambiar estado'),
                              _SelectionFrame(
                                child: DropdownButton<TicketStatus>(
                                  key: const Key('ticket-status'),
                                  isExpanded: true,
                                  underline: const SizedBox.shrink(),
                                  hint: const Text('Selecciona un estado'),
                                  value: viewModel.selectedStatus,
                                  items: [
                                    for (final status
                                        in viewModel.availableStatuses)
                                      DropdownMenuItem(
                                        value: status,
                                        child: Text(status.label),
                                      ),
                                  ],
                                  onChanged:
                                      viewModel.isSaving ||
                                          viewModel.availableStatuses.isEmpty
                                      ? null
                                      : viewModel.selectStatus,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                key: const Key('ticket-status-comment'),
                                enabled: !viewModel.isSaving,
                                maxLines: 3,
                                onChanged: viewModel.setStatusComment,
                                decoration: InputDecoration(
                                  labelText:
                                      viewModel
                                              .selectedStatus
                                              ?.requiresComment ==
                                          true
                                      ? 'Comentario obligatorio'
                                      : 'Comentario (opcional)',
                                  hintText: 'Explica el cambio o la solución aplicada',
                                ),
                              ),
                              const SizedBox(height: 10),
                              FilledButton(
                                key: const Key('save-ticket-status'),
                                onPressed:
                                    viewModel.isSaving ||
                                        viewModel.selectedStatus == null
                                    ? null
                                    : () => viewModel.updateStatus(token),
                                child: const Text('Guardar estado'),
                              ),
                              if (viewModel.isSaving) ...[
                                const SizedBox(height: 12),
                                const LinearProgressIndicator(),
                              ],
                              if (viewModel.actionMessage != null) ...[
                                const SizedBox(height: 12),
                                Text(viewModel.actionMessage!),
                              ],
                              if (viewModel.requiresLogin)
                                TextButton(
                                  onPressed: auth.logout,
                                  child: const Text('Iniciar sesión'),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _EvidenceCard extends StatelessWidget {
  const _EvidenceCard({required this.viewModel, required this.token});

  final TicketDetailViewModel viewModel;
  final String token;

  @override
  Widget build(BuildContext context) {
    return CentrixGlass(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Evidencias', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text(
              'Consulta las fotografías y videos adjuntos a esta incidencia.',
            ),
            if (viewModel.evidenceError != null) ...[
              const SizedBox(height: 10),
              Text(
                viewModel.evidenceError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              TextButton(
                onPressed: viewModel.requiresLogin
                    ? context.read<AuthViewModel>().logout
                    : () => viewModel.loadEvidences(token),
                child: Text(
                  viewModel.requiresLogin
                      ? 'Iniciar sesión'
                      : 'Reintentar carga',
                ),
              ),
            ],
            const Divider(height: 30),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Archivos adjuntos',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Actualizar evidencias',
                  onPressed: viewModel.isLoadingEvidences
                      ? null
                      : () => viewModel.loadEvidences(token),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            if (viewModel.isLoadingEvidences) const LinearProgressIndicator(),
            if (!viewModel.isLoadingEvidences &&
                viewModel.evidences.isEmpty &&
                viewModel.evidenceError == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Este ticket aún no tiene evidencias.'),
              ),
            for (final evidence in viewModel.evidences)
              _EvidenceItem(evidence: evidence),
          ],
        ),
      ),
    );
  }
}

class _EvidenceItem extends StatelessWidget {
  const _EvidenceItem({required this.evidence});

  final TicketEvidence evidence;

  Future<void> _open(BuildContext context) async {
    final opened = await launchUrl(
      Uri.parse(evidence.signedUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo abrir la evidencia. Actualiza la lista e inténtalo de nuevo.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (evidence.isImage)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              evidence.signedUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox(
                height: 90,
                child: Center(
                  child: Text(
                    'Vista previa no disponible. Actualiza las evidencias.',
                  ),
                ),
              ),
            ),
          )
        else
          const ListTile(
            leading: Icon(Icons.videocam_outlined),
            title: Text('Video MP4'),
          ),
        const SizedBox(height: 5),
        Text(
          '${(evidence.size / 1024).toStringAsFixed(0)} KB · ${evidence.mimeType}',
        ),
        TextButton.icon(
          onPressed: () => _open(context),
          icon: const Icon(Icons.open_in_new),
          label: const Text('Abrir evidencia'),
        ),
      ],
    ),
  );
}

class _SelectionFrame extends StatelessWidget {
  const _SelectionFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: CentrixColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: CentrixColors.outline),
    ),
    child: child,
  );
}

class _NoTicket extends StatelessWidget {
  const _NoTicket({
    required this.message,
    required this.onRetry,
    required this.label,
  });

  final String message;
  final VoidCallback onRetry;
  final String label;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.confirmation_number_outlined, size: 56),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        FilledButton(onPressed: onRetry, child: Text(label)),
      ],
    ),
  );
}
